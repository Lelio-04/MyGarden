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
        // Recupera il DataSource dal ServletContext
        DataSource dataSource = (DataSource) getServletContext().getAttribute("DataSourceStorage");
        cartDAO = new ICartDao(dataSource);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(true);
        Integer userId = (Integer) session.getAttribute("userId");

        try {
            int productCode = Integer.parseInt(request.getParameter("productCode"));
            int quantity = Integer.parseInt(request.getParameter("quantity"));

            if (userId != null) {
                // 🔐 Utente loggato: aggiorna su DB
                if (quantity <= 0) {
                    cartDAO.removeItem(userId, productCode);
                } else {
                    cartDAO.updateQuantity(userId, productCode, quantity);
                }
            } else {
                // 👤 Utente ospite: aggiorna nella guestCart
                @SuppressWarnings("unchecked")
                List<CartBean> guestCart = (List<CartBean>) session.getAttribute("guestCart");

                if (guestCart != null) {
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
                        session.setAttribute("guestCart", guestCart);
                    }
                }
            }

        } catch (NumberFormatException | SQLException e) {
            e.printStackTrace();
        }

        response.sendRedirect("cart");
    }
}
