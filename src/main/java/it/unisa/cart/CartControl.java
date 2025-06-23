package it.unisa.cart;

import it.unisa.db.DriverManagerConnectionPool;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/cart")
public class CartControl extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        Integer userId = (Integer) session.getAttribute("userId");

        List<CartBean> cartItems = new ArrayList<>();

        if (userId != null) {
            // Utente loggato: carica carrello da DB
            DriverManagerConnectionPool pool = (DriverManagerConnectionPool) getServletContext().getAttribute("DriverManager");
            CartDAO cartDao = new CartDAO(pool);

            try {
                cartItems = cartDao.getCartItems(userId);
            } catch (SQLException e) {
                e.printStackTrace();
                request.setAttribute("errorMessage", "Errore nel caricamento del carrello: " + e.getMessage());
            }
        } else {
            // Utente non loggato: carrello dalla sessione
            @SuppressWarnings("unchecked")
            List<CartBean> guestCart = (List<CartBean>) session.getAttribute("guestCart");
            if (guestCart != null) {
                cartItems = guestCart;
            }
        }

        request.setAttribute("cartItems", cartItems);
        request.getRequestDispatcher("carrello.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doGet(request, response);
    }
}
