package it.unisa.cart;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import javax.sql.DataSource;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

@WebServlet("/update-cart-quantity")
public class UpdateCartQuantityServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private transient CartDAO cartDAO;

    @Override
    public void init() throws ServletException {
        DataSource dataSource = (DataSource) getServletContext().getAttribute("DataSourceStorage");
        if (dataSource == null) {
            throw new ServletException("DataSource non trovato nel contesto");
        }
        cartDAO = new CartDAO(dataSource);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(true);
        Integer userId = (Integer) session.getAttribute("userId");

        String[] productCodes = request.getParameterValues("productCode");
        String[] quantities = request.getParameterValues("quantity");

        if (productCodes == null || quantities == null || productCodes.length != quantities.length) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"status\":\"error\", \"message\":\"Parametri mancanti o incoerenti\"}");
            return;
        }

        try {
            if (userId != null) {
                // Utente loggato: aggiorna nel DB
                for (int i = 0; i < productCodes.length; i++) {
                    int code = Integer.parseInt(productCodes[i]);
                    int qty = Integer.parseInt(quantities[i]);
                    if (qty <= 0) {
                        cartDAO.removeItem(userId, code);
                    } else {
                        cartDAO.updateQuantity(userId, code, qty);
                    }
                }
            } else {
                // Utente guest: aggiorna nella guestCart in sessione
                @SuppressWarnings("unchecked")
                List<CartBean> guestCart = (List<CartBean>) session.getAttribute("guestCart");

                if (guestCart != null) {
                    for (int i = 0; i < productCodes.length; i++) {
                        int code = Integer.parseInt(productCodes[i]);
                        int qty = Integer.parseInt(quantities[i]);

                        CartBean itemToUpdate = null;
                        for (CartBean item : guestCart) {
                            if (Integer.valueOf(code).equals(item.getProductCode())) {
                                itemToUpdate = item;
                                break;
                            }
                        }

                        if (itemToUpdate != null) {
                            if (qty <= 0) {
                                guestCart.remove(itemToUpdate);
                            } else {
                                itemToUpdate.setQuantity(qty);
                            }
                        }
                    }
                    session.setAttribute("guestCart", guestCart);
                }
            }
            response.getWriter().write("{\"status\":\"success\"}");
        } catch (NumberFormatException | SQLException e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"status\":\"error\", \"message\":\"" + e.getMessage() + "\"}");
        }
    }

}
