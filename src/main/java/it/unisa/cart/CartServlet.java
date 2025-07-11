package it.unisa.cart;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import javax.sql.DataSource;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/AddToCart")
public class CartServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private transient DataSource dataSource;

    @Override
    public void init() throws ServletException {
        // Recupera il DataSource dal contesto applicativo
        dataSource = (DataSource) getServletContext().getAttribute("DataSourceStorage");
        if (dataSource == null) {
            throw new ServletException("DataSource non configurato correttamente nel contesto.");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String productCodeStr = request.getParameter("productCode");
        String quantityStr = request.getParameter("quantity");

        if (productCodeStr == null || quantityStr == null) {
            response.sendRedirect("errore.jsp");
            return;
        }

        try {
            int productCode = Integer.parseInt(productCodeStr);
            int quantity = Integer.parseInt(quantityStr);

            HttpSession session = request.getSession();
            Integer userId = (Integer) session.getAttribute("userId");

            CartBean cartItem = new CartBean();
            cartItem.setProductCode(productCode);
            cartItem.setQuantity(quantity);

            if (userId != null) {
                // Utente loggato → salva nel DB
                cartItem.setUserId(userId);
                addToCart(cartItem);
            } else {
                // Utente non loggato → salva nella sessione
                @SuppressWarnings("unchecked")
                List<CartBean> sessionCart = (List<CartBean>) session.getAttribute("guestCart");

                if (sessionCart == null) {
                    sessionCart = new ArrayList<>();
                    session.setAttribute("guestCart", sessionCart);
                }

                // Se il prodotto è già presente, aggiorna la quantità
                boolean found = false;
                for (CartBean item : sessionCart) {
                    if (item.getProductCode() == productCode) {
                        item.setQuantity(item.getQuantity() + quantity);
                        found = true;
                        break;
                    }
                }
                if (!found) {
                    sessionCart.add(cartItem);
                }
            }

            response.sendRedirect("carrello.jsp?success=1");

        } catch (NumberFormatException | SQLException e) {
            e.printStackTrace();
            response.sendRedirect("carrello.jsp?error=1");
        }
    }

    private void addToCart(CartBean item) throws SQLException {
        String sql = "INSERT INTO cart_items (user_id, product_code, quantity) VALUES (?, ?, ?) " +
                     "ON DUPLICATE KEY UPDATE quantity = quantity + VALUES(quantity)";

        try (Connection con = dataSource.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, item.getUserId());
            ps.setInt(2, item.getProductCode());
            ps.setInt(3, item.getQuantity());

            ps.executeUpdate();
        }
    }
}
