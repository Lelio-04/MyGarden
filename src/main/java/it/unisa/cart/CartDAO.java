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

    public boolean addToCart(int userId, int productCode, int quantityToAdd) throws SQLException {
        try (Connection conn = dataSource.getConnection()) {
            conn.setAutoCommit(false);

            // Verifica la disponibilità in magazzino del prodotto
            String selectStock = "SELECT quantity FROM product WHERE code = ? FOR UPDATE";

            try (PreparedStatement psStock = conn.prepareStatement(selectStock)) {
                // Controlla la disponibilità del prodotto
                psStock.setInt(1, productCode);
                int availableStock;
                try (ResultSet rsStock = psStock.executeQuery()) {
                    if (!rsStock.next()) {
                        conn.rollback();
                        System.out.println("Errore: Prodotto non trovato.");
                        return false; // Prodotto non trovato
                    }
                    availableStock = rsStock.getInt("quantity");
                    System.out.println("Disponibilità prodotto: " + availableStock);  // Log di debug
                }

                // Aggiungi o aggiorna la quantità nel carrello
                // Se il prodotto è già nel carrello, aggiorna la quantità
                String updateSql = "INSERT INTO cart_items (user_id, product_code, quantity) " +
                                   "VALUES (?, ?, ?) " +
                                   "ON DUPLICATE KEY UPDATE quantity = quantity + ?"; // Usa ON DUPLICATE KEY per aggiornare
                try (PreparedStatement psUpdate = conn.prepareStatement(updateSql)) {
                    psUpdate.setInt(1, userId);
                    psUpdate.setInt(2, productCode);
                    psUpdate.setInt(3, quantityToAdd);
                    psUpdate.setInt(4, quantityToAdd);  // Aggiungi la quantità

                    int rowsAffected = psUpdate.executeUpdate();
                    if (rowsAffected > 0) {
                        System.out.println("Prodotto aggiunto o quantità aggiornata nel carrello.");  // Log di debug
                    } else {
                        conn.rollback();
                        System.out.println("Errore durante l'aggiornamento del carrello.");
                        return false;
                    }
                }

                conn.commit();
                System.out.println("Transazione completata con successo.");
                return true;
            } catch (SQLException e) {
                conn.rollback();
                System.out.println("Errore durante l'operazione: " + e.getMessage() + ". Rollback eseguito.");
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
        }
    }

    public boolean addToCart(int userId, int productCode, int quantityToAdd, boolean isMerge) throws SQLException {
        try (Connection conn = dataSource.getConnection()) {
            conn.setAutoCommit(false);

            // Verifica la disponibilità in magazzino del prodotto
            String selectStock = "SELECT quantity FROM product WHERE code = ? FOR UPDATE";

            try (PreparedStatement psStock = conn.prepareStatement(selectStock)) {
                // Controlla la disponibilità del prodotto
                psStock.setInt(1, productCode);
                int availableStock;
                try (ResultSet rsStock = psStock.executeQuery()) {
                    if (!rsStock.next()) {
                        conn.rollback();
                        System.out.println("Errore: Prodotto non trovato.");
                        return false; // Prodotto non trovato
                    }
                    availableStock = rsStock.getInt("quantity");
                    System.out.println("Disponibilità prodotto: " + availableStock);  // Log di debug
                }

                // La query di inserimento/aggiornamento dipende dalla flag isMerge
                String updateSql;
                if (isMerge) {
                    // Se isMerge è true, sovrascrive la quantità nel carrello
                    updateSql = "INSERT INTO cart_items (user_id, product_code, quantity) " +
                                "VALUES (?, ?, ?) " +
                                "ON DUPLICATE KEY UPDATE quantity = ?";
                } else {
                    // Se isMerge è false, somma la quantità alla quantità esistente
                    updateSql = "INSERT INTO cart_items (user_id, product_code, quantity) " +
                                "VALUES (?, ?, ?) " +
                                "ON DUPLICATE KEY UPDATE quantity = quantity + ?";
                }

                try (PreparedStatement psUpdate = conn.prepareStatement(updateSql)) {
                    psUpdate.setInt(1, userId);
                    psUpdate.setInt(2, productCode);
                    psUpdate.setInt(3, quantityToAdd);

                    if (isMerge) {
                        // Sovrascrive la quantità esistente nel carrello con quella nuova
                        psUpdate.setInt(4, quantityToAdd);
                    } else {
                        // Somma la quantità esistente con quella nuova
                        psUpdate.setInt(4, quantityToAdd);
                    }

                    int rowsAffected = psUpdate.executeUpdate();
                    if (rowsAffected > 0) {
                        System.out.println("Prodotto aggiunto o quantità aggiornata nel carrello.");  // Log di debug
                    } else {
                        conn.rollback();
                        System.out.println("Errore durante l'aggiornamento del carrello.");
                        return false;
                    }
                }

                conn.commit();
                System.out.println("Transazione completata con successo.");
                return true;
            } catch (SQLException e) {
                conn.rollback();
                System.out.println("Errore durante l'operazione: " + e.getMessage() + ". Rollback eseguito.");
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
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
    
    public int getAvailableQuantity(int productCode) throws SQLException {
        String sql = "SELECT quantity FROM product WHERE code = ?";

        try (Connection conn = dataSource.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, productCode);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("quantity");
                } else {
                    // Prodotto non trovato, per sicurezza restituisci 0
                    return 0;
                }
            }
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
    public boolean insertToCart(int userId, int productCode, int quantity) throws SQLException {
        String sql = "INSERT INTO cart_items (user_id, product_code, quantity) VALUES (?, ?, ?)";
        try (Connection conn = dataSource.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, productCode);
            ps.setInt(3, quantity);
            int affectedRows = ps.executeUpdate();
            return affectedRows > 0;
        } catch (SQLException e) {
            if (e.getSQLState().startsWith("23")) { // codice di violazione chiave duplicata (dipende DB)
                return false; // riga esiste già
            } else {
                throw e;
            }
        }
    }
    public void updateOrInsertCartItem(int userId, int productCode, int quantity) throws SQLException {
        String sql = "INSERT INTO cart_items (user_id, product_code, quantity) " +
                     "VALUES (?, ?, ?) " +
                     "ON DUPLICATE KEY UPDATE quantity = VALUES(quantity)";

        try (Connection conn = dataSource.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, productCode);
            ps.setInt(3, quantity);
            ps.executeUpdate();
        }
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
    public void updateUserCart(int userId, List<CartBean> cartItems) throws SQLException {
        try (Connection conn = dataSource.getConnection()) {
            conn.setAutoCommit(false);  // Inizia una transazione

            // 1. Svuota il carrello esistente
            String clearCartSql = "DELETE FROM cart_items WHERE user_id = ?";
            try (PreparedStatement psClear = conn.prepareStatement(clearCartSql)) {
                psClear.setInt(1, userId);
                psClear.executeUpdate();
                System.out.println("Carrello dell'utente " + userId + " svuotato.");
            }

            // 2. Aggiungi i nuovi articoli nel carrello
            String insertSql = "INSERT INTO cart_items (user_id, product_code, quantity) VALUES (?, ?, ?)";
            try (PreparedStatement psInsert = conn.prepareStatement(insertSql)) {
                for (CartBean cartItem : cartItems) {
                    int productCode = cartItem.getProductCode();
                    int quantity = cartItem.getQuantity();

                    // Verifica la disponibilità del prodotto
                    ProductBean product = getProductDetails(productCode);
                    if (product == null || product.getQuantity() < quantity) {
                        // Se il prodotto non esiste o non c'è abbastanza disponibilità, interrompi
                        conn.rollback();
                        System.out.println("Errore: prodotto con codice " + productCode + " non disponibile o quantità insufficiente.");
                        throw new SQLException("Prodotto non disponibile o quantità insufficiente.");
                    }

                    // Aggiungi l'articolo al carrello
                    psInsert.setInt(1, userId);
                    psInsert.setInt(2, productCode);
                    psInsert.setInt(3, quantity);
                    psInsert.executeUpdate();
                    System.out.println("Prodotto con codice " + productCode + " aggiunto al carrello.");
                }
            }

            conn.commit();  // Completare la transazione
            System.out.println("Carrello aggiornato con successo.");
        } catch (SQLException e) {
            // Rollback in caso di errore
            System.out.println("Errore durante l'aggiornamento del carrello: " + e.getMessage());
            throw e;
        }
    }



}