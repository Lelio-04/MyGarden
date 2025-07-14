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
import java.util.UUID;

@WebServlet("/checkout-page")
public class CheckoutPageServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private DataSource dataSource;

    @Override
    public void init() throws ServletException {
        try {
            Context initContext = new InitialContext();
            Context envContext = (Context) initContext.lookup("java:comp/env");
            dataSource = (DataSource) envContext.lookup("jdbc/storage");
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
            UserDAO userDAO = new UserDAO(dataSource);
            User user = userDAO.getUserById(userId);

            CartDAO cartDAO = new CartDAO(dataSource);
            List<CartBean> cartItems = cartDAO.getCartItems(userId);

            // ✅ Verifica se qualche prodotto ha quantità maggiore della disponibilità
            boolean superaDisponibilita = false;

            for (CartBean item : cartItems) {
                int richiesta = item.getQuantity();
                int disponibile = cartDAO.getAvailableQuantity(item.getProductCode());

                if (richiesta > disponibile) {
                    superaDisponibilita = true;
                    break;
                }
            }

            if (superaDisponibilita) {
                // ⚠️ Messaggio e redirect al carrello
                request.setAttribute("erroreQuantita", "Alcuni prodotti superano la quantità disponibile. Riduci le quantità prima di procedere.");
                request.setAttribute("cartItems", cartItems);
                request.getRequestDispatcher("catalogo.jsp").forward(request, response);
                return;
            }

            // ✅ Se tutto è valido, procedi col checkout
            String token = UUID.randomUUID().toString();
            session.setAttribute("sessionToken", token);

            request.setAttribute("user", user);
            request.setAttribute("cartItems", cartItems);

            request.getRequestDispatcher("checkout.jsp").forward(request, response);

        } catch (SQLException e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Errore nel caricamento dati utente/carrello.");
        }
    }
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doPost(request, response);
    }
}
