package it.unisa.order;

import it.unisa.cart.CartBean;
import it.unisa.cart.CartDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import javax.sql.DataSource;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

@WebServlet("/checkout")
public class CheckoutServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private DataSource dataSource;

    @Override
    public void init() throws ServletException {
        super.init();
        // Recupera il DataSource dal ServletContext
        dataSource = (DataSource) getServletContext().getAttribute("DataSourceStorage");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Integer userId = (Integer) session.getAttribute("userId");

        if (userId == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        // 📝 Dati inviati dal form di checkout.jsp
        String fullName = request.getParameter("fullName");
        String address = request.getParameter("address");
        String city = request.getParameter("city");
        String cap = request.getParameter("cap");
        String payment = request.getParameter("payment");

        System.out.println("📝 Nome: " + fullName);
        System.out.println("📝 Indirizzo: " + address + ", " + cap + " " + city);
        System.out.println("📝 Metodo pagamento: " + payment);

        CartDAO cartDAO = new CartDAO(dataSource);
        OrderDAO orderDAO = new OrderDAO(dataSource);

        try {
            List<CartBean> cartItems = cartDAO.getCartItems(userId);
            if (cartItems == null || cartItems.isEmpty()) {
                request.setAttribute("error", "Il carrello è vuoto.");
                request.getRequestDispatcher("carrello.jsp").forward(request, response);
                return;
            }

            // ✅ Crea ordine e salva articoli
            int orderId = orderDAO.createOrder(userId, cartItems);
            System.out.println("✅ Ordine creato con ID: " + orderId);

            if (orderId > 0) {
                // ✅ Inserisce dati di spedizione/pagamento
                orderDAO.insertOrderInfo(orderId, fullName, address, city, cap, payment);

                // ✅ Svuota carrello
                cartDAO.clearCart(userId);
                System.out.println("🧹 Carrello svuotato.");

                response.sendRedirect("ordini.jsp");
            } else {
                request.setAttribute("error", "Errore durante la creazione dell'ordine.");
                request.getRequestDispatcher("carrello.jsp").forward(request, response);
            }

        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Errore SQL: " + e.getMessage());
            request.getRequestDispatcher("carrello.jsp").forward(request, response);
        }
    }
}
