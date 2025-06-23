package it.unisa.cart;

import java.sql.SQLException;
import java.util.List;

public interface ICartDao {

    void addToCart(int userId, int productCode, int quantity) throws SQLException;

    List<CartBean> getCartItems(int userId) throws SQLException;

    void updateQuantity(int userId, int productCode, int newQuantity) throws SQLException;

    void removeItem(int userId, int productCode) throws SQLException;

    void clearCart(int userId) throws SQLException;
}
