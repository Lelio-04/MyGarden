package it.unisa.cart;

import java.sql.SQLException;
import java.util.List;

import it.unisa.db.ProductBean;

public interface ICartDao {

    boolean addToCart(int userId, int productCode, int quantity) throws SQLException;


    List<CartBean> getCartItems(int userId) throws SQLException;

    void updateQuantity(int userId, int productCode, int newQuantity) throws SQLException;

    void removeItem(int userId, int productCode) throws SQLException;

    void clearCart(int userId) throws SQLException;

    int getProductQuantityInCart(int userId, int productCode) throws SQLException;

    ProductBean getProductDetails(int productCode) throws SQLException;
    
    boolean insertToCart(int userId, int productCode, int quantity) throws SQLException;
}