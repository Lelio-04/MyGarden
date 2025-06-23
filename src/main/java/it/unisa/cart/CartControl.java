package it.unisa.cart;

import it.unisa.db.DriverManagerConnectionPool;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

@WebServlet("/cart")
public class CartControl extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Integer userId = (Integer) request.getSession().getAttribute("userId");

        if (userId == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        DriverManagerConnectionPool pool = (DriverManagerConnectionPool) getServletContext().getAttribute("DriverManager");
        CartDAO cartDao = new CartDAO(pool);

        try {
            List<CartBean> cartItems = cartDao.getCartItems(userId);
            request.setAttribute("cartItems", cartItems);
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Errore nel caricamento del carrello: " + e.getMessage());
        }

        request.getRequestDispatcher("carrello.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doGet(request, response);
    }
}
