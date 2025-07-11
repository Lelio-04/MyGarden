package it.unisa.cart;

import it.unisa.db.ProductBean;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import javax.naming.Context;
import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.sql.DataSource;

import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/cart")
public class CartControl extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private DataSource dataSource;

    @Override
    public void init() throws ServletException {
        try {
            Context initContext = new InitialContext();
            Context envContext = (Context) initContext.lookup("java:comp/env"); // qui senza slash dopo java:
            dataSource = (DataSource) envContext.lookup("jdbc/storage");        // qui il nome JNDI esatto
        } catch (NamingException e) {
            throw new ServletException("Impossibile ottenere il DataSource", e);
        }
    }


    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Integer userId = (Integer) session.getAttribute("userId");

        List<CartBean> cartItems = new ArrayList<>();

        if (userId != null) {
            // Utente loggato: carica carrello da DB
            CartDAO cartDao = new CartDAO(dataSource);
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
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
