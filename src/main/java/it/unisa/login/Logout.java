package it.unisa.login;

import java.io.IOException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/Logout")
public class Logout extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        // Invalida la sessione corrente
        if (request.getSession(false) != null) {
            request.getSession().invalidate();
        }

        // Reindirizza alla homepage o alla login
        response.sendRedirect("index.jsp");  // oppure "login.jsp" se preferisci
    }
}
