package it.unisa.order;

import it.unisa.cart.CartBean;
import it.unisa.db.ProductBean;

import javax.sql.DataSource;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class OrderDAO {

    private final DataSource dataSource;

    public OrderDAO(DataSource dataSource) {
        this.dataSource = dataSource;
    }

    public int createOrder(int userId, List<CartBean> cartItems) throws SQLException {
        String insertOrderSQL = "INSERT INTO orders (user_id, total) VALUES (?, ?)";
        String insertItemSQL = "INSERT INTO order_items (order_id, product_code, quantity, price_at_purchase) VALUES (?, ?, ?, ?)";
        String updateProductQuantitySQL = "UPDATE product SET quantity = quantity - ? WHERE code = ? AND quantity >= ?";
        double total = 0.0;

        for (CartBean item : cartItems) {
            total += item.getProduct().getPrice() * item.getQuantity();
        }

        int orderId = -1;

        try (Connection conn = dataSource.getConnection()) {
            conn.setAutoCommit(false);

            try (
                PreparedStatement orderStmt = conn.prepareStatement(insertOrderSQL, Statement.RETURN_GENERATED_KEYS);
                PreparedStatement itemStmt = conn.prepareStatement(insertItemSQL);
                PreparedStatement updateQtyStmt = conn.prepareStatement(updateProductQuantitySQL)
            ) {
                // Inserisci ordine
                orderStmt.setInt(1, userId);
                orderStmt.setDouble(2, total);
                int orderRows = orderStmt.executeUpdate();

                if (orderRows == 0) {
                    conn.rollback();
                    return -1;
                }

                try (ResultSet rs = orderStmt.getGeneratedKeys()) {
                    if (rs.next()) {
                        orderId = rs.getInt(1);
                    } else {
                        conn.rollback();
                        return -1;
                    }
                }

                // Inserisci items e aggiorna quantità prodotti
                for (CartBean item : cartItems) {
                    double price = item.getProduct().getPrice();

                    // Inserisci item
                    itemStmt.setInt(1, orderId);
                    itemStmt.setInt(2, item.getProduct().getCode()); // product.code
                    itemStmt.setInt(3, item.getQuantity());
                    itemStmt.setDouble(4, price);
                    itemStmt.addBatch();

                    // Aggiorna quantità prodotto
                    updateQtyStmt.setInt(1, item.getQuantity());
                    updateQtyStmt.setInt(2, item.getProduct().getCode());
                    updateQtyStmt.setInt(3, item.getQuantity());

                    int updatedRows = updateQtyStmt.executeUpdate();
                    if (updatedRows == 0) {
                        conn.rollback();
                        throw new SQLException("Quantità insufficiente per prodotto codice: " + item.getProduct().getCode());
                    }
                }

                itemStmt.executeBatch();
                conn.commit();

            } catch (SQLException e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
        }

        return orderId;
    }

    public List<OrderBean> getOrdersByUser(int userId) throws SQLException {
        List<OrderBean> orders = new ArrayList<>();
        String sql = "SELECT id, user_id, created_at, total FROM orders WHERE user_id = ? ORDER BY created_at DESC";

        try (Connection conn = dataSource.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                OrderBean order = new OrderBean();
                order.setId(rs.getInt("id"));
                order.setUserId(rs.getInt("user_id"));
                order.setCreatedAt(rs.getTimestamp("created_at"));
                order.setTotal(rs.getDouble("total"));
                orders.add(order);
            }
        }

        return orders;
    }

    public List<OrderBean> getAllOrders() throws SQLException {
        List<OrderBean> orders = new ArrayList<>();
        String sql = "SELECT id, user_id, created_at, total FROM orders ORDER BY created_at DESC";

        try (Connection conn = dataSource.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                OrderBean order = new OrderBean();
                order.setId(rs.getInt("id"));
                order.setUserId(rs.getInt("user_id"));
                order.setCreatedAt(rs.getTimestamp("created_at"));
                order.setTotal(rs.getDouble("total"));
                orders.add(order);
            }
        }

        return orders;
    }

    public void insertOrderInfo(int orderId, String fullName, String address, String city, String cap, String paymentMethod) throws SQLException {
        String sql = "INSERT INTO order_info (order_id, full_name, address, city, cap, payment_method) VALUES (?, ?, ?, ?, ?, ?)";

        try (Connection conn = dataSource.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, orderId);
            ps.setString(2, fullName);
            ps.setString(3, address);
            ps.setString(4, city);
            ps.setString(5, cap);
            ps.setString(6, paymentMethod);

            ps.executeUpdate();
            System.out.println("📝 [OrderDAO] Dettagli ordine salvati.");
        }
    }
}
