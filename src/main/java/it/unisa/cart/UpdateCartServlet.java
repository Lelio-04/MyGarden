package it.unisa.cart;

import it.unisa.db.*;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import javax.sql.DataSource;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.util.*;

@WebServlet("/update-cart")
public class UpdateCartServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private ICartDao cartDao;

    @Override
    public void init() throws ServletException {
        DataSource ds = (DataSource) getServletContext().getAttribute("DataSourceStorage");
        if (ds == null) {
            throw new ServletException("DataSource non disponibile nel contesto.");
        }
        cartDao = new CartDAO(ds);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        System.out.println("Servlet 'update-cart' chiamata");
        response.setContentType("application/json");
        PrintWriter out = response.getWriter();
        HttpSession session = request.getSession(true);
        Integer userId = (Integer) session.getAttribute("userId");

        try {
            StringBuilder jsonRequest = new StringBuilder();
            String line;
            while ((line = request.getReader().readLine()) != null) {
                jsonRequest.append(line);
            }

            System.out.println("Dati carrello ricevuti: " + jsonRequest.toString());

            String requestData = jsonRequest.toString();

            String cartData = requestData.substring(requestData.indexOf("[") + 1, requestData.lastIndexOf("]"));

            List<CartBean> cartItems = parseCartData(cartData);

            if (userId == null) {
                // Utente guest: salva carrello in sessione
                session.setAttribute("guestCart", cartItems);
                System.out.println("Guest cart sostituito in sessione, elementi: " + cartItems.size());
                response.setStatus(HttpServletResponse.SC_OK);
                return;
            } else {
                // Utente loggato: aggiorna carrello nel DB
                updateUserCartInDb(userId, cartItems, out);
                System.out.println("Carrello aggiornato con successo per userId: " + userId);
            }

            out.print("{\"success\":true}");

        } catch (Exception e) {
            String errorMsg = e.getMessage() != null ? e.getMessage().replace("\"", "\\\"") : "Errore sconosciuto";
            out.print("{\"success\":false,\"error\":\"" + errorMsg + "\"}");
        } finally {
            out.flush();
            out.close();
        }
    }

    private List<CartBean> parseCartData(String jsonData) throws SQLException {
        List<CartBean> cartItems = new ArrayList<>();

        String[] itemDataArray = jsonData.split("},\\{");

        for (String itemData : itemDataArray) {
            itemData = itemData.trim();
            if (itemData.startsWith("{")) itemData = itemData.substring(1);
            if (itemData.endsWith("}")) itemData = itemData.substring(0, itemData.length() - 1);

            String[] fields = itemData.split(",");
            String id = null;
            int quantity = 0;

            for (String field : fields) {
                String[] keyValue = field.split(":");
                if (keyValue.length == 2) {
                    String key = keyValue[0].trim().replaceAll("\"", "");
                    String value = keyValue[1].trim().replaceAll("\"", "");

                    switch (key) {
                        case "productCode":
                            id = value;
                            break;
                        case "quantity":
                            quantity = Integer.parseInt(value);
                            break;
                    }
                }
            }

            if (id != null) {
                int productCode = Integer.parseInt(id);
                ProductBean product = cartDao.getProductDetails(productCode); // recupera da DB
                if (product != null) {
                    CartBean cartItem = new CartBean(productCode, quantity, product);
                    cartItems.add(cartItem);
                    System.out.println("Dati carrello parsati da DB: id=" + productCode + ", quantity=" + quantity +
                                       ", name=" + product.getName() + ", price=" + product.getPrice());
                } else {
                    System.out.println("Prodotto non trovato nel DB: productCode=" + productCode);
                }
            }
        }

        return cartItems;
    }

    private void updateUserCartInDb(Integer userId, List<CartBean> cartItems, PrintWriter out) throws SQLException {
        //Svuota carrello utente
        cartDao.clearCart(userId);

        for (CartBean cartItem : cartItems) {
            int productCode = cartItem.getProductCode();
            int requestedQty = cartItem.getQuantity();

            ProductBean product = cartDao.getProductDetails(productCode);
            if (product == null || product.isDeleted()) {
                out.print("{\"success\":false, \"error\":\"Prodotto non disponibile o eliminato.\"}");
                return;
            }

            int finalQty = Math.min(requestedQty, product.getQuantity());

            if (finalQty <= 0) continue;

            boolean success = cartDao.insertToCart(userId, productCode, finalQty);
            if (!success) {
                out.print("{\"success\":false, \"error\":\"Errore inserimento prodotto nel carrello.\"}");
                return;
            }
        }
    }

}
