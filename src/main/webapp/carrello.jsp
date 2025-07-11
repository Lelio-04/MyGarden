<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, it.unisa.cart.*, it.unisa.db.*" %>
<%
    List<CartBean> cartItems = (List<CartBean>) request.getAttribute("cartItems");
    if (cartItems == null) {
        response.sendRedirect("cart");
        return;
    }
    String username = (String) session.getAttribute("username");
    Boolean isAdmin = (Boolean) session.getAttribute("isAdmin");
    double total = 0;
%>

<!DOCTYPE html>
<html lang="it">
<head>
    <meta charset="UTF-8">
    <title>Carrello</title>
    <link rel="stylesheet" href="styles/styleBase.css">
    <link rel="stylesheet" href="styles/styleCarrello.css">
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
                <li><a href="index.jsp">Home</a></li>
                <% Boolean isAdmin4 = (Boolean) request.getSession().getAttribute("isAdmin");  
                   if(isAdmin4 != null && isAdmin4){
                	
                
                %>
                    <li><a href="<%=request.getContextPath()%>/product">Gestione Catalogo</a></li>
                <% } else { %>
                    <li><a href="<%=request.getContextPath()%>/product">Catalogo</a></li>
                <% } %>
                <% Boolean isAdmin2 = (Boolean) request.getSession().getAttribute("isAdmin");  
                   if(isAdmin2 != null && isAdmin2){
                
                
                %>
                    <li><a href="carrello.jsp" id = "signed">Gestione Ordini</a></li>
                <% } else { %>
                    <li><a href="carrello.jsp" id = "signed">Carrello</a></li>
                <% } %>
                <% Boolean isAdmin3 = (Boolean) request.getSession().getAttribute("isAdmin");  
                   if(isAdmin3 != null && isAdmin3){
                	
                
                %>
                    
                <% }  %>
                
                <% if (username != null) { %>
                    <li><a href="Logout">Logout</a></li>
                <% } else { %>
                    <li><a href="login.jsp">Accedi</a></li>
                <% } %>
            </ul>
        </nav>
    </header>

<main>
    <form action="update-cart" method="post">
        <div class="table-container">
            <table>
                <thead>
                <tr>
                    <th>Immagine</th>
                    <th>Prodotto</th>
                    <th>Prezzo</th>
                    <th>Quantità</th>
                    <th>Subtotale</th>
                    <th>Azione</th>
                </tr>
                </thead>
                <tbody>
                <%
                    if (!cartItems.isEmpty()) {
                        for (CartBean item : cartItems) {
                            ProductBean product = item.getProduct();
                            if (product != null) {
                                double subtotal = item.getSubtotal();
                                total += subtotal;
                %>
                <tr>
                    <td class="product-image-cell">
                        <img src="<%= product.getImage() %>" alt="<%= product.getName() %>" class="cart-product-image">
                    </td>
                    <td class="product-name-cell"><%= product.getName() %></td>
                    <td class="price-cell">€ <%= String.format("%.2f", product.getPrice()) %></td>
                    <td>
                        <input type="number" name="quantities[<%= product.getCode() %>]" value="<%= item.getQuantity() %>" min="1" max="<%= product.getQuantity() %>" class="quantity-input">
                    </td>
                    <td class="subtotal-cell">€ <%= String.format("%.2f", subtotal) %></td>
                    <td>
                        <button type="submit" formaction="remove-from-cart" formmethod="post" name="productCode" value="<%= product.getCode() %>" class="remove-btn">
                            Rimuovi
                        </button>
                    </td>
                </tr>
                <%
                            }
                        }
                    } else {
                %>
                <tr>
                    <td colspan="6" class="empty-cart-message">Il carrello è vuoto.</td>
                </tr>
                <% } %>
                </tbody>
            </table>
        </div>
        
	       <div class="cart-actions updated-layout">
	        <div class="cart-summary-box">
	    		<div class="left-section">
	        		<p class="cart-total">Totale: € <%= String.format("%.2f", total) %></p>
	
	        		<% if (username != null) { %>
	            	<button type="submit" formaction="checkout-page" formmethod="post" class="checkout-btn">Effettua Ordine</button>
	        		<% } else { %>
	            	<p class="login-message">Per effettuare l'ordine devi <a href="login.jsp">accedere</a>.</p>
	       			 <% } %>
	    		</div>
	
	    		
			</div>
				<div class="right-section">
	        		<button type="submit" class="primary-btn">Aggiorna Quantità</button>
	        		<button type="submit" formaction="clear-cart" formmethod="post" class="secondary-btn">Svuota Carrello</button>
	    		</div>
		</div>
    </form>
</main>
	<footer>
        <p>&copy; 2025 MyGarden - Tutti i diritti riservati.</p>
    </footer>
</body>
</html>