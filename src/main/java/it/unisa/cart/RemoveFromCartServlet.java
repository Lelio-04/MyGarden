package it.unisa.cart;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import javax.sql.DataSource;

import it.unisa.db.ProductBean;
import it.unisa.db.ProductDaoDataSource;

import java.io.IOException;
import java.sql.SQLException;
import java.util.Iterator;
import java.util.List;

@WebServlet("/remove-from-cart")
public class RemoveFromCartServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private transient CartDAO cartDAO;
    private transient ProductDaoDataSource productDAO;

    @Override
    public void init() throws ServletException {
        DataSource dataSource = (DataSource) getServletContext().getAttribute("DataSourceStorage");
        if (dataSource == null) {
            throw new ServletException("DataSource non trovato nel contesto");
        }
        cartDAO = new CartDAO(dataSource);
        productDAO = new ProductDaoDataSource(dataSource);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(true);
        Integer userId = (Integer) session.getAttribute("userId");
        String productCodeParam = request.getParameter("productCode");

        if (productCodeParam == null) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"status\":\"error\", \"message\":\"Codice prodotto mancante.\"}");
            return;
        }

        try {
            int productCode = Integer.parseInt(productCodeParam);

            boolean removed = false;

            if (userId != null) {
                cartDAO.removeItem(userId, productCode);
                removed = true;
            } else {
                @SuppressWarnings("unchecked")
                List<CartBean> guestCart = (List<CartBean>) session.getAttribute("guestCart");

                if (guestCart != null) {
                    Iterator<CartBean> iterator = guestCart.iterator();
                    while (iterator.hasNext()) {
                        CartBean item = iterator.next();
                        if (item.getProductCode() == productCode) {
                            iterator.remove();
                            removed = true;
                            break;
                        }
                    }
                    if (removed) {
                        session.setAttribute("guestCart", guestCart);
                    }
                }
            }

            if (!removed) {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                response.getWriter().write("{\"status\":\"error\", \"message\":\"Prodotto non trovato nel carrello.\"}");
                return;
            }

            // Costruisci JSON carrello aggiornato
            List<CartBean> cartItems;
            if (userId != null) {
                cartItems = cartDAO.getCartItems(userId);
            } else {
                @SuppressWarnings("unchecked")
                List<CartBean> guestCart = (List<CartBean>) session.getAttribute("guestCart");
                cartItems = (guestCart != null) ? guestCart : List.of();
            }

            for (CartBean item : cartItems) {
                ProductBean p = productDAO.doRetrieveByKey(item.getProductCode());
                item.setProduct(p);
            }

            StringBuilder json = new StringBuilder("[");
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
                json.append("\"image\":\"").append(escapeJson(p.getImage())).append("\",");
                json.append("\"quantity\":").append(p.getQuantity());
                json.append("}}");

                if (i < cartItems.size() - 1) json.append(",");
            }
            json.append("]");

            response.getWriter().write(json.toString());

        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"status\":\"error\", \"message\":\"Codice prodotto non valido.\"}");
        } catch (SQLException e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"status\":\"error\", \"message\":\"Errore durante la rimozione dal carrello.\"}");
            e.printStackTrace();
        }
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\"", "\\\"").replace("\n", "").replace("\r", "");
    }
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setStatus(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
        response.getWriter().write("{\"error\":\"Metodo GET non supportato. Usa POST.\"}");
    }
}
