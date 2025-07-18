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
    <link rel="stylesheet" href="styles/styleSidebar.css">
    <link rel="stylesheet" href="styles/styleLogin.css">
    <link rel="icon" href="images/favicon.png" type="image/png">
    <script>
      var isLoggedIn = <%= (username != null) ? "true" : "false" %>;
    </script>
    <script src="scripts/sidebar.js" defer></script>
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

        <form action="https://localhost<%= request.getContextPath() %>/Login" method="post">
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


       	<jsp:include page="footer.jsp" />
    
</body>
</html>