package it.unisa.order;

public class OrderItemBean {
    private String productName;
    private int quantity;
    private double priceAtPurchase;
    private String productImage;

    // ✅ Costruttore vuoto obbligatorio per JavaBean (JSP, JSON, BeanUtils)
    public OrderItemBean() {}

    // ✅ Costruttore opzionale completo (utile nei test o DAO)
    public OrderItemBean(String productName, int quantity, double priceAtPurchase, String productImage) {
        this.productName = productName;
        this.quantity = quantity;
        this.priceAtPurchase = priceAtPurchase;
        this.productImage = productImage;
    }

    public String getProductName() {
        return productName;
    }

    public void setProductName(String productName) {
        this.productName = productName;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public double getPriceAtPurchase() {
        return priceAtPurchase;
    }

    public void setPriceAtPurchase(double priceAtPurchase) {
        this.priceAtPurchase = priceAtPurchase;
    }

    public String getProductImage() {
        return productImage;
    }

    public void setProductImage(String productImage) {
        this.productImage = productImage;
    }

    // ✅ Utile per debug/log
    @Override
    public String toString() {
        return "OrderItemBean{" +
                "productName='" + productName + '\'' +
                ", quantity=" + quantity +
                ", priceAtPurchase=" + priceAtPurchase +
                ", productImage='" + productImage + '\'' +
                '}';
    }
}
