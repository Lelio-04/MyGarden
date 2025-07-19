package it.unisa.login;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.sql.*;
import java.util.*;
import javax.sql.DataSource;

import it.unisa.cart.CartBean;
import it.unisa.cart.CartDAO;
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
                        session.setAttribute("username", dbUsername);
                        session.setAttribute("userId", userId);
                        session.setAttribute("isAdmin", isAdmin);
                        session.setAttribute("role", isAdmin ? "admin" : "cliente");

                        // CSRF token
                        String token = UUID.randomUUID().toString();
                        System.out.println("Session ID prima getSession: " + (request.getSession(false) != null ? request.getSession(false).getId() : "nessuna sessione"));
                        session = request.getSession(true);
                        System.out.println("Session ID dopo getSession: " + session.getId());

                        @SuppressWarnings("unchecked")
                        List<CartBean> guestCart = (List<CartBean>) session.getAttribute("guestCart");
                        System.out.println("guestCart in sessione? " + (guestCart != null ? "sì, " + guestCart.size() + " elementi" : "no"));


                        if (guestCart != null && !guestCart.isEmpty()) {
                            System.out.println("guestCart contiene " + guestCart.size() + " elementi.");

                            CartDAO cartDAO = new CartDAO(ds);

                            // Recupera carrello utente dal DB
                            List<CartBean> userCart = cartDAO.getCartItems(userId);

                            if (userCart == null) userCart = new ArrayList<>();
                            System.out.println("userCart contiene " + userCart.size() + " elementi.");

                            // Mappa prodotto -> quantità per userCart
                            Map<Integer, Integer> userMap = new HashMap<>();
                            for (CartBean item : userCart) {
                                userMap.put(item.getProductCode(), item.getQuantity());
                            }

                            // Somma quantità guestCart a userCart
                            for (CartBean guestItem : guestCart) {
                                int prodCode = guestItem.getProductCode();
                                int guestQty = guestItem.getQuantity();
                                userMap.merge(prodCode, guestQty, Integer::sum);
                            }

                            System.out.println("Dopo merge userMap contiene:");
                            for (Map.Entry<Integer, Integer> entry : userMap.entrySet()) {
                                System.out.println("Prodotto " + entry.getKey() + " qty " + entry.getValue());
                            }

                            // Ricostruisci lista unificata
                            List<CartBean> mergedCart = new ArrayList<>();
                            for (Map.Entry<Integer, Integer> entry : userMap.entrySet()) {
                                CartBean cb = new CartBean();
                                cb.setUserId(userId);
                                cb.setProductCode(entry.getKey());
                                cb.setQuantity(entry.getValue());
                                mergedCart.add(cb);
                            }

                            // Aggiorna carrello utente nel DB
                            try {
                                cartDAO.updateUserCart(userId, mergedCart);
                                System.out.println("Carrello utente aggiornato con " + mergedCart.size() + " prodotti.");
                            } catch (Exception e) {
                                System.err.println("Errore aggiornando carrello utente: " + e.getMessage());
                            }

                            // Rimuovi carrello guest dalla sessione
                            session.removeAttribute("guestCart");
                            System.out.println("guestCart rimosso dalla sessione.");
                        } else {
                            System.out.println("guestCart è null o vuoto, niente merge da fare.");
                        }

                        System.out.println("✅ LOGIN OK — Session ID: " + session.getId());
                        System.out.println("🟢 Username: " + dbUsername + " | Admin: " + isAdmin);

                        // No cache headers
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
        request.getRequestDispatcher("login.jsp").forward(request, response);
    }
}
