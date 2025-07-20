package it.unisa.cart;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import it.unisa.db.ProductBean;
import it.unisa.db.ProductDaoDataSource;

import javax.sql.DataSource;
import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

@WebServlet("/update-cart-quantity")
public class UpdateCartQuantityServlet extends HttpServlet {

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

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(true);
        Integer userId = (Integer) session.getAttribute("userId");

        String[] productCodes = request.getParameterValues("productCode");
        String[] quantities = request.getParameterValues("quantity");

        if (productCodes == null) {
            String singleCode = request.getParameter("productCode");
            if (singleCode != null) {
                productCodes = new String[]{singleCode};
            }
        }
        if (quantities == null) {
            String singleQty = request.getParameter("quantity");
            if (singleQty != null) {
                quantities = new String[]{singleQty};
            }
        }

        if (productCodes == null || quantities == null || productCodes.length != quantities.length) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"status\":\"error\", \"message\":\"Parametri mancanti o incoerenti\"}");
            return;
        }

        try {
            for (int i = 0; i < productCodes.length; i++) {
                int code = Integer.parseInt(productCodes[i]);
                int qty = Integer.parseInt(quantities[i]);

                if (qty < 0) {
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    response.getWriter().write("{\"status\":\"error\", \"message\":\"Quantità non può essere negativa\"}");
                    return;
                }

                ProductBean product = productDAO.doRetrieveByKey(code);
                if (product == null) {
                    response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                    response.getWriter().write("{\"status\":\"error\", \"message\":\"Prodotto con codice " + code + " non trovato\"}");
                    return;
                }

                int maxAvailable = product.getQuantity();
                if (qty > maxAvailable) {
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    response.getWriter().write("{\"status\":\"error\", \"message\":\"Quantità massima disponibile per il prodotto " + code + " è " + maxAvailable + "\"}");
                    return;
                }
            }

            //Aggiornamento carrello
            if (userId != null) {
                for (int i = 0; i < productCodes.length; i++) {
                    int code = Integer.parseInt(productCodes[i]);
                    int qty = Integer.parseInt(quantities[i]);

                    if (qty == 0) {
                        cartDAO.removeItem(userId, code);
                    } else {
                        cartDAO.updateQuantity(userId, code, qty);
                    }
                }
            } else {
                @SuppressWarnings("unchecked")
                List<CartBean> guestCart = (List<CartBean>) session.getAttribute("guestCart");

                if (guestCart != null) {
                    for (int i = 0; i < productCodes.length; i++) {
                        int code = Integer.parseInt(productCodes[i]);
                        int qty = Integer.parseInt(quantities[i]);

                        Iterator<CartBean> it = guestCart.iterator();
                        while (it.hasNext()) {
                            CartBean item = it.next();
                            if (Integer.valueOf(code).equals(item.getProductCode())) {
                                if (qty == 0) {
                                    it.remove();
                                } else {
                                    item.setQuantity(qty);
                                }
                                break;
                            }
                        }
                    }
                    session.setAttribute("guestCart", guestCart);
                }
            }

            List<CartBean> cartItems = new ArrayList<>();
            if (userId != null) {
                cartItems = cartDAO.getCartItems(userId);
            } else {
                @SuppressWarnings("unchecked")
                List<CartBean> guestCart = (List<CartBean>) session.getAttribute("guestCart");
                if (guestCart != null) {
                    cartItems = guestCart;
                }
            }

            for (CartBean item : cartItems) {
                ProductBean product = productDAO.doRetrieveByKey(item.getProductCode());
                item.setProduct(product);
            }

            StringBuilder json = new StringBuilder("{\"status\":\"success\", \"cart\":[");
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
            json.append("]}");
            response.setStatus(HttpServletResponse.SC_OK);
            response.getWriter().write(json.toString());

        } catch (NumberFormatException | SQLException e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            String msg = e.getMessage() != null ? e.getMessage().replace("\"", "\\\"").replace("\n", "").replace("\r", "") : "Errore interno";
            response.getWriter().write("{\"status\":\"error\", \"message\":\"" + msg + "\"}");
        }
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\"", "\\\"").replace("\n", "").replace("\r", "");
    }
}
