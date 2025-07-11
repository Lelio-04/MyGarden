package it.unisa.cart;

import it.unisa.db.ProductBean;

import javax.sql.DataSource;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CartDAO implements ICartDao {

    private final DataSource dataSource;

    public CartDAO(DataSource dataSource) {
        this.dataSource = dataSource;
    }

    @Override
    public void addToCart(int userId, int productCode, int quantity) throws SQLException {
        String sql = "INSERT INTO cart_items (user_id, product_code, quantity) " +
                     "VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE quantity = quantity + ?";

        try (Connection conn = dataSource.getConnection();
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
        String sql = "SELECT ci.id, ci.user_id, ci.product_code, ci.quantity, " +
                     "p.name, p.description, p.price, p.quantity AS stock_quantity, p.image " +
                     "FROM cart_items ci " +
                     "JOIN product p ON ci.product_code = p.code " +
                     "WHERE ci.user_id = ?";

        try (Connection conn = dataSource.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                ProductBean product = new ProductBean();
                product.setCode(rs.getInt("product_code"));
                product.setName(rs.getString("name"));
                product.setDescription(rs.getString("description"));
                product.setPrice(rs.getDouble("price"));
                product.setQuantity(rs.getInt("stock_quantity"));
                product.setImage(rs.getString("image"));

                CartBean item = new CartBean();
                item.setId(rs.getInt("id"));
                item.setUserId(rs.getInt("user_id"));
                item.setProductCode(rs.getInt("product_code"));
                item.setQuantity(rs.getInt("quantity"));
                item.setProduct(product);

                items.add(item);
            }
        }

        return items;
    }

    @Override
    public void updateQuantity(int userId, int productCode, int newQuantity) throws SQLException {
        String sql = "UPDATE cart_items SET quantity = ? WHERE user_id = ? AND product_code = ?";

        try (Connection conn = dataSource.getConnection();
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

        try (Connection conn = dataSource.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, productCode);
            ps.executeUpdate();
        }
    }

    @Override
    public void clearCart(int userId) throws SQLException {
        String sql = "DELETE FROM cart_items WHERE user_id = ?";

        try (Connection conn = dataSource.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.executeUpdate();
        }
    }
}
