<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, it.unisa.cart.*, it.unisa.db.*" %>
<%
    String username = (String) session.getAttribute("username");
    Boolean isAdmin = (Boolean) session.getAttribute("isAdmin");
%>


<!DOCTYPE html>
<html lang="it">
<head>
    <meta charset="UTF-8">
    <title>Carrello</title>
    <link rel="stylesheet" href="styles/styleCarrello.css">
    <script>
        var isLoggedIn = <%= (username != null) ? "true" : "false" %>;
    </script>
    <script src="scripts/cart.js" defer></script>
</head>
<body>
<jsp:include page="header.jsp" />
<main>
    <div id="cart-container">
        <!-- Qui verrà caricata dinamicamente la tabella carrello -->
    </div>
    <div id="cart-actions" style="display:none;">
        <p id="total-price"></p>
        <% if (username != null) { %>
            <button id="checkoutBtn">Effettua Ordine</button>
        <% } else { %>
            <p>Per effettuare l'ordine devi <a href="login.jsp">accedere</a>.</p>
        <% } %>
        <button id="clearCartBtn">Svuota Carrello</button>
    </div>
</main>


<jsp:include page="footer.jsp" />

<!-- Sidebar Carrello -->


</body>
</html>
