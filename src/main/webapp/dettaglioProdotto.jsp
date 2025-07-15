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
    <style>
        .not-available {
            display: inline-block;
            padding: 10px 20px;
            background-color: #ffcdd2;
            color: #b71c1c;
            font-weight: bold;
            border-radius: 6px;
            margin-top: 15px;
        }
    </style>
    
    <style>
		.sidebar-carrello {
		  position: fixed;
		  top: 0;
		  right: -400px; /* inizialmente fuori dallo schermo */
		  width: 350px;
		  height: 100vh;
		  background: white;
		  border-left: 1px solid #ccc;
		  padding: 20px;
		  overflow-y: auto;
		  z-index: 10000;
		  box-shadow: -2px 0 10px rgba(0,0,0,0.2);
		  transition: right 0.3s ease-in-out;
		}
		
		.sidebar-carrello.attiva {
		  right: 0; /* entra in vista */
		}
</style>
    
</head>
<body>

<jsp:include page="header.jsp" />

<main class="product-detail-container">
    <div class="product-detail-card">
        <img class="product-image" src="<%= product.getImage() %>" alt="<%= product.getName() %>">

        <div class="product-info">
            <h1><%= product.getName() %></h1>
            <p class="price">Prezzo: € <%= String.format("%.2f", product.getPrice()) %></p>
            <p class="description"><%= product.getDescription() %></p>
            <p class="availability">Disponibilità: <%= product.getQuantity() %> unità</p>

		<% if (product.getQuantity() > 0) { %>
		    <div class="quantity-section">
		        <div class="quantity-row">
		            <label for="quantity">Quantità:</label>
		            <input type="number" id="quantity" name="quantity" value="1" min="1" max="<%= product.getQuantity() %>" required>
		        </div>
		    </div>
		    <button 
		        onclick="aggiungiAlCarrelloDettaglio(<%= product.getCode() %>, <%= product.getQuantity() %>)" 
		        class="add-to-cart-btn">
		        Aggiungi al carrello
		    </button>
		<% } else { %>
		    <div class="not-available">Non disponibile</div>
		<% } %>

        </div>
    </div>
</main>

<jsp:include page="footer.jsp" />
<!-- Sidebar Carrello -->
<div id="sidebar-carrello" class="sidebar-carrello">
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
  // Passa lo stato di login da JSP a JS
  const isLoggedIn = <%= (username != null) ? "true" : "false" %>;
</script>
<script src="scripts/sidebarDetails.js"></script>

</body>
</html>