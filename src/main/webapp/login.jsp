<%@ page import="java.util.List" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    String username = (String) session.getAttribute("username");
%>
<!DOCTYPE html>
<html lang="it">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - MyGarden</title>
    <link rel="icon" href="images/favicon.png" type="image/png">
    <link rel="stylesheet" href="styles/styleBase.css">
    <link rel="stylesheet" href="styles/styleLogin.css">
    <link rel="icon" href="images/favicon.png" type="image/png">
</head>
<body>
	
	<jsp:include page="header.jsp" />
	
	    <div class="login-container">
        <div class="login-header">
            <h2>Accedi</h2>
            <p>Benvenuto su MyGarden</p>
        </div>

        <%
        List<String> errors = (List<String>) request.getAttribute("errors");
        if (errors != null && !errors.isEmpty()) {
        %>
        <div class="form-errors">
            <ul>
                <% for (String error : errors) { %>
                <li><%= error %></li>
                <% } %>
            </ul>
        </div>
        <% } %>

        <form action="Login" method="post">
            <div class="form-group username-field">
                <label for="username">Username:</label>
                <input id="username" type="text" name="username" placeholder="Inserisci il tuo Username" required>
            </div>

            <div class="form-group password-field">
                <label for="password">Password:</label>
                <input id="password" type="password" name="password" placeholder="Inserisci la tua password" required>
            </div>

            <div class="form-buttons">
                <button type="submit" class="btn btn-login">ACCEDI</button>
                <button id = btn type="reset" class="btn btn-reset">RESETTA</button>
            </div>
        </form>

        <div class="register-link">
            <p>Non hai un account? <a href="register.jsp">Registrati qui</a></p>
        </div>
    </div>
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
       	<jsp:include page="footer.jsp" />
    
</body>
</html>
