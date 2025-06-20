<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Registrazione Utente</title>
    <link rel="stylesheet" href="styles/styleBase.css">
     <link rel="stylesheet" href="styles/styleRegister.css">
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


	  <header>
        <div class="header-top">
            <img src="images/logo.png" alt="MyGarden Logo" class="logo">
            <span class="site-title">MyGarden</span>
            <div class="header-icons">
                <a href="carrello.html" class="icon-link" title="Carrello">
                    <svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <circle cx="9" cy="21" r="1"></circle>
                        <circle cx="20" cy="21" r="1"></circle>
                        <path d="m1 1 4 4 14 1-1 9H6"></path>
                    </svg>
                </a>
                <a href="login.jsp" class="icon-link" title="Profilo">
                    <svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path>
                        <circle cx="12" cy="7" r="4"></circle>
                    </svg>
                </a>
                <a href="register.jsp" class="icon-link" title="Registrati">
                    <svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"></path>
                        <circle cx="9" cy="7" r="4"></circle>
                        <path d="m22 11-3-3m0 0-3 3m3-3v12"></path>
                    </svg>
                </a>
            </div>
        </div>
        <nav class="main-nav">
            <ul class="nav-links">
                <li><a href="index.jsp">Home</a></li>
                <li><a href="catalogo.jsp">Catalogo</a></li>
                <li><a href="login.jsp">Login</a></li>
                <li><a href="carrello.jsp">Carrello</a></li>
                <li><a href="#contattaci">Contattaci</a></li>
            </ul>
        </nav>
    </header>



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
    
     <footer>
        <p>&copy; 2025 MyGarden - Tutti i diritti riservati.</p>
    </footer>
</body>
</html>
