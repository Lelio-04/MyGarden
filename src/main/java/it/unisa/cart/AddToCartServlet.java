package it.unisa.cart;

import it.unisa.db.DriverManagerConnectionPool;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/AddToCartServlet")
public class AddToCartServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private CartDAO cartDAO;

    @Override
    public void init() throws ServletException {
        cartDAO = new CartDAO(new DriverManagerConnectionPool());
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        Integer userId = (session != null) ? (Integer) session.getAttribute("userId") : null;

        if (userId == null) {
            System.out.println("❌ userId mancante nella sessione.");
            response.sendRedirect("login.jsp");
            return;
        }

        try {
            int productCode = Integer.parseInt(request.getParameter("productCode"));
            int quantity = Integer.parseInt(request.getParameter("quantity"));

            cartDAO.addToCart(userId, productCode, quantity);
            System.out.println("✅ Prodotto aggiunto al carrello: userId=" + userId + ", productCode=" + productCode + ", quantity=" + quantity);
        } catch (NumberFormatException e) {
            System.out.println("❌ Errore nel parsing dei parametri: " + e.getMessage());
        } catch (Exception e) {
            e.printStackTrace();
        }

        response.sendRedirect("catalogo.jsp?added=1");
    }
}
