package it.unisa.login;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.sql.*;
import java.util.*;

import javax.sql.DataSource;

import it.unisa.cart.CartBean;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

@WebServlet("/Login")
public class Login extends HttpServlet {

    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String username = request.getParameter("username");
        String password = request.getParameter("password");

        List<String> errors = new ArrayList<>();
        RequestDispatcher dispatcherToLoginPage = request.getRequestDispatcher("login.jsp");

        if (username == null || username.trim().isEmpty() || password == null || password.trim().isEmpty()) {
            errors.add("Username e password sono obbligatori!");
            request.setAttribute("errors", errors);
            dispatcherToLoginPage.forward(request, response);
            return;
        }

        username = username.trim();
        password = password.trim();
        String hashPassword = toHash(password);

        System.out.println("Tentativo login:");
        System.out.println("Username: " + username);
        System.out.println("Password (hash): " + hashPassword);

        Connection conn = null;
        try {
            DataSource dsStorege = (DataSource) getServletContext().getAttribute("DataSourceStorage");
            if (dsStorege == null) {
                throw new SQLException("DataSource 'DataSourceStorage' non trovato nel ServletContext.");
            }

            conn = dsStorege.getConnection();
            String sql = "SELECT id, username, password FROM users WHERE username = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, username);
                ResultSet rs = ps.executeQuery();

                if (rs.next()) {
                    int userId = rs.getInt("id");
                    String usernameFromDb = rs.getString("username").trim();
                    String passwordFromDb = rs.getString("password").trim();

                    if (hashPassword.equals(passwordFromDb)) {
                        boolean isAdmin = "admin".equalsIgnoreCase(usernameFromDb);

                        HttpSession session = request.getSession(true);
                        session.setAttribute("username", usernameFromDb);
                        session.setAttribute("isAdmin", isAdmin);
                        session.setAttribute("userId", userId);
                        session.setMaxInactiveInterval(30 * 60); // 30 minuti

                        // ✅ Se esiste un guestCart, migra gli articoli nel DB
                        @SuppressWarnings("unchecked")
                        List<CartBean> guestCart = (List<CartBean>) session.getAttribute("guestCart");

                        if (guestCart != null && !guestCart.isEmpty()) {
                            for (CartBean item : guestCart) {
                                insertCartItem(conn, userId, item.getProductCode(), item.getQuantity());
                            }
                            session.removeAttribute("guestCart");
                        }

                        System.out.println("✅ LOGIN OK");
                        System.out.println("🟢 Sessione ID: " + session.getId());
                        System.out.println("🟢 Username in sessione: " + session.getAttribute("username"));
                        System.out.println("🟢 userId in sessione: " + session.getAttribute("userId"));

                        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
                        response.setHeader("Pragma", "no-cache");
                        response.setDateHeader("Expires", 0);

                        response.sendRedirect("index.jsp");
                        return;
                    } else {
                        errors.add("Password errata!");
                        System.out.println("❌ Password errata per utente: " + username);
                    }
                } else {
                    errors.add("Utente non trovato!");
                    System.out.println("❌ Utente non trovato: " + username);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            errors.add("Errore di connessione al database.");
        } finally {
            try {
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }

        System.out.println("❌ LOGIN FALLITO.");
        request.setAttribute("errors", errors);
        dispatcherToLoginPage.forward(request, response);
    }

    private void insertCartItem(Connection conn, int userId, int productCode, int quantity) throws SQLException {
        String sql = "INSERT INTO cart_items (user_id, product_code, quantity) VALUES (?, ?, ?) " +
                     "ON DUPLICATE KEY UPDATE quantity = quantity + VALUES(quantity)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, productCode);
            ps.setInt(3, quantity);
            ps.executeUpdate();
        }
    }

    private String toHash(String password) {
        StringBuilder hashString = new StringBuilder();
        try {
            java.security.MessageDigest digest = java.security.MessageDigest.getInstance("SHA-512");
            byte[] hash = digest.digest(password.getBytes(StandardCharsets.UTF_8));
            for (byte b : hash) {
                hashString.append(String.format("%02x", b));
            }
        } catch (java.security.NoSuchAlgorithmException e) {
            System.out.println("Errore hashing: " + e.getMessage());
        }
        return hashString.toString();
    }
}
