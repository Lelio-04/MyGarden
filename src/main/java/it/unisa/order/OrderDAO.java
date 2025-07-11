package it.unisa.order;

import it.unisa.cart.CartBean;
import it.unisa.db.DriverManagerConnectionPool;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class OrderDAO {

    private final DriverManagerConnectionPool connectionPool;

    public OrderDAO(DriverManagerConnectionPool pool) {
        this.connectionPool = pool;
    }

    public int createOrder(int userId, List<CartBean> cartItems) throws SQLException {
        String insertOrderSQL = "INSERT INTO orders (user_id, total) VALUES (?, ?)";
        String insertItemSQL = "INSERT INTO order_items (order_id, product_code, quantity, price_at_purchase) VALUES (?, ?, ?, ?)";
        double total = 0.0;

        for (CartBean item : cartItems) {
            total += item.getProduct().getPrice() * item.getQuantity();
        }

        int orderId = -1;

        try (Connection conn = connectionPool.getConnection()) {
            conn.setAutoCommit(false);

            try (
                PreparedStatement orderStmt = conn.prepareStatement(insertOrderSQL, Statement.RETURN_GENERATED_KEYS);
                PreparedStatement itemStmt = conn.prepareStatement(insertItemSQL)
            ) {
                // Inserimento ordine
                orderStmt.setInt(1, userId);
                orderStmt.setDouble(2, total);
                int orderRows = orderStmt.executeUpdate();

                if (orderRows == 0) {
                    System.out.println("❌ Nessuna riga inserita in 'orders'.");
                    conn.rollback();
                    return -1;
                }

                try (ResultSet rs = orderStmt.getGeneratedKeys()) {
                    if (rs.next()) {
                        orderId = rs.getInt(1);
                        System.out.println("✅ Ordine inserito con ID: " + orderId);
                    } else {
                        System.out.println("❌ Errore nel recupero dell'ID dell'ordine.");
                        conn.rollback();
                        return -1;
                    }
                }

                // Inserimento prodotti
                for (CartBean item : cartItems) {
                    double price = item.getProduct().getPrice();
                    itemStmt.setInt(1, orderId);
                    itemStmt.setInt(2, item.getProductCode());
                    itemStmt.setInt(3, item.getQuantity());
                    itemStmt.setDouble(4, price);

                    System.out.println("➡️ Aggiungo item: code=" + item.getProductCode()
                            + ", qty=" + item.getQuantity() + ", prezzo=" + price);
                    itemStmt.addBatch();
                }

                int[] results = itemStmt.executeBatch();
                conn.commit();

                System.out.println("✅ Inseriti " + results.length + " articoli nell'ordine.");
            } catch (SQLException e) {
                conn.rollback();
                System.out.println("❌ Errore durante la creazione dell'ordine: " + e.getMessage());
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

        try (Connection conn = connectionPool.getConnection();
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
    
    public void insertOrderInfo(int orderId, String fullName, String address, String city, String cap, String paymentMethod) throws SQLException {
        String sql = "INSERT INTO order_info (order_id, full_name, address, city, cap, payment_method) VALUES (?, ?, ?, ?, ?, ?)";

        try (Connection conn = connectionPool.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, orderId);
            ps.setString(2, fullName);
            ps.setString(3, address);
            ps.setString(4, city);
            ps.setString(5, cap);
            ps.setString(6, paymentMethod);

            int rows = ps.executeUpdate();
            System.out.println("📝 [OrderDAO] Dettagli ordine salvati (" + rows + " riga/e).");
        }
    }

}
