package it.unisa.cart;

import it.unisa.db.DriverManagerConnectionPool;
import it.unisa.db.ProductBean;
import it.unisa.db.ProductDaoDriverMan;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CartDAODriverManager implements ICartDao {

    private final DriverManagerConnectionPool connectionPool;

    public CartDAODriverManager(DriverManagerConnectionPool pool) {
        this.connectionPool = pool;
    }

    @Override
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

    @Override
    public List<CartBean> getCartItems(int userId) throws SQLException {
        List<CartBean> items = new ArrayList<>();
        String sql = "SELECT * FROM cart_items WHERE user_id = ?";

        try (Connection conn = connectionPool.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();

            ProductDaoDriverMan productDAO = new ProductDaoDriverMan(connectionPool);

            while (rs.next()) {
                CartBean item = new CartBean();
                item.setId(rs.getInt("id"));
                item.setUserId(userId);
                item.setProductCode(rs.getInt("product_code"));
                item.setQuantity(rs.getInt("quantity"));

                ProductBean product = productDAO.doRetrieveByKey(item.getProductCode());
                item.setProduct(product);

                items.add(item);
            }

            rs.close();
        }

        return items;
    }

    @Override
    public void updateQuantity(int userId, int productCode, int newQuantity) throws SQLException {
        String sql = "UPDATE cart_items SET quantity = ? WHERE user_id = ? AND product_code = ?";

        try (Connection conn = connectionPool.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, newQuantity);
            ps.setInt(2, userId);
            ps.setInt(3, productCode);
            ps.executeUpdate();
        }
    }

    @Override
    public void removeItem(int userId, int productCode) throws SQLException {
        String sql = "DELETE FROM cart_items WHERE user_id = ? AND product_code = ?";

        try (Connection conn = connectionPool.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ps.setInt(2, productCode);
            ps.executeUpdate();
        }
    }

    @Override
    public void clearCart(int userId) throws SQLException {
        String sql = "DELETE FROM cart_items WHERE user_id = ?";

        try (Connection conn = connectionPool.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ps.executeUpdate();
        }
    }
}
