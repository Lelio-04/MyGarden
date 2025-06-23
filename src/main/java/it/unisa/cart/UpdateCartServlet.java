package it.unisa.cart;

import it.unisa.db.DriverManagerConnectionPool;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.SQLException;
import java.util.Map;

@WebServlet("/update-cart")
public class UpdateCartServlet extends HttpServlet {

    private final DriverManagerConnectionPool pool = new DriverManagerConnectionPool();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        Integer userId = (Integer) session.getAttribute("userId");

        if (userId == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        ICartDao cartDao = new CartDAODriverManager(pool);

        try {
            // Scorri tutti i parametri
            for (Map.Entry<String, String[]> entry : request.getParameterMap().entrySet()) {
                String key = entry.getKey(); // tipo: "quantities[12]"
                if (key.startsWith("quantities[")) {
                    String productCodeStr = key.substring("quantities[".length(), key.length() - 1); // estrae "12"
                    int productCode = Integer.parseInt(productCodeStr);
                    int quantity = Integer.parseInt(entry.getValue()[0]);

                    cartDao.updateQuantity(userId, productCode, quantity);
                }
            }

        } catch (SQLException | NumberFormatException e) {
            throw new ServletException("Errore aggiornamento carrello", e);
        }

        response.sendRedirect("cart");
    }
}
