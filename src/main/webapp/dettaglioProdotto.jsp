<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="it.unisa.db.ProductBean" %>
<%
    ProductBean product = (ProductBean) request.getAttribute("product");
    if (product == null) {
        response.sendRedirect("product");
        return;
    }
    String username = (String) session.getAttribute("username");
%>

<!DOCTYPE html>
<html lang="it">
<head>
    <meta charset="UTF-8">
    <title><%= product.getName() %> - Dettaglio</title>
    <link rel="stylesheet" href="styles/styleBase.css">
    <link rel="stylesheet" href="styles/styleDettaglio.css">
</head>
<body>

    <header>
        <div class="header-top">
            <img src="images/logo.png" alt="MyGarden Logo" class="logo">
            <span class="site-title">
            	<span class="yellow">My</span><span class="green">Garden</span>
            </span>
            <div class="header-icons">
                <a href="carrello.jsp" class="icon-link" title="Carrello">
                    <svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <circle cx="9" cy="21" r="1"></circle>
                        <circle cx="20" cy="21" r="1"></circle>
                        <path d="m1 1 4 4 14 1-1 9H6"></path>
                    </svg>
                </a>

                <!-- Icona profilo dinamica -->
                <a href="<%= (username != null) ? "profilo.jsp" : "login.jsp" %>" class="icon-link" title="<%= (username != null) ? "Profilo" : "Accedi" %>">
                    <svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path>
                        <circle cx="12" cy="7" r="4"></circle>
                    </svg>
                </a>

                <!-- Registrazione sempre visibile -->
                <% if (username != null) { %>
                    
                <% } else { %>
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
                <li><a href="index.jsp" id = "signed">Home</a></li>
                <% Boolean isAdmin = (Boolean) request.getSession().getAttribute("isAdmin");  
                   if(isAdmin != null && isAdmin){
                	
                
                %>
                    <li><a href="<%=request.getContextPath()%>/product">Gestione Catalogo</a></li>
                <% } else { %>
                    <li><a href="<%=request.getContextPath()%>/product">Catalogo</a></li>
                <% } %>
                <% Boolean isAdmin2 = (Boolean) request.getSession().getAttribute("isAdmin");  
                   if(isAdmin2 != null && isAdmin2){
                
                
                %>
                    <li><a href="carrello.jsp">Gestione Ordini</a></li>
                <% } else { %>
                    <li><a href="carrello.jsp">Carrello</a></li>
                <% } %>
                <% Boolean isAdmin3 = (Boolean) request.getSession().getAttribute("isAdmin");  
                   if(isAdmin3 != null && isAdmin3){
                	
                
                %>
                    
                <% } %>
                
                <% if (username != null) { %>
                    <li><a href="Logout">Logout</a></li>
                <% } else { %>
                    <li><a href="login.jsp">Accedi</a></li>
                <% } %>
            </ul>
        </nav>
    </header>


<main class="product-detail-container">
    <div class="product-detail-card">
        <img class="product-image" src="<%= product.getImage() %>" alt="<%= product.getName() %>">

        <div class="product-info">
    <h1><%= product.getName() %></h1>
    <p class="price">Prezzo: € <%= String.format("%.2f", product.getPrice()) %></p>
    <p class="description"><%= product.getDescription() %></p>

    <form action="AddToCartServlet" method="post" class="add-to-cart-form">
        <input type="hidden" name="productCode" value="<%= product.getCode() %>">
        
        <div class="quantity-section">
            <p class="availability">Disponibilità: <%= product.getQuantity() %> unità</p>
            <div class="quantity-row">
                <label for="quantity">Quantità:</label>
                <input type="number" id="quantity" name="quantity" value="1" min="1" max="<%= product.getQuantity() %>" required>
            </div>
        </div>
        
        <input type="submit" value="Aggiungi al carrello">
    </form>
</div>
    </div>
</main>
	<footer>
        <p>&copy; 2025 MyGarden - Tutti i diritti riservati.</p>
    </footer>
</body>
</html>
