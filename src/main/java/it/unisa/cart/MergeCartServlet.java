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
    private transient ProductDaoDataSource productDAO;

    @Override
    public void init() throws ServletException {
        DataSource dataSource = (DataSource) getServletContext().getAttribute("DataSourceStorage");
        cartDAO = new CartDAO(dataSource);
        productDAO = new ProductDaoDataSource(dataSource);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("{\"error\":\"No active session.\"}");
            return;
        }

        Integer userId = (Integer) session.getAttribute("userId");
        System.out.println("DEBUG MERGE SERVLET: doPost called at " + System.currentTimeMillis());

        if (userId == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("{\"error\":\"User not logged in.\"}");
            return;
        }

        // 🔐 BLOCCO SINCRONIZZATO SULLA SESSIONE
        long now = System.currentTimeMillis();
        synchronized (session) {
            Long lastMerge = (Long) session.getAttribute("lastMergeTime");
            if (lastMerge != null && (now - lastMerge < 2000)) {
                System.out.println("⛔ Merge già eseguito troppo recentemente (" + (now - lastMerge) + " ms fa)");
                response.setStatus(HttpServletResponse.SC_CONFLICT);
                response.getWriter().write("{\"error\":\"Merge già eseguito.\"}");
                return;
            }

            // ✅ Imposta subito il flag di merge per bloccare altre richieste concorrenti
            session.setAttribute("lastMergeTime", now);
        }

        // 🔁 Continua con il parsing e il merge effettivo
        StringBuilder sb = new StringBuilder();
        try (BufferedReader reader = new BufferedReader(new InputStreamReader(request.getInputStream()))) {
            String line;
            while ((line = reader.readLine()) != null) {
                sb.append(line);
            }
        }
        String jsonPayload = sb.toString();

        List<CartBean> guestCart;
        try {
            guestCart = parseJsonToCartList(jsonPayload);
        } catch (Exception e) {
            System.err.println("Error parsing guest cart JSON: " + e.getMessage());
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"error\":\"Invalid guest cart data\"}");
            return;
        }

        try {
            System.out.println("DEBUG MERGE SERVLET: Starting merge for userId: " + userId);

            for (CartBean guestItem : guestCart) {
                int productCode = guestItem.getProductCode();
                int guestQuantity = guestItem.getQuantity();
                System.out.println("DEBUG MERGE SERVLET: Adding productCode " + productCode + " with quantity " + guestQuantity);
                cartDAO.addToCart(userId, productCode, guestQuantity);
            }

            List<CartBean> updatedCart = cartDAO.getCartItems(userId);

            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write(buildCartJson(updatedCart));

        } catch (SQLException e) {
            System.err.println("Database error during cart merge: " + e.getMessage());
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"error\":\"Database error during cart merge\"}");
        } catch (Exception e) {
            System.err.println("Unexpected error during cart merge: " + e.getMessage());
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"error\":\"Unexpected error during cart merge\"}");
        }
    }


    /**
     * Parses a JSON string representing a list of guest cart items into a List of CartBean objects.
     * This is a simplified manual parser. For production, consider using a JSON library like Gson or Jackson.
     *
     * Expected JSON format:
     * [{"productCode":123,"quantity":1,"product":{"id":123,"name":"Product A","price":10.00}}, ...]
     */

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
    private List<CartBean> parseJsonToCartList(String json) throws Exception {
        List<CartBean> cartItems = new ArrayList<>();
        if (json == null || json.trim().isEmpty() || !json.startsWith("[") || !json.endsWith("]")) {
            return cartItems; // Return empty list for invalid or empty JSON
        }

        // Remove outer brackets and split by object
        String content = json.substring(1, json.length() - 1);
        String[] itemStrings = content.split("(?<=}),");

        for (String itemString : itemStrings) {
            if (itemString.trim().isEmpty()) continue;

            if (!itemString.trim().endsWith("}")) {
                itemString = itemString.trim() + "}";
            }

            // Extract productCode as raw string
            int productCodeStart = itemString.indexOf("\"productCode\":") + "\"productCode\":".length();
            int productCodeEnd = itemString.indexOf(",", productCodeStart);
            if (productCodeEnd == -1) productCodeEnd = itemString.indexOf("}", productCodeStart);

            if (productCodeStart == -1 || productCodeEnd == -1) {
                throw new Exception("Invalid JSON format: missing productCode in item: " + itemString);
            }
            String rawProductCode = itemString.substring(productCodeStart, productCodeEnd).trim();
            int productCode = parseIntFromString(rawProductCode);

            // Extract quantity as raw string
            int quantityStart = itemString.indexOf("\"quantity\":", productCodeEnd) + "\"quantity\":".length();
            int quantityEnd = itemString.indexOf(",", quantityStart);
            if (quantityEnd == -1) quantityEnd = itemString.indexOf("}", quantityStart);

            if (quantityStart == -1 || quantityEnd == -1) {
                throw new Exception("Invalid JSON format: missing quantity in item: " + itemString);
            }
            String rawQuantity = itemString.substring(quantityStart, quantityEnd).trim();
            int quantity = parseIntFromString(rawQuantity);

            CartBean cartBean = new CartBean();
            cartBean.setProductCode(productCode);
            cartBean.setQuantity(quantity);

            // Parse product details if present
            int productStart = itemString.indexOf("\"product\":");
            if (productStart != -1) {
                int productObjStart = itemString.indexOf("{", productStart);
                int productObjEnd = findClosingBrace(itemString, productObjStart);

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
                    productBean.setCode(productCode);
                    productBean.setName(productName);
                    productBean.setPrice(productPrice);
                    cartBean.setProduct(productBean);
                }
            }
            cartItems.add(cartBean);
        }
        return cartItems;
    }

    /**
     * Helper method to parse an int from a string that may be wrapped in quotes.
     */
    private int parseIntFromString(String s) throws NumberFormatException {
        s = s.trim();
        if (s.startsWith("\"") && s.endsWith("\"")) {
            s = s.substring(1, s.length() - 1);
        }
        return Integer.parseInt(s);
    }
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED, "GET non supportato su MergeCartServlet");
    }

}