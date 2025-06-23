package it.unisa.cart;

import it.unisa.db.DriverManagerConnectionPool;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

@WebServlet("/AddToCart")
public class CartServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final DriverManagerConnectionPool pool = new DriverManagerConnectionPool();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String userIdStr = request.getParameter("userId");
        String productCodeStr = request.getParameter("productCode");
        String quantityStr = request.getParameter("quantity");

        if (userIdStr == null || productCodeStr == null || quantityStr == null) {
            response.sendRedirect("errore.jsp");
            return;
        }

        try {
            int userId = Integer.parseInt(userIdStr);
            int productCode = Integer.parseInt(productCodeStr);
            int quantity = Integer.parseInt(quantityStr);

            CartBean cartItem = new CartBean();
            cartItem.setUserId(userId);
            cartItem.setProductCode(productCode);
            cartItem.setQuantity(quantity);

            addToCart(cartItem);

            response.sendRedirect("carrello.jsp?success=1");

        } catch (NumberFormatException | SQLException e) {
            e.printStackTrace();
            response.sendRedirect("carrello.jsp?error=1");
        }
    }

    private void addToCart(CartBean item) throws SQLException {
        String sql = "INSERT INTO cart_items (user_id, product_code, quantity) VALUES (?, ?, ?)";

        try (Connection con = pool.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, item.getUserId());
            ps.setInt(2, item.getProductCode());
            ps.setInt(3, item.getQuantity());

            ps.executeUpdate();
        }
    }
}
