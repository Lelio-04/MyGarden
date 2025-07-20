package it.unisa.register;

import java.io.IOException;
import javax.sql.DataSource;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/register")
public class RegisterServletControl extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws IOException {
        String username = req.getParameter("username");
        String email = req.getParameter("email");
        String password = req.getParameter("password");

        String telefono = req.getParameter("telefono");
        String dataNascita = req.getParameter("dataNascita");
        String indirizzo = req.getParameter("indirizzo");
        String citta = req.getParameter("citta");
        String provincia = req.getParameter("provincia");
        String cap = req.getParameter("cap");

        if (username != null) username = username.trim();
        if (email != null) email = email.trim();
        if (password != null) password = password.trim();

        if (username == null || username.isEmpty() ||
            email == null || !isValidEmail(email) ||
            password == null || !isValidPassword(password)) {
            res.sendRedirect("register.jsp?error=input");
            return;
        }

        DataSource ds = (DataSource) getServletContext().getAttribute("DataSourceUtenti");
        if (ds == null) {
            res.sendRedirect("register.jsp?error=datasource");
            return;
        }

        UserDAO dao = new UserDAO(ds);

        if (dao.usernameExists(username)) {
            res.sendRedirect("register.jsp?error=username_taken");
            return;
        }

        if (dao.emailExists(email)) {
            res.sendRedirect("register.jsp?error=email_taken");
            return;
        }

        User user = new User(username, email, password);
        user.setTelefono(telefono);
        user.setDataNascita(dataNascita);
        user.setIndirizzo(indirizzo);
        user.setCitta(citta);
        user.setProvincia(provincia);
        user.setCap(cap);

        boolean success = dao.register(user);

        if (success) {
            res.sendRedirect("login.jsp?success=1");
        } else {
            res.sendRedirect("register.jsp?error=db");
        }
    }

    private boolean isValidEmail(String email) {
        return email.matches("^[\\w.-]+@[\\w.-]+\\.[A-Za-z]{2,6}$");
    }

    private boolean isValidPassword(String password) {
        return password.length() >= 6;
    }
}
