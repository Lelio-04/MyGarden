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
    <script src="scripts/sidebar.js" defer></script>
</head>
<body>
<jsp:include page="header.jsp" />
<main>
    <!-- Sidebar come carrello -->
</main>
<div id="cartSidebar" class="cart-sidebar">
    <h2>Il tuo Carrello</h2>
    <div id="cart-items">
        <p class="empty-cart-message">Il carrello è vuoto.</p>
    </div>
    <div class="cart-total">
        <span>Totale:</span>
        <span id="cart-total-price">€0.00</span>
    </div>
    <button class="checkout-btn" onclick="checkout()">Procedi al Checkout</button>
</div>
<jsp:include page="footer.jsp" />

<!-- Sidebar Carrello -->


</body>
</html>
