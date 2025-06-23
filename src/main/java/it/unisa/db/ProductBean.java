package it.unisa.db;

import java.io.Serializable;

public class ProductBean implements Serializable {

    private static final long serialVersionUID = 1L;
    
    private int code;
    private String name;
    private String description;
    private double price; // Cambiato da int a double
    private int quantity;
    private String image;

    public ProductBean() {
        this.code = -1;
        this.name = "";
        this.description = "";
        this.price = 0.0;
        this.quantity = 0;
        this.image = "";
    }

    public int getCode() {
        return code;
    }

    public void setCode(int code) {
        this.code = code;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public double getPrice() {
        return price;
    }

    public void setPrice(double price) {
        this.price = price;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public String getImage() {
        return image;
    }

    public void setImage(String image) {
        this.image = image;
    }

    @Override
    public String toString() {
        return name + " (" + code + "), " + price + "€ - Quantità: " + quantity + ". " + description + " " + image;
    }
}
