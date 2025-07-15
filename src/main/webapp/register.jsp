<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String username = (String) session.getAttribute("username");
%>
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

<jsp:include page="header.jsp" />

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

<jsp:include page="footer.jsp" />

<!-- ✅ AJAX per autocompletamento città e provincia -->
<script>
document.addEventListener("DOMContentLoaded", function () {
    const capInput = document.getElementById("cap");
    const cittaInput = document.getElementById("citta");
    const provinciaInput = document.getElementById("provincia");

    capInput.addEventListener("blur", function () {
        const cap = capInput.value.trim();
        if (cap.length === 5 && /^[0-9]{5}$/.test(cap)) {
            fetch("GetComuneProvincia?cap=" + encodeURIComponent(cap))
                .then(response => {
                    if (!response.ok) throw new Error("Errore nella risposta del server");
                    return response.json();
                })
                .then(data => {
                    if (data.success) {
                        if (data.city) cittaInput.value = data.city;
                        if (data.provincia) provinciaInput.value = data.provincia;
                    }
                })
                .catch(error => {
                    console.error("Errore AJAX:", error);
                });
        }
    });
});
</script>
<div id="sidebar-carrello" style="display:none; position: fixed; right: 0; top: 0; width: 350px; height: 100vh; background: white; border-left: 1px solid #ccc; padding: 20px; overflow-y: auto; z-index: 10000; box-shadow: -2px 0 10px rgba(0,0,0,0.2);">
    <button onclick="chiudiSidebar()" style="float:right; font-size: 20px; border:none; background:none; cursor:pointer;">&times;</button>
    <h3>🛒 Il tuo carrello</h3>
    <div id="carrello-items"></div>
    <hr>
    <strong>Totale: €<span id="carrello-totale">0.00</span></strong>
    <br><br>
    <button onclick="svuotaCarrello()" style="background:#e53935; color:white; border:none; padding:10px; cursor:pointer; border-radius:5px;">Svuota Carrello</button>
    
    <!-- Sezione acquisto o login -->
    <div id="checkout-section" style="margin-top: 20px; text-align: center;"></div>
</div>

<script>
  const isLoggedIn = <%= (username != null) ? "true" : "false" %>;
</script>
<script src="scripts/sidebar.js"></script>
</body>
</html>
