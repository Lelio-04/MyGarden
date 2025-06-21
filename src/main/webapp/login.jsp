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
                <a href="login.jsp" class="icon-link" title="<%= (username != null) ? "Profilo" : "Accedi" %>">
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
                <li><a href="carrello.html">Carrello</a></li>
                <li><a href="#contattaci">Contattaci</a></li>
                <li><a href="register.jsp">Registrati</a></li>
            </ul>
        </nav>
    </header>
    
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
    
        <footer>
        <p>&copy; 2025 MyGarden - Tutti i diritti riservati.</p>
    </footer>
    
</body>
</html>
