<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Registrazione Utente</title>
    <script>
        function validateForm() {
            const email = document.forms["regForm"]["email"].value;
            const password = document.forms["regForm"]["password"].value;

            const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            if (!emailPattern.test(email)) {
                alert("Inserisci un'email valida.");
                return false;
            }

            if (password.length < 6) {
                alert("La password deve contenere almeno 6 caratteri.");
                return false;
            }

            return true;
        }
    </script>
</head>
<body>
    <h2>Registrazione Utente</h2>

    <!-- Messaggi di errore -->
    <%
        String error = request.getParameter("error");
        if ("invalid".equals(error)) {
    %>
        <p style="color:red;">Dati non validi. Controlla email e password.</p>
    <%
        } else if ("exists".equals(error)) {
    %>
        <p style="color:red;">Questa email è già registrata.</p>
    <%
        } else if ("db".equals(error)) {
    %>
        <p style="color:red;">Errore durante la registrazione. Riprova.</p>
    <%
        }
    %>

    <!-- Form registrazione -->
    <form name="regForm" action="register" method="post" onsubmit="return validateForm();">
        <label>Username:</label><br>
        <input type="text" name="username" required><br><br>

        <label>Email:</label><br>
        <input type="email" name="email" required><br><br>

        <label>Password:</label><br>
        <input type="password" name="password" required><br><br>

        <button type="submit">Registrati</button>
    </form>

    <p>Hai già un account? <a href="login.jsp">Login</a></p>
</body>
</html>
