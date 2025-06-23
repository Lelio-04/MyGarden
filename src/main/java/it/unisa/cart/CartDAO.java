package it.unisa.cart;

import it.unisa.db.DriverManagerConnectionPool;
import it.unisa.db.ProductBean;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CartDAO {

    private final DriverManagerConnectionPool connectionPool;

    public CartDAO(DriverManagerConnectionPool pool) {
        this.connectionPool = pool;
    }

    public void addToCart(int userId, int productCode, int quantity) throws SQLException {
        String sql = "INSERT INTO cart_items (user_id, product_code, quantity) " +
                     "VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE quantity = quantity + ?";

        try (Connection conn = connectionPool.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, productCode);
            ps.setInt(3, quantity);
            ps.setInt(4, quantity);
            ps.executeUpdate();
        }
    }

    public List<CartBean> getCartItems(int userId) throws SQLException {
        List<CartBean> items = new ArrayList<>();
        String sql = "SELECT ci.id, ci.user_id, ci.product_code, ci.quantity, " +
                     "p.name, p.description, p.price, p.quantity AS stock_quantity, p.image " +
                     "FROM cart_items ci " +
                     "JOIN product p ON ci.product_code = p.code " +
                     "WHERE ci.user_id = ?";

        try (Connection conn = connectionPool.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                // Crea oggetto prodotto
                ProductBean product = new ProductBean();
                product.setCode(rs.getInt("product_code"));
                product.setName(rs.getString("name"));
                product.setDescription(rs.getString("description"));
                product.setPrice(rs.getInt("price"));
                product.setQuantity(rs.getInt("stock_quantity")); // quantità disponibile in magazzino
                product.setImage(rs.getString("image"));

                // Crea oggetto carrello
                CartBean item = new CartBean();
                item.setId(rs.getInt("id"));
                item.setUserId(rs.getInt("user_id"));
                item.setProductCode(rs.getInt("product_code"));
                item.setQuantity(rs.getInt("quantity"));
                item.setProduct(product); // 🔥 importantissimo!

                items.add(item);
            }
        }

        return items;
    }

    public void removeItem(int userId, int productCode) throws SQLException {
        String sql = "DELETE FROM cart_items WHERE user_id = ? AND product_code = ?";

        try (Connection conn = connectionPool.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, productCode);
            ps.executeUpdate();
        }
    }

    public void clearCart(int userId) throws SQLException {
        String sql = "DELETE FROM cart_items WHERE user_id = ?";

        try (Connection conn = connectionPool.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.executeUpdate();
        }
    }
}
