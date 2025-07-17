package it.unisa.cart;

import it.unisa.db.*;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import javax.sql.DataSource;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.util.*;

@WebServlet("/update-cart")
public class UpdateCartServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private ICartDao cartDao;

    @Override
    public void init() throws ServletException {
        // Inizializzazione della fonte di dati
        DataSource ds = (DataSource) getServletContext().getAttribute("DataSourceStorage");
        if (ds == null) {
            throw new ServletException("DataSource non disponibile nel contesto.");
        }
        cartDao = new CartDAO(ds); // Usa il tuo CartDAO
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        System.out.println("Servlet 'update-cart' chiamata");
        response.setContentType("application/json");
        PrintWriter out = response.getWriter();
        HttpSession session = request.getSession(true);
        Integer userId = (Integer) session.getAttribute("userId");

        try {
            if (userId == null) {
                out.print("{\"success\":false, \"error\":\"Utente non loggato.\"}");
                return; // Non possiamo aggiornare il carrello se l'utente non è loggato
            }

            // Ricevi il carrello unito in formato JSON
            StringBuilder jsonRequest = new StringBuilder();
            String line;
            while ((line = request.getReader().readLine()) != null) {
                jsonRequest.append(line);
            }

            // Log per verificare cosa ricevi
            System.out.println("Dati carrello ricevuti: " + jsonRequest.toString());

            // Parso il carrello unito (contenente anche i dettagli dei prodotti)
            String requestData = jsonRequest.toString();

            // Ottieni il flag isMerged (se è presente nel JSON)
            boolean isMerged = requestData.contains("\"isMerged\":true");

            // Log per il flag isMerged e carrello in uso
            if (isMerged) {
                System.out.println("Stiamo usando il carrello unito per sovrascrivere.");
            } else {
                System.out.println("Stiamo usando il carrello non unito per aggiungere articoli.");
            }

            // Estrai la parte del carrello vero e proprio (carrello dei prodotti)
            String cartData = requestData.substring(requestData.indexOf("[") + 1, requestData.lastIndexOf("]"));
            // Converte il carrello JSON in una lista di oggetti CartBean
            List<CartBean> cartItems = parseCartData(cartData);

            // Sovrascrivi o aggiungi i prodotti nel database
            if (isMerged) {
                overwriteUserCartInDb(userId, cartItems, out);  // Sovrascrive il carrello nel DB
            } else {
                addToUserCartInDb(userId, cartItems, out, isMerged);  // Aggiungi i prodotti al carrello
            }

            // Risposta JSON positiva
            out.print("{\"success\":true}");
            System.out.println("Carrello aggiornato con successo.");
        } catch (Exception e) {
            // Risposta di errore JSON
            String errorMsg = e.getMessage() != null ? e.getMessage().replace("\"", "\\\"") : "Errore sconosciuto";
            out.print("{\"success\":false,\"error\":\"" + errorMsg + "\"}");
            System.out.println("Errore durante l'aggiornamento del carrello: " + errorMsg);
        } finally {
            out.flush(); // Assicurati di fare il flush per inviare la risposta
        }
    }

    // Funzione per analizzare i dati del carrello unito in JSON senza librerie esterne
    private List<CartBean> parseCartData(String jsonData) {
        List<CartBean> cartItems = new ArrayList<>();

        // Dividi i dati sui separatori di campo (ogni elemento del carrello)
        String[] itemDataArray = jsonData.split("},\\{");

        // Per ogni elemento del carrello, estrai i dati
        for (String itemData : itemDataArray) {
            itemData = itemData.trim();
            if (itemData.startsWith("{")) itemData = itemData.substring(1);
            if (itemData.endsWith("}")) itemData = itemData.substring(0, itemData.length() - 1);

            // Estrai i vari campi (id, name, price, quantity)
            String[] fields = itemData.split(",");
            String id = null;
            int quantity = 0;

            // Variabili per i dettagli del prodotto
            String productName = null;
            double productPrice = 0;

            for (String field : fields) {
                String[] keyValue = field.split(":");
                if (keyValue.length == 2) {
                    String key = keyValue[0].trim().replaceAll("\"", "");
                    String value = keyValue[1].trim().replaceAll("\"", "");

                    // Identifica i vari campi e crea un oggetto CartBean
                    switch (key) {
                        case "id":
                            id = value;
                            break;
                        case "quantity":
                            quantity = Integer.parseInt(value);
                            break;
                        case "name":
                            productName = value;
                            break;
                        case "price":
                            productPrice = Double.parseDouble(value);
                            break;
                    }
                }
            }

            // Log per verificare i dati parsati
            System.out.println("Dati carrello parsati: id=" + id + ", quantity=" + quantity + ", name=" + productName + ", price=" + productPrice);

            if (id != null) {
                int productCode = Integer.parseInt(id); // L'ID del prodotto
                ProductBean product = new ProductBean(productCode, productName, productPrice, false);
                CartBean cartItem = new CartBean(productCode, quantity, product);
                cartItems.add(cartItem);
            }
        }

        return cartItems;
    }

    // Funzione per aggiungere al carrello dell'utente
    private void addToUserCartInDb(Integer userId, List<CartBean> cartItems, PrintWriter out, boolean isMerge) throws SQLException {
        for (CartBean cartItem : cartItems) {
            int productCode = cartItem.getProductCode();
            int quantity = cartItem.getQuantity();

            // Verifica la disponibilità del prodotto
            ProductBean product = cartDao.getProductDetails(productCode);
            if (product == null || product.isDeleted()) {
                out.print("{\"success\":false, \"error\":\"Prodotto non disponibile o eliminato.\"}");
                return;
            }

            // Verifica se la quantità richiesta è valida
            if (quantity <= product.getQuantity()) {
                // Logica in base al valore di isMerge
                if (isMerge) {
                    // Sovrascrivi la quantità nel carrello
                    cartDao.addToCart(userId, productCode, quantity, true); // passiamo true per sovrascrivere
                    System.out.println("Prodotto con codice " + productCode + " sovrascritto nel carrello.");
                } else {
                    // Somma la quantità al carrello
                    cartDao.addToCart(userId, productCode, quantity, false); // passiamo false per sommare
                    System.out.println("Prodotto con codice " + productCode + " aggiunto al carrello.");
                }
            } else {
                out.print("{\"success\":false, \"error\":\"Quantità richiesta maggiore della disponibilità.\"}");
                return;
            }
        }
    }

    // Funzione per sovrascrivere il carrello dell'utente
    private void overwriteUserCartInDb(Integer userId, List<CartBean> cartItems, PrintWriter out) throws SQLException {
        // Prima svuotiamo il carrello esistente
        cartDao.clearCart(userId);
        System.out.println("Carrello utente " + userId + " svuotato.");

        // Aggiungi i nuovi articoli nel carrello dell'utente
        for (CartBean cartItem : cartItems) {
            int productCode = cartItem.getProductCode();
            int quantity = cartItem.getQuantity();

            // Verifica la disponibilità del prodotto
            ProductBean product = cartDao.getProductDetails(productCode);
            if (product == null || product.isDeleted()) {
                out.print("{\"success\":false, \"error\":\"Prodotto non disponibile o eliminato.\"}");
                return;
            }

            // Verifica se la quantità richiesta è valida
            if (quantity <= product.getQuantity()) {
                // Sovrascrivi la quantità nel carrello
                cartDao.addToCart(userId, productCode, quantity, true); // Passiamo true per sovrascrivere
                System.out.println("Prodotto con codice " + productCode + " aggiunto al carrello. Sovrascritto");
            } else {
                out.print("{\"success\":false, \"error\":\"Quantità richiesta maggiore della disponibilità.\"}");
                return;
            }
        }
    }
}