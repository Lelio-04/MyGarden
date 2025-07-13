package it.unisa.order;

import java.sql.Timestamp;
import java.util.List;

public class OrderBean {
    private int id;
    private int userId;
    private Timestamp createdAt;
    private double total;

    // ✅ Nuovo campo per i prodotti acquistati
    private List<OrderItemBean> orderItems;

    // Getter e Setter
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public double getTotal() { return total; }
    public void setTotal(double total) { this.total = total; }

    // ✅ Getter e Setter per i prodotti associati all'ordine
    public List<OrderItemBean> getOrderItems() {
        return orderItems;
    }

    public void setOrderItems(List<OrderItemBean> orderItems) {
        this.orderItems = orderItems;
    }
}
