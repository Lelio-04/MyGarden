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
import jakarta.servlet.http.HttpSession;

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
                        
                        // Ottieni la sessione e imposta gli attributi
                        HttpSession session = request.getSession(true); // Crea sessione se non esiste
                        session.setAttribute("username", usernameFromDb);
                        session.setAttribute("isAdmin", isAdmin);
                        
                        // Imposta timeout sessione (30 minuti)
                        session.setMaxInactiveInterval(30 * 60);

                        System.out.println("✅ LOGIN OK");
                        System.out.println("usernameFromDb = " + usernameFromDb);
                        System.out.println("🟢 Sessione ID: " + session.getId());
                        System.out.println("🟢 Username in sessione: " + session.getAttribute("username"));

                        // Aggiungi header per evitare cache
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