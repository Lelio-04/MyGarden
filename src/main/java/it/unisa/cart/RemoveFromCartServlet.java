package it.unisa.cart;

import it.unisa.db.DriverManagerConnectionPool;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/remove-from-cart")
public class RemoveFromCartServlet extends HttpServlet {

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

        String productCodeParam = request.getParameter("productCode");
        if (productCodeParam == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Codice prodotto mancante.");
            return;
        }

        try {
            int productCode = Integer.parseInt(productCodeParam);
            cartDAO.removeItem(userId, productCode);
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Codice prodotto non valido.");
        } catch (SQLException e) {
            throw new ServletException("Errore nella rimozione dal carrello", e);
        }

        response.sendRedirect("cart");
    }
}
