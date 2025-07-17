<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="it.unisa.db.ProductBean" %>
<%@ page import="java.util.List" %>
<%@ page import="it.unisa.db.ReviewBean" %>

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
    <link rel="stylesheet" href="styles/styleSidebar.css">
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
    <script>
	  const isLoggedIn = <%= (username != null) ? "true" : "false" %>;
	</script>
	<script src="scripts/sidebar.js"></script>
    <%-- Ensure your custom modal HTML structure is present somewhere, e.g., in header.jsp or directly here --%>
    
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
		            <input type="number" id="qty-<%= product.getCode() %>" name="quantity" value="1" min="1" max="<%= product.getQuantity() %>" required>
		        </div>
		    </div>
		    <button
                class="add-to-cart-btn"
                data-product-id="<%= product.getCode() %>"
                data-product-name="<%= product.getName().replace("\"", "&quot;").replace("'", "&#39;") %>"
                data-product-price="<%= String.format(java.util.Locale.US, "%.2f", product.getPrice()) %>"
                data-product-image="<%= product.getImage().replace("\"", "&quot;").replace("'", "&#39;") %>"
                data-max-qty="<%= product.getQuantity() %>"
            >
		        Aggiungi al carrello
		    </button>
		<% } else { %>
		    <div class="not-available">Non disponibile</div>
		<% } %>

        </div>
    </div>
    	
    <%
    List<ReviewBean> reviews = (List<ReviewBean>) request.getAttribute("reviews");
%>

<section class="reviews-section">
    <h2>Recensioni dei clienti</h2>

    <% if (reviews != null && !reviews.isEmpty()) {
        for (ReviewBean review : reviews) {
            int stars = review.getStars();
    %>
    <div class="review">
        <div class="review-header">
            <span class="review-stars">
                <%= "★".repeat(stars) + "☆".repeat(5 - stars) %>
            </span>
            <span class="review-user"><%= review.getUser() %></span>
        </div>
        <p class="review-text"><%= review.getText() %></p>
    </div>
    <%   }
       } else { %>
        <p>Nessuna recensione disponibile per questo prodotto.</p>
    <% } %>
</section>
    
    
</main>

<jsp:include page="footer.jsp" />


</body>
</html>