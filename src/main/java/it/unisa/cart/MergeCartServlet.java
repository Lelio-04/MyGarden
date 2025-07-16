package it.unisa.cart;

import it.unisa.db.ProductBean;
import it.unisa.db.ProductDaoDataSource;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import javax.sql.DataSource;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/MergeCartServlet")
public class MergeCartServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private transient CartDAO cartDAO;
    private transient ProductDaoDataSource productDAO; // Still needed for product details in guest cart parsing, if not already present.

    @Override
    public void init() throws ServletException {
        DataSource dataSource = (DataSource) getServletContext().getAttribute("DataSourceStorage");
        cartDAO = new CartDAO(dataSource);
        productDAO = new ProductDaoDataSource(dataSource); // Initialize ProductDaoDataSource
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        Integer userId = (Integer) session.getAttribute("userId");

        // Ensure user is logged in
        if (userId == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("{\"error\":\"User not logged in.\"}");
            return;
        }

        StringBuilder sb = new StringBuilder();
        try (BufferedReader reader = new BufferedReader(new InputStreamReader(request.getInputStream()))) {
            String line;
            while ((line = reader.readLine()) != null) {
                sb.append(line);
            }
        }

        String jsonPayload = sb.toString();
        // The parseJsonToCartList still attempts to get ProductBean,
        // so productDAO might be implicitly needed there if the guest cart JSON is incomplete.
        List<CartBean> guestCart = null;
		try {
			guestCart = parseJsonToCartList(jsonPayload);
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} // Custom parsing for guest cart

        try {
            // Get current user's cart from DB (already populates ProductBean thanks to CartDAO.getCartItems)
            List<CartBean> userCart = cartDAO.getCartItems(userId);

            // Merge guest cart into user's cart
            for (CartBean guestItem : guestCart) {
                boolean found = false;
                for (CartBean userItem : userCart) {
                    // Compare using productCode (which maps to ProductBean.code)
                    if (userItem.getProductCode() == guestItem.getProductCode()) {
                        // Product already in user's cart, update quantity
                        userItem.setQuantity(userItem.getQuantity() + guestItem.getQuantity());
                        // Corrected method name: updateQuantity
                        cartDAO.updateQuantity(userId, userItem.getProductCode(), userItem.getQuantity());
                        found = true;
                        break;
                    }
                }
                if (!found) {
                    // Product not in user's cart, add it
                    // Corrected method name: addToCart
                    cartDAO.addToCart(userId, guestItem.getProductCode(), guestItem.getQuantity());
                    // The CartDAO.addToCart method with ON DUPLICATE KEY UPDATE handles the merge directly.
                    // For the response, we still need the ProductBean details for this new item.
                    // We can either fetch it now or rely on the final re-fetch.
                    // Given the final re-fetch, this specific product enrichment for guestItem isn't strictly necessary for the *final* response.
                    // However, keeping it in the `userCart.add(guestItem)` is fine for the temporary list.
                    // For robustness and simplicity, we will re-fetch the entire cart at the end.
                }
            }

            // After merging, refresh the user's cart from the database to ensure consistency.
            // CartDAO.getCartItems already performs the JOIN and populates ProductBean.
            userCart = cartDAO.getCartItems(userId);


            // Respond with the updated user cart
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write(buildCartJson(userCart));

        } catch (SQLException e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"error\":\"Database error during cart merge: " + escapeJson(e.getMessage()) + "\"}");
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"error\":\"Error processing guest cart data: " + escapeJson(e.getMessage()) + "\"}");
        }
    }

    /**
     * Parses a JSON string representing a list of guest cart items into a List of CartBean objects.
     * This is a simplified manual parser. For production, consider using a JSON library like Gson or Jackson.
     *
     * Expected JSON format:
     * [{"productCode":123,"quantity":1,"product":{"id":123,"name":"Product A","price":10.00}}, ...]
     */
    private List<CartBean> parseJsonToCartList(String json) throws Exception {
        List<CartBean> cartItems = new ArrayList<>();
        if (json == null || json.trim().isEmpty() || !json.startsWith("[") || !json.endsWith("]")) {
            return cartItems; // Return empty list for invalid or empty JSON
        }

        // Remove outer brackets and split by object
        String content = json.substring(1, json.length() - 1);
        // This regex split is more robust for splitting JSON objects, but still basic.
        // It splits by "}," but ensures it's not inside a string.
        String[] itemStrings = content.split("(?<=}),");

        for (String itemString : itemStrings) {
            if (itemString.trim().isEmpty()) continue;

            // Manual adjustment for the last item in the array if it doesn't end with "}"
            if (!itemString.trim().endsWith("}")) {
                itemString = itemString.trim() + "}";
            }

            // Extract productCode
            int productCodeStart = itemString.indexOf("\"productCode\":") + "\"productCode\":".length();
            int productCodeEnd = itemString.indexOf(",", productCodeStart);
            if (productCodeEnd == -1) productCodeEnd = itemString.indexOf("}", productCodeStart); // Fallback for single-field objects

            if (productCodeStart == -1 || productCodeEnd == -1) {
                throw new Exception("Invalid JSON format: missing productCode in item: " + itemString);
            }
            int productCode = Integer.parseInt(itemString.substring(productCodeStart, productCodeEnd).trim());

            // Extract quantity
            int quantityStart = itemString.indexOf("\"quantity\":", productCodeEnd) + "\"quantity\":".length();
            int quantityEnd = itemString.indexOf(",", quantityStart);
            if (quantityEnd == -1) quantityEnd = itemString.indexOf("}", quantityStart);

            if (quantityStart == -1 || quantityEnd == -1) {
                throw new Exception("Invalid JSON format: missing quantity in item: " + itemString);
            }
            int quantity = Integer.parseInt(itemString.substring(quantityStart, quantityEnd).trim());

            CartBean cartBean = new CartBean();
            cartBean.setProductCode(productCode);
            cartBean.setQuantity(quantity);

            // Attempt to parse product details if present (for guest cart display logic)
            // It's still a good idea to parse these if the client sends them,
            // even if the server will re-fetch the authoritative data.
            int productStart = itemString.indexOf("\"product\":");
            if (productStart != -1) {
                int productObjStart = itemString.indexOf("{", productStart);
                int productObjEnd = findClosingBrace(itemString, productObjStart); // Use a helper to find correct closing brace

                if (productObjStart != -1 && productObjEnd != -1 && productObjEnd > productObjStart) {
                    String productObjString = itemString.substring(productObjStart, productObjEnd + 1);

                    String nameKey = "\"name\":\"";
                    int nameStart = productObjString.indexOf(nameKey);
                    String productName = null;
                    if (nameStart != -1) {
                        nameStart += nameKey.length();
                        int nameEnd = productObjString.indexOf("\"", nameStart);
                        if (nameEnd != -1) {
                            productName = productObjString.substring(nameStart, nameEnd);
                        }
                    }

                    String priceKey = "\"price\":";
                    int priceStart = productObjString.indexOf(priceKey);
                    double productPrice = 0.0;
                    if (priceStart != -1) {
                        priceStart += priceKey.length();
                        int priceEnd = productObjString.indexOf(",", priceStart);
                        if (priceEnd == -1) priceEnd = productObjString.indexOf("}", priceStart);
                        if (priceEnd != -1) {
                            productPrice = Double.parseDouble(productObjString.substring(priceStart, priceEnd));
                        }
                    }

                    ProductBean productBean = new ProductBean();
                    productBean.setCode(productCode); // Set the code of the ProductBean
                    productBean.setName(productName);
                    productBean.setPrice(productPrice);
                    // Add other product fields if necessary and parsed from JSON
                    cartBean.setProduct(productBean);
                }
            }
            cartItems.add(cartBean);
        }
        return cartItems;
    }

    /**
     * Helper method to find the matching closing brace for a given opening brace.
     * This is a basic implementation and might not handle all complex JSON scenarios (e.g., escaped braces).
     */
    private int findClosingBrace(String json, int openBraceIndex) {
        int balance = 0;
        for (int i = openBraceIndex; i < json.length(); i++) {
            char c = json.charAt(i);
            if (c == '{') {
                balance++;
            } else if (c == '}') {
                balance--;
            }
            if (balance == 0 && i > openBraceIndex) {
                return i;
            }
        }
        return -1; // No matching closing brace found
    }


    /**
     * Builds a JSON string from a list of CartBean objects.
     * This is a simplified manual builder. For production, consider using a JSON library.
     */
    private String buildCartJson(List<CartBean> cartItems) {
        StringBuilder json = new StringBuilder("[");
        for (int i = 0; i < cartItems.size(); i++) {
            CartBean item = cartItems.get(i);
            ProductBean p = item.getProduct();
            if (p == null) continue; // Skip if product details are missing

            json.append("{");
            json.append("\"productCode\":").append(item.getProductCode()).append(",");
            json.append("\"quantity\":").append(item.getQuantity()).append(",");
            json.append("\"product\":{");
            json.append("\"id\":").append(p.getCode()).append(","); // ⭐ Using p.getCode() here ⭐
            json.append("\"name\":\"").append(escapeJson(p.getName())).append("\",");
            json.append("\"price\":").append(p.getPrice());
            // Add other product fields if available in ProductBean
            if (p.getImage() != null) {
                json.append(",\"image\":\"").append(escapeJson(p.getImage())).append("\"");
            }
            // Using getQuantity() from ProductBean as stockQuantity
            if (p.getQuantity() > 0) { // Assuming getQuantity() on ProductBean represents stock
                 json.append(",\"stockQuantity\":").append(p.getQuantity());
            }
            if (p.getCategory() != null) {
                json.append(",\"category\":\"").append(escapeJson(p.getCategory())).append("\"");
            }
            json.append("}}");

            if (i < cartItems.size() - 1) json.append(",");
        }
        json.append("]");
        return json.toString();
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r");
    }
}