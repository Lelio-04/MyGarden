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

            String selectStock = "SELECT quantity FROM product WHERE code = ? FOR UPDATE";

            try (PreparedStatement psStock = conn.prepareStatement(selectStock)) {
                //Controlla disponibilità del prodotto
                psStock.setInt(1, productCode);
                int availableStock;
                try (ResultSet rsStock = psStock.executeQuery()) {
                    if (!rsStock.next()) {
                        conn.rollback();
                        System.out.println("Errore: Prodotto non trovato.");
                        return false; //Prod non trovato
                    }
                    availableStock = rsStock.getInt("quantity");
                    System.out.println("Disponibilità prodotto: " + availableStock);  // Log di debug
                }

                // Aggiungi quantità nel carrello
                // Se prod già nel carrello, aggiorna quantità
                String updateSql = "INSERT INTO cart_items (user_id, product_code, quantity) " +
                                   "VALUES (?, ?, ?) " +
                                   "ON DUPLICATE KEY UPDATE quantity = quantity + ?";
                try (PreparedStatement psUpdate = conn.prepareStatement(updateSql)) {
                    psUpdate.setInt(1, userId);
                    psUpdate.setInt(2, productCode);
                    psUpdate.setInt(3, quantityToAdd);
                    psUpdate.setInt(4, quantityToAdd);  //Aggiungi quantità

                    int rowsAffected = psUpdate.executeUpdate();
                    if (rowsAffected > 0) {
                        System.out.println("Prodotto aggiunto o quantità aggiornata nel carrello."); 
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
                    //Prodotto non trovato
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
        return 0; //Se prod non è nel carrello utente, quantità è 0
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
            if (e.getSQLState().startsWith("23")) {
                return false;
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
                    return null; //Se prod non esiste
                }
            }
        }
    }
    public void updateUserCart(int userId, List<CartBean> cartItems) throws SQLException {
        try (Connection conn = dataSource.getConnection()) {
            conn.setAutoCommit(false);  //Inizia transazione

            //Svuota carrello esistente
            String clearCartSql = "DELETE FROM cart_items WHERE user_id = ?";
            try (PreparedStatement psClear = conn.prepareStatement(clearCartSql)) {
                psClear.setInt(1, userId);
                psClear.executeUpdate();
                System.out.println("Carrello dell'utente " + userId + " svuotato.");
            }

            //Aggiungi nuovi articoli nel carrello
            String insertSql = "INSERT INTO cart_items (user_id, product_code, quantity) VALUES (?, ?, ?)";
            try (PreparedStatement psInsert = conn.prepareStatement(insertSql)) {
                for (CartBean cartItem : cartItems) {
                    int productCode = cartItem.getProductCode();
                    int requestedQuantity = cartItem.getQuantity();

                    //Verifica disponibilità prodotto
                    ProductBean product = getProductDetails(productCode);
                    if (product == null) {
                        conn.rollback();
                        System.out.println("Errore: prodotto con codice " + productCode + " non trovato.");
                        throw new SQLException("Prodotto non trovato.");
                    }

                    int availableQty = product.getQuantity();
                    int quantityToInsert = Math.min(requestedQuantity, availableQty);

                    if (quantityToInsert <= 0) {
                        System.out.println("Quantità zero o negativa per prodotto " + productCode + ", salto inserimento.");
                        continue; //Ignora prodotto se non disponibile
                    }

                    //Aggiungi articolo carrello con quantità limitata
                    psInsert.setInt(1, userId);
                    psInsert.setInt(2, productCode);
                    psInsert.setInt(3, quantityToInsert);
                    psInsert.executeUpdate();
                    System.out.println("Prodotto con codice " + productCode + " aggiunto al carrello con qty " + quantityToInsert);
                }
            }

            conn.commit();
            System.out.println("Carrello aggiornato con successo.");
        } catch (SQLException e) {
            System.out.println("Errore durante l'aggiornamento del carrello: " + e.getMessage());
            throw e;
        }
    }



}