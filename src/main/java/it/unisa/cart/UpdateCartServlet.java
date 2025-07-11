package it.unisa.cart;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import javax.sql.DataSource;
import java.io.IOException;
import java.sql.SQLException;
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
        cartDao = (ICartDao) new CartDAODataSource(ds);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        Integer userId = (Integer) session.getAttribute("userId");

        if (userId == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        try {
            for (Map.Entry<String, String[]> entry : request.getParameterMap().entrySet()) {
                String key = entry.getKey(); // es. "quantities[12]"
                if (key.startsWith("quantities[")) {
                    String productCodeStr = key.substring("quantities[".length(), key.length() - 1);
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
