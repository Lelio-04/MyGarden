package it.unisa.cart;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import javax.sql.DataSource;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.util.List;
import java.util.Map;

@WebServlet("/update-cart")
public class UpdateCartServlet extends HttpServlet {

    private ICartDao cartDao;

    @Override
    public void init() throws ServletException {
        DataSource ds = (DataSource) getServletContext().getAttribute("DataSourceStorage");
        if (ds == null) {
            throw new ServletException("DataSource non disponibile nel contesto.");
        }
        cartDao = new CartDAODataSource(ds);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        PrintWriter out = response.getWriter();

        HttpSession session = request.getSession(true);
        Integer userId = (Integer) session.getAttribute("userId");

        try {
            if (userId != null) {
                for (Map.Entry<String, String[]> entry : request.getParameterMap().entrySet()) {
                    String key = entry.getKey();
                    if (key.startsWith("quantities[")) {
                        String productCodeStr = key.substring("quantities[".length(), key.length() - 1);
                        int productCode = Integer.parseInt(productCodeStr);
                        int quantity = Integer.parseInt(entry.getValue()[0]);

                        if (quantity <= 0) {
                            cartDao.removeItem(userId, productCode);
                        } else {
                            cartDao.updateQuantity(userId, productCode, quantity);
                        }
                    }
                }
            } else {
                @SuppressWarnings("unchecked")
                List<CartBean> guestCart = (List<CartBean>) session.getAttribute("guestCart");

                if (guestCart != null) {
                    for (Map.Entry<String, String[]> entry : request.getParameterMap().entrySet()) {
                        String key = entry.getKey();
                        if (key.startsWith("quantities[")) {
                            String productCodeStr = key.substring("quantities[".length(), key.length() - 1);
                            int productCode = Integer.parseInt(productCodeStr);
                            int quantity = Integer.parseInt(entry.getValue()[0]);

                            CartBean itemToUpdate = null;
                            for (CartBean item : guestCart) {
                                if (item.getProductCode() == productCode) {
                                    itemToUpdate = item;
                                    break;
                                }
                            }
                            if (itemToUpdate != null) {
                                if (quantity <= 0) {
                                    guestCart.remove(itemToUpdate);
                                } else {
                                    itemToUpdate.setQuantity(quantity);
                                }
                            }
                        }
                    }
                    session.setAttribute("guestCart", guestCart);
                }
            }

            // Successo
            out.print("{\"success\":true}");
        } catch (SQLException | NumberFormatException e) {
            // Errore - risposta JSON con messaggio
            String errorMsg = e.getMessage() != null ? e.getMessage().replace("\"", "\\\"") : "Errore sconosciuto";
            out.print("{\"success\":false,\"error\":\"" + errorMsg + "\"}");
        }

        out.flush();
    }
}
