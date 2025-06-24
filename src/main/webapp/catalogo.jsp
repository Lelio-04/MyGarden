<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, it.unisa.cart.*, it.unisa.db.*" %>
<%
    Collection<?> products = (Collection<?>) request.getAttribute("products");
    if (products == null) {
        response.sendRedirect("./product");
        return;
    }
    String username = (String) session.getAttribute("username");
    Boolean isAdmin = (Boolean) session.getAttribute("isAdmin");
%>

<!DOCTYPE html>
<html lang="it">
<head>
    <meta charset="UTF-8">
    <title>Catalogo Prodotti</title>
    <link rel="stylesheet" href="styles/styleBase.css">
    <link rel="stylesheet" href="styles/styleCatalogo.css">
    <link rel="icon" href="images/favicon.png" type="image/png">
</head>
<body>
<header>
    <div class="header-top">
        <img src="images/logo.png" alt="MyGarden Logo" class="logo">
        <span class="site-title"><span class="yellow">My</span><span class="green">Garden</span></span>
        <div class="header-icons">
            <a href="cart" class="icon-link" title="Carrello">
                <svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <circle cx="9" cy="21" r="1"></circle>
                    <circle cx="20" cy="21" r="1"></circle>
                    <path d="m1 1 4 4 14 1-1 9H6"></path>
                </svg>
            </a>
            <a href="<%= (username != null) ? "profilo.jsp" : "login.jsp" %>" class="icon-link" title="<%= (username != null) ? "Profilo" : "Accedi" %>">
                <svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path>
                    <circle cx="12" cy="7" r="4"></circle>
                </svg>
            </a>
            <% if (username == null) { %>
            <a href="register.jsp" class="icon-link" title="Registrati">
                <svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"></path>
                    <circle cx="9" cy="7" r="4"></circle>
                    <path d="m22 11-3-3m0 0-3 3m3-3v12"></path>
                </svg>
            </a>
            <% } %>
        </div>
    </div>

    <nav class="main-nav">
        <ul class="nav-links">
            <li><a href="index.jsp">Home</a></li>
            <li><a href="<%=request.getContextPath()%>/product" id="signed"><%= (isAdmin != null && isAdmin) ? "Gestione Catalogo" : "Catalogo" %></a></li>
            <li><a href="cart"><%= (isAdmin != null && isAdmin) ? "Gestione Ordini" : "Carrello" %></a></li>
            
            <% if (username != null) { %>
                <li><a href="Logout">Logout</a></li>
            <% } else { %>
                <li><a href="login.jsp">Accedi</a></li>
            <% } %>
        </ul>
    </nav>
</header>

<main class="catalog-container">
    <div class="catalog-grid">
        <%
            if (!products.isEmpty()) {
                for (Object obj : products) {
                    ProductBean bean = (ProductBean) obj;
        %>
        <div class="product-card">
            <a href="DettaglioProdottoServlet?code=<%= bean.getCode() %>">
                <img src="<%= bean.getImage() %>" alt="<%= bean.getName() %>">
            </a>
            <h3><%= bean.getName() %></h3>
            <p class="price">€ <%= String.format("%.2f", bean.getPrice()) %></p>
            <form action="AddToCartServlet" method="post">
                <input type="hidden" name="productCode" value="<%= bean.getCode() %>">
                <div class="quantity-row">
                    <span class="available">Disponibilità: <%= bean.getQuantity() %></span>
                    <input type="number" name="quantity" value="1" min="1" max="<%= bean.getQuantity() %>" required>
                </div>
                <input type="submit" value="Aggiungi al Carrello">
            </form>
        </div>
        <%
                }
            } else {
        %>
        <p>Nessun prodotto disponibile.</p>
        <% } %>
    </div>
</main>
	<footer>
        <p>&copy; 2025 MyGarden - Tutti i diritti riservati.</p>
    </footer>
</body>
</html>
