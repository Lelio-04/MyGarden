package it.unisa.order;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class OrderBean {
    private int id;
    private int userId;
    private Timestamp createdAt;
    private double total;

    private List<OrderItemBean> orderItems = new ArrayList<>();

    public OrderBean() {}

    //Getter e Setter
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

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public double getTotal() {
        return total;
    }

    public void setTotal(double total) {
        this.total = total;
    }

    public List<OrderItemBean> getOrderItems() {
        return orderItems;
    }

    public void setOrderItems(List<OrderItemBean> orderItems) {
        if (orderItems != null) {
            this.orderItems = orderItems;
        } else {
            this.orderItems = new ArrayList<>();
        }
    }
}
