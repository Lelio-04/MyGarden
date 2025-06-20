package it.unisa.login;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

import javax.sql.DataSource;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

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

        // 🔍 Debug
        System.out.println("Tentativo login:");
        System.out.println("Username: " + username);
        System.out.println("Password (hash): " + hashPassword);

        Connection conn = null;
        try {
            // 🔗 Recupera il DataSource dal ServletContext
            DataSource dsUtenti = (DataSource) getServletContext().getAttribute("DataSourceUtenti");
            if (dsUtenti == null) {
                throw new SQLException("DataSource 'DataSourceUtenti' non trovato nel ServletContext.");
            }

            conn = dsUtenti.getConnection();
            String sql = "SELECT username, password FROM users WHERE username = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, username);
                ResultSet rs = ps.executeQuery();

                if (rs.next()) {
                    String passwordFromDb = rs.getString("password").trim();
                    String usernameFromDb = rs.getString("username").trim();

                    if (hashPassword.equals(passwordFromDb)) {
                        boolean isAdmin = "admin".equalsIgnoreCase(usernameFromDb);
                        request.getSession().setAttribute("isAdmin", isAdmin);

                        System.out.println("✅ LOGIN OK: utente riconosciuto. isAdmin = " + isAdmin);

                        if (isAdmin) {
                            response.sendRedirect("admin/adminCatalogo.jsp");
                        } else {
                            response.sendRedirect("catalogo.jsp");
                        }
                        return;
                    } else {
                        errors.add("Password errata!");
                    }
                } else {
                    errors.add("Utente non trovato!");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            errors.add("Errore di connessione al database.");
        } finally {
            try {
                if (conn != null) conn.close(); // con JNDI chiudi solo la connessione
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }

        // ❌ Login fallito
        System.out.println("❌ LOGIN FALLITO.");
        request.setAttribute("errors", errors);
        dispatcherToLoginPage.forward(request, response);
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
