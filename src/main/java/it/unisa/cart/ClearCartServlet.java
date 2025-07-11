package it.unisa.cart;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import javax.sql.DataSource;
import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/clear-cart")
public class ClearCartServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private transient CartDAO cartDAO;

    @Override
    public void init() throws ServletException {
        // 🔧 Recupera DataSource dal ServletContext
        DataSource dataSource = (DataSource) getServletContext().getAttribute("DataSourceStorage");
        this.cartDAO = new CartDAO(dataSource);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(true);
        Integer userId = (Integer) session.getAttribute("userId");

        try {
            if (userId != null) {
                // 🔐 Utente loggato: svuota carrello da DB
                cartDAO.clearCart(userId);
            } else {
                // 👤 Utente non loggato: svuota guestCart in sessione
                session.removeAttribute("guestCart");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        response.sendRedirect("cart");
    }
}
