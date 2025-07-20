package it.unisa.register;

public class User {
	private int id;
    private String username;
    private String email;
    private String password;
    private String telefono;
    private String dataNascita;
    private String indirizzo;
    private String citta;
    private String provincia;
    private String cap;

    public User(String username, String email, String password, String telefono,
                String dataNascita, String indirizzo, String citta,
                String provincia, String cap) {
        this.username = username;
        this.email = email;
        this.password = password;
        this.telefono = telefono;
        this.dataNascita = dataNascita;
        this.indirizzo = indirizzo;
        this.citta = citta;
        this.provincia = provincia;
        this.cap = cap;
    }

    public User(String username, String email, String password) {
        this(username, email, password, "", "", "", "", "", "");
    }

    //Getter e Setter
    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getTelefono() {
        return telefono;
    }

    public void setTelefono(String telefono) {
        this.telefono = telefono;
    }

    public String getDataNascita() {
        return dataNascita;
    }

    public void setDataNascita(String dataNascita) {
        this.dataNascita = dataNascita;
    }

    public String getIndirizzo() {
        return indirizzo;
    }

    public void setIndirizzo(String indirizzo) {
        this.indirizzo = indirizzo;
    }

    public String getCitta() {
        return citta;
    }

    public void setCitta(String citta) {
        this.citta = citta;
    }

    public String getProvincia() {
        return provincia;
    }

    public void setProvincia(String provincia) {
        this.provincia = provincia;
    }

    public String getCap() {
        return cap;
    }

    public void setCap(String cap) {
        this.cap = cap;
    }
    
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

}
