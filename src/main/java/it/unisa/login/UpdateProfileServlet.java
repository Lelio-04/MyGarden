package it.unisa.login;
 // <--- SOSTITUISCI CON IL NOME DEL TUO PACKAGE REALE

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException; // Importa SQLException
import javax.sql.DataSource; // Importa DataSource
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/UpdateProfileServlet")
public class UpdateProfileServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        String username = (String) session.getAttribute("username");

        // 1. Controllo di autenticazione: Se l'utente non è loggato, reindirizza al login
        if (username == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        // 2. Recupera i dati inviati dal form (i parametri 'name' degli input nella JSP)
        // Nota: non recuperiamo 'username' dal form perché lo prendiamo dalla sessione per sicurezza.
        String email = request.getParameter("email");
        String telefono = request.getParameter("telefono");
        String dataNascita = request.getParameter("dataNascita");
        String indirizzo = request.getParameter("indirizzo");
        String citta = request.getParameter("citta");
        String provincia = request.getParameter("provincia");
        String cap = request.getParameter("cap");

        DataSource ds = (DataSource) getServletContext().getAttribute("DataSourceUtenti");
        Connection conn = null;
        PreparedStatement ps = null;
        String status = "error"; // Inizializza lo stato a 'error' di default

        try {
            // 3. Ottieni una connessione dal DataSource
            if (ds == null) {
                throw new ServletException("DataSource 'DataSourceUtenti' non trovato nel ServletContext.");
            }
            conn = ds.getConnection();

            // 4. Prepara la query SQL per l'aggiornamento
            // Usiamo PreparedStatement per prevenire SQL injection
            String sql = "UPDATE users SET email = ?, telefono = ?, data_nascita = ?, " +
                         "indirizzo = ?, citta = ?, provincia = ?, cap = ? WHERE username = ?";
            ps = conn.prepareStatement(sql);

            // 5. Imposta i parametri nella PreparedStatement
            // Assicurati che l'ordine e il tipo dei parametri corrispondano ai '?' nella query SQL
            ps.setString(1, email);
            ps.setString(2, telefono);
            ps.setString(3, dataNascita); // Assicurati che il formato della data sia compatibile con il DB
            ps.setString(4, indirizzo);
            ps.setString(5, citta);
            ps.setString(6, provincia);
            ps.setString(7, cap);
            ps.setString(8, username); // L'username della sessione è la condizione WHERE

            // 6. Esegui la query di aggiornamento
            int rowsAffected = ps.executeUpdate(); // Restituisce il numero di righe modificate

            if (rowsAffected > 0) {
                status = "success"; // Se almeno una riga è stata modificata, l'aggiornamento è riuscito
                // Potresti anche aggiornare gli attributi di sessione se li usi altrove
                // session.setAttribute("email", email);
                // ...e così via per gli altri campi che potrebbero essere visualizzati
            } else {
                // Nessuna riga modificata, potrebbe indicare che l'username non è stato trovato (improbabile se loggato)
                status = "error";
            }

        } catch (SQLException e) {
            e.printStackTrace(); // Stampa lo stack trace per il debug nel log del server
            // In un'applicazione reale, dovresti loggare questo errore con un framework di logging
            status = "error";
        } catch (ServletException e) {
            e.printStackTrace(); // Logga l'errore di DataSource non trovato
            status = "error";
        } finally {
            // 7. Chiudi le risorse del database per evitare memory leak
            try {
                if (ps != null) ps.close();
            } catch (SQLException se) {
                se.printStackTrace();
            }
            try {
                if (conn != null) conn.close();
            } catch (SQLException se) {
                se.printStackTrace();
            }
        }

        // 8. Reindirizza l'utente alla pagina del profilo con un messaggio di stato
        // Questo parametro 'status' verrà letto dalla JSP per mostrare il feedback all'utente
        response.sendRedirect("profilo.jsp?status=" + status);
    }
}