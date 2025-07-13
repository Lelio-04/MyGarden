package it.unisa.login;

import java.io.IOException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/Logout")
public class Logout extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false); // Non crea una nuova sessione

        if (session != null) {
            System.out.println("🔒 Logout utente: " + session.getAttribute("username"));
            session.invalidate(); // Invalida la sessione
            System.out.println("✅ Sessione invalidata");
        } else {
            System.out.println("⚠️ Nessuna sessione attiva da invalidare");
        }

        response.sendRedirect("index.jsp");
    }
}
