package it.unisa.order;

import it.unisa.cart.CartBean;
import it.unisa.cart.CartDAO;
import it.unisa.register.User;
import it.unisa.register.UserDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import javax.naming.Context;
import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.sql.DataSource;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

@WebServlet("/checkout-page")
public class CheckoutPageServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private DataSource dataSource;

    @Override
    public void init() throws ServletException {
        try {
            // Recupera il DataSource JNDI
        	Context initContext = new InitialContext();
        	Context envContext = (Context) initContext.lookup("java:comp/env");
        	dataSource = (DataSource) envContext.lookup("jdbc/storage");  // usa il nome JNDI corretto

        } catch (NamingException e) {
            throw new ServletException("Errore nel recupero del DataSource", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        Integer userId = (Integer) session.getAttribute("userId");

        try {
            // ✅ Recupera info utente
            UserDAO userDAO = new UserDAO(dataSource);
            User user = userDAO.getUserById(userId);

            // ✅ Recupera carrello
            CartDAO cartDAO = new CartDAO(dataSource);
            List<CartBean> cartItems = cartDAO.getCartItems(userId);

            request.setAttribute("user", user);
            request.setAttribute("cartItems", cartItems);

            // ✅ Vai alla pagina checkout.jsp
            request.getRequestDispatcher("checkout.jsp").forward(request, response);

        } catch (SQLException e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Errore nel caricamento dati utente/carrello.");
        }
    }
}
