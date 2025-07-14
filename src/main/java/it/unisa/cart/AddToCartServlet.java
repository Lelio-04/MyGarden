package it.unisa.cart;

import jakarta.servlet.http.HttpServletResponse;
import it.unisa.db.ProductBean;
import it.unisa.db.ProductDaoDataSource;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import javax.sql.DataSource;
import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/AddToCartServlet")
public class AddToCartServlet extends HttpServlet {

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
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(true);
        Integer userId = (Integer) session.getAttribute("userId");

        try {
            int productCode = Integer.parseInt(request.getParameter("productCode"));
            int quantityToAdd = Integer.parseInt(request.getParameter("quantity"));

            // Recupera prodotto per quantità massima disponibile
            ProductBean product = productDAO.doRetrieveByKey(productCode);
            if (product == null) {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                response.getWriter().write("{\"error\": \"Prodotto non trovato\"}");
                return;
            }
            int maxAvailable = product.getQuantity();

            // Recupera quantità già presente nel carrello per questo prodotto
            int currentQuantityInCart = 0;

            if (userId != null) {
                // Utente loggato, prendi quantità dal DB
                List<CartBean> cartItems = cartDAO.getCartItems(userId);
                for (CartBean item : cartItems) {
                    if (item.getProductCode() == productCode) {
                        currentQuantityInCart = item.getQuantity();
                        break;
                    }
                }

                int newTotal = currentQuantityInCart + quantityToAdd;
                if (newTotal > maxAvailable) {
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    response.getWriter().write("{\"error\": \"Quantità massima disponibile superata\"}");
                    return;
                }

                // Aggiungi solo se valido
                cartDAO.addToCart(userId, productCode, quantityToAdd);

            } else {
                // Utente guest: gestisci sessione
                @SuppressWarnings("unchecked")
                List<CartBean> guestCart = (List<CartBean>) session.getAttribute("guestCart");
                if (guestCart == null) guestCart = new ArrayList<>();

                for (CartBean item : guestCart) {
                    if (item.getProductCode() == productCode) {
                        currentQuantityInCart = item.getQuantity();
                        break;
                    }
                }

                int newTotal = currentQuantityInCart + quantityToAdd;
                if (newTotal > maxAvailable) {
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    response.getWriter().write("{\"error\": \"Quantità massima disponibile superata\"}");
                    return;
                }

                // Aggiungi o aggiorna nel carrello guest
                boolean found = false;
                for (CartBean item : guestCart) {
                    if (item.getProductCode() == productCode) {
                        item.setQuantity(newTotal);
                        found = true;
                        break;
                    }
                }

                if (!found) {
                    CartBean item = new CartBean();
                    item.setProductCode(productCode);
                    item.setQuantity(quantityToAdd);
                    item.setProduct(product);
                    guestCart.add(item);
                }
                session.setAttribute("guestCart", guestCart);
            }

        } catch (NumberFormatException | SQLException e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"error\": \"Parametro errato o errore DB\"}");
            return;
        }

        // Preparazione della risposta JSON
        List<CartBean> cartItems = new ArrayList<>();
        if (userId != null) {
            try {
                cartItems = cartDAO.getCartItems(userId);
                for (CartBean item : cartItems) {
                    ProductBean p = productDAO.doRetrieveByKey(item.getProductCode());
                    if (p == null) continue;
                    item.setProduct(p);
                }
            } catch (SQLException e) {
                e.printStackTrace();
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                response.getWriter().write("{\"error\": \"Errore DB\"}");
                return;
            }
        } else {
            @SuppressWarnings("unchecked")
            List<CartBean> guestCart = (List<CartBean>) session.getAttribute("guestCart");
            if (guestCart != null) {
                cartItems = guestCart;
            }
        }

        // Costruzione manuale del JSON per il carrello aggiornato
        StringBuilder json = new StringBuilder();
        json.append("[");

        for (int i = 0; i < cartItems.size(); i++) {
            CartBean item = cartItems.get(i);
            ProductBean p = item.getProduct();
            if (p == null) continue;

            json.append("{");
            json.append("\"productCode\":").append(item.getProductCode()).append(",");
            json.append("\"quantity\":").append(item.getQuantity()).append(",");
            json.append("\"product\":{");
            json.append("\"name\":\"").append(escapeJson(p.getName())).append("\",");
            json.append("\"price\":").append(p.getPrice()).append(",");
            json.append("\"image\":\"").append(escapeJson(p.getImage())).append("\"");
            json.append("}}");

            if (i < cartItems.size() - 1) json.append(",");
        }

        json.append("]");

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.getWriter().write(json.toString());
    }


    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\"", "\\\"").replace("\n", "").replace("\r", "");
    }
}
