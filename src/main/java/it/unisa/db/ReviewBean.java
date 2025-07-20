package it.unisa.db;

public class ReviewBean {
    private int id;
    private int prodottoId;
    private String user;
    private int stars;
    private String text;

    public ReviewBean() {}

    public ReviewBean(String user, int stars, String text) {
        this.user = user;
        this.stars = stars;
        this.text = text;
    }

    //Getter e setter
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getProdottoId() { return prodottoId; }
    public void setProdottoId(int prodottoId) { this.prodottoId = prodottoId; }

    public String getUser() { return user; }
    public void setUser(String user) { this.user = user; }

    public int getStars() { return stars; }
    public void setStars(int stars) { this.stars = stars; }

    public String getText() { return text; }
    public void setText(String text) { this.text = text; }
}
