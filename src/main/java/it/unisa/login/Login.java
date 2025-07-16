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

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String next = request.getParameter("next");

        List<String> errors = new ArrayList<>();
        RequestDispatcher dispatcher = request.getRequestDispatcher("login.jsp");

        if (username == null || username.trim().isEmpty() || password == null || password.trim().isEmpty()) {
            errors.add("Username e password sono obbligatori!");
            request.setAttribute("errors", errors);
            dispatcher.forward(request, response);
            return;
        }

        username = username.trim();
        password = password.trim();
        String hashedPassword = toHash(password);

        System.out.println("Tentativo login: " + username);

        Connection conn = null;
        try {
            DataSource ds = (DataSource) getServletContext().getAttribute("DataSourceStorage");
            if (ds == null) throw new SQLException("DataSource non trovato.");

            conn = ds.getConnection();

            String sql = "SELECT id, username, password FROM users WHERE username = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, username);
                ResultSet rs = ps.executeQuery();

                if (rs.next()) {
                    int userId = rs.getInt("id");
                    String dbUsername = rs.getString("username").trim();
                    String dbPassword = rs.getString("password").trim();

                    if (hashedPassword.equals(dbPassword)) {
                        boolean isAdmin = "admin".equalsIgnoreCase(dbUsername);

                        HttpSession session = request.getSession(true);
                        session.setAttribute("username", dbUsername); // per coerenza
                        session.setAttribute("userId", userId);
                        session.setAttribute("isAdmin", isAdmin);      // ✅ Booleano usato dalle JSP
                        session.setAttribute("role", isAdmin ? "admin" : "cliente");

                        // ✅ Token CSRF per la sessione
                        String token = UUID.randomUUID().toString();
                        session.setAttribute("sessionToken", token);

                        // ✅ Guest cart migration - QUESTO BLOCCO DEVE RIMANERE COMMENTATO
                        /*@SuppressWarnings("unchecked")
                        List<CartBean> guestCart = (List<CartBean>) session.getAttribute("guestCart");

                        if (guestCart != null && !guestCart.isEmpty()) {
                            for (CartBean item : guestCart) {
                                insertCartItem(conn, userId, item.getProductCode(), item.getQuantity());
                            }
                            session.removeAttribute("guestCart");
                        }*/

                        System.out.println("✅ LOGIN OK — Session ID: " + session.getId());
                        System.out.println("🟢 Username: " + dbUsername + " | Admin: " + isAdmin);

                        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
                        response.setHeader("Pragma", "no-cache");
                        response.setDateHeader("Expires", 0);

                        if (next != null && !next.isBlank()) {
                            response.sendRedirect(next);
                        } else {
                            response.sendRedirect("index.jsp");
                        }
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
            if (conn != null) try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
        }

        System.out.println("❌ LOGIN FALLITO");
        request.setAttribute("errors", errors);
        dispatcher.forward(request, response);
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
        try {
            java.security.MessageDigest digest = java.security.MessageDigest.getInstance("SHA-512");
            byte[] hash = digest.digest(password.getBytes(StandardCharsets.UTF_8));
            StringBuilder sb = new StringBuilder();
            for (byte b : hash) sb.append(String.format("%02x", b));
            return sb.toString();
        } catch (Exception e) {
            System.err.println("Errore hash: " + e.getMessage());
            return "";
        }
    }
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Tipicamente ridirigi alla pagina login.jsp
        request.getRequestDispatcher("login.jsp").forward(request, response);
    }
}