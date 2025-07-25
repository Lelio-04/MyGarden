package it.unisa.cart;

import it.unisa.db.*;

public class CartBean {
    private int id;
    private int userId;
    private int productCode;
    private int quantity;
    private ProductBean product; //Collegamento a prodotto

    public CartBean(int productCode, int quantity, ProductBean product) {
        this.productCode = productCode;
        this.quantity = quantity;
        this.product = product;
    }

    public CartBean() {

    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public int getProductCode() {
        return productCode;
    }

    public void setProductCode(int productCode) {
        this.productCode = productCode;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public ProductBean getProduct() {
        return product;
    }

    public void setProduct(ProductBean product) {
        this.product = product;
    }

    public double getSubtotal() {
        if (product != null) {
            return product.getPrice()*quantity;
        }
        return 0;
    }
} 
