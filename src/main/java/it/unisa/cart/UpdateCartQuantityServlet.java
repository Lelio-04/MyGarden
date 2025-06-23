package it.unisa.cart;

import it.unisa.db.DriverManagerConnectionPool;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/update-cart-quantity")
public class UpdateCartQuantityServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private transient CartDAODriverManager cartDAO;

    @Override
    public void init() throws ServletException {
        cartDAO = new CartDAODriverManager(new DriverManagerConnectionPool());
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        Integer userId = (session != null) ? (Integer) session.getAttribute("userId") : null;

        if (userId == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        try {
            int productCode = Integer.parseInt(request.getParameter("productCode"));
            int quantity = Integer.parseInt(request.getParameter("quantity"));

            if (quantity <= 0) {
                cartDAO.removeItem(userId, productCode); // Rimuove se quantità è 0 o meno
            } else {
                cartDAO.updateQuantity(userId, productCode, quantity);
            }

        } catch (NumberFormatException | SQLException e) {
            e.printStackTrace();
        }

        response.sendRedirect("cart");
    }
}
