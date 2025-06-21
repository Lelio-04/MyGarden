<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Registrazione Utente</title>
    <link rel="stylesheet" href="styles/styleBase.css">
     <link rel="stylesheet" href="styles/styleRegister.css">
     <link rel="icon" href="images/favicon.png" type="image/png">
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



<div class="register-container">
    <div class="register-header">
        <h2>Registrazione</h2>
        <p>Crea un nuovo account su MyGarden</p>
    </div>

    <% String error = request.getParameter("error"); %>
    <% if ("invalid".equals(error)) { %>
        <div class="form-errors">Dati non validi. Controlla email e password.</div>
    <% } else if ("exists".equals(error)) { %>
        <div class="form-errors">Questa email è già registrata.</div>
    <% } else if ("db".equals(error)) { %>
        <div class="form-errors">Errore durante la registrazione. Riprova.</div>
    <% } %>

<form name="regForm" action="register" method="post" onsubmit="return validateForm();">
    <div class="form-group">
        <label for="username">Username:</label>
        <input id="username" type="text" name="username" placeholder="Inserisci il tuo Username" required>
    </div>

    <div class="form-group">
        <label for="email">Email:</label>
        <input id="email" type="email" name="email" placeholder="Inserisci la tua email" required>
    </div>

    <div class="form-group">
        <label for="password">Password:</label>
        <input id="password" type="password" name="password" placeholder="Inserisci la tua password" required>
    </div>

    <div class="form-group">
        <label for="telefono">Telefono:</label>
        <input id="telefono" type="tel" name="telefono" pattern="[0-9]{10}" placeholder="Es: 3201234567" required>
    </div>

    <div class="form-group">
        <label for="dataNascita">Data di Nascita:</label>
        <input id="dataNascita" type="date" name="dataNascita" required>
    </div>

    <div class="form-group">
        <label for="indirizzo">Indirizzo:</label>
        <input id="indirizzo" type="text" name="indirizzo" placeholder="Via/Piazza e numero civico" required>
    </div>

    <div class="form-group">
        <label for="citta">Città:</label>
        <input id="citta" type="text" name="citta" placeholder="Inserisci la tua città" required>
    </div>

    <div class="form-group">
        <label for="provincia">Provincia:</label>
        <input id="provincia" type="text" name="provincia" placeholder="Es: NA, MI, RM" maxlength="2" required>
    </div>

    <div class="form-group">
        <label for="cap">CAP:</label>
        <input id="cap" type="text" name="cap" pattern="[0-9]{5}" placeholder="Es: 80100" required>
    </div>

    <button type="submit" class="btn">REGISTRATI</button>
</form>


    <div class="register-link">
        <p>Hai già un account? <a href="login.jsp">Accedi qui</a></p>
    </div>
</div>
    
     <footer>
        <p>&copy; 2025 MyGarden - Tutti i diritti riservati.</p>
    </footer>
</body>
</html>
