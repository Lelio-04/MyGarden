package it.unisa.register;

import javax.sql.DataSource;
import java.sql.*;
import java.security.MessageDigest;
import java.nio.charset.StandardCharsets;

public class UserDAO {

    private final DataSource dataSource;

    public UserDAO(DataSource dataSource) {
        this.dataSource = dataSource;
    }

    public boolean emailExists(String email) {
        String sql = "SELECT id FROM users WHERE email = ?";
        try (Connection conn = dataSource.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, email.trim());
            ResultSet rs = stmt.executeQuery();
            return rs.next();

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean usernameExists(String username) {
        String sql = "SELECT id FROM users WHERE username = ?";
        try (Connection conn = dataSource.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, username.trim());
            ResultSet rs = stmt.executeQuery();
            return rs.next();

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean register(User user) {
        String hashedPassword = toHash(user.getPassword());
        String sql = "INSERT INTO users (username, email, password, telefono, data_nascita, indirizzo, citta, provincia, cap) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = dataSource.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, user.getUsername());
            stmt.setString(2, user.getEmail());
            stmt.setString(3, hashedPassword);
            stmt.setString(4, user.getTelefono());
            stmt.setString(5, user.getDataNascita());
            stmt.setString(6, user.getIndirizzo());
            stmt.setString(7, user.getCitta());
            stmt.setString(8, user.getProvincia());
            stmt.setString(9, user.getCap());

            return stmt.executeUpdate() == 1;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public User getUserById(int id) throws SQLException {
        String sql = "SELECT * FROM users WHERE id = ?";
        try (Connection conn = dataSource.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, id);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                return new User(
                    rs.getString("username"),
                    rs.getString("email"),
                    rs.getString("password"),
                    rs.getString("telefono"),
                    rs.getString("data_nascita"),
                    rs.getString("indirizzo"),
                    rs.getString("citta"),
                    rs.getString("provincia"),
                    rs.getString("cap")
                );
            } else {
                return null;
            }
        }
    }

    private String toHash(String password) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-512");
            byte[] hash = digest.digest(password.getBytes(StandardCharsets.UTF_8));
            StringBuilder sb = new StringBuilder();
            for (byte b : hash) sb.append(String.format("%02x", b));
            return sb.toString();
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
}
