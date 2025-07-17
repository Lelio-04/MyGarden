package it.unisa.cart;

import it.unisa.db.ProductBean;

import javax.sql.DataSource;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CartDAODataSource implements ICartDao{

    private final DataSource dataSource;

    public CartDAODataSource(DataSource dataSource) {
        this.dataSource = dataSource;
    }

    public boolean addToCart(int userId, int productCode, int quantityToAdd) throws SQLException {
        int currentQuantity = getProductQuantityInCart(userId, productCode);
        int availableStock = getAvailableQuantity(productCode);

        if (currentQuantity + quantityToAdd > availableStock) {
            System.out.println("DEBUG CART DAO: Quantità richiesta supera lo stock disponibile");
            return false;
        }

        String sql = "INSERT INTO cart_items (user_id, product_code, quantity) " +
                     "VALUES (?, ?, ?) " +
                     "ON DUPLICATE KEY UPDATE quantity = quantity + VALUES(quantity)";

        try (Connection conn = dataSource.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, productCode);
            ps.setInt(3, quantityToAdd);

            int rows = ps.executeUpdate();
            System.out.println("DEBUG CART DAO: Quantità aggiornata per utente " + userId);
            return true;
        }
    }



    public int getAvailableQuantity(int productCode) throws SQLException {
        String sql = "SELECT quantity FROM products WHERE code = ?";
        try (Connection conn = dataSource.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, productCode);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("quantity");
                }
            }
        }
        return 0; // prodotto non trovato = stock 0
    }

    public List<CartBean> getCartItems(int userId) throws SQLException {
        List<CartBean> items = new ArrayList<>();

        String sql = "SELECT c.*, p.name, p.price, p.description, p.image FROM cart_items c " +
                     "JOIN products p ON c.product_code = p.code WHERE c.user_id = ?";

        try (Connection conn = dataSource.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    CartBean item = new CartBean();
                    item.setId(rs.getInt("id"));
                    item.setUserId(userId);
                    item.setProductCode(rs.getInt("product_code"));
                    item.setQuantity(rs.getInt("quantity"));

                    ProductBean product = new ProductBean();
                    product.setCode(rs.getInt("product_code"));
                    product.setName(rs.getString("name"));
                    product.setDescription(rs.getString("description"));
                    product.setImage(rs.getString("image"));
                    product.setPrice(rs.getDouble("price"));

                    item.setProduct(product);
                    items.add(item);
                }
            }
        }

        return items;
    }

    public void removeItem(int userId, int productCode) throws SQLException {
        String sql = "DELETE FROM cart_items WHERE user_id = ? AND product_code = ?";

        try (Connection conn = dataSource.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, productCode);
            ps.executeUpdate();
        }
    }

    public void clearCart(int userId) throws SQLException {
        String sql = "DELETE FROM cart_items WHERE user_id = ?";

        try (Connection conn = dataSource.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.executeUpdate();
        }
    }

    public void updateQuantity(int userId, int productCode, int quantity) throws SQLException {
        String sql = "UPDATE cart_items SET quantity = ? WHERE user_id = ? AND product_code = ?";

        try (Connection conn = dataSource.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, quantity);
            ps.setInt(2, userId);
            ps.setInt(3, productCode);
            ps.executeUpdate();
        }
    }

    @Override
    public int getProductQuantityInCart(int userId, int productCode) throws SQLException {
        String sql = "SELECT quantity FROM cart_items WHERE user_id = ? AND product_code = ?";
        try (Connection conn = dataSource.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, productCode);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("quantity");
                }
            }
        }
        return 0; // Se il prodotto non è nel carrello dell'utente, la quantità è 0
    }

    @Override
    public ProductBean getProductDetails(int productCode) throws SQLException {
        String sql = "SELECT code, name, description, price, quantity, image FROM product WHERE code = ?";

        try (Connection conn = dataSource.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, productCode);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    ProductBean product = new ProductBean();
                    product.setCode(rs.getInt("code"));
                    product.setName(rs.getString("name"));
                    product.setDescription(rs.getString("description"));
                    product.setPrice(rs.getDouble("price"));
                    product.setQuantity(rs.getInt("quantity"));
                    product.setImage(rs.getString("image"));

                    return product;
                } else {
                    return null; // Se il prodotto non esiste
                }
            }
        }
    }

	@Override
	public boolean addToCart(int userId, int productCode, int quantityToAdd, boolean isMerge) throws SQLException {
		// TODO Auto-generated method stub
		return false;
	}
}