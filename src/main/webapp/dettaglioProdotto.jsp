<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="it.unisa.db.ProductBean" %>
<%@ page import="java.util.*" %>
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
		   <button class="add-to-cart-btn"
                        data-product-id="<%= product.getCode() %>"
                        data-product-name="<%= product.getName() %>"
                        data-product-price="<%= String.format(Locale.US, "%.2f", product.getPrice()) %>"
                        data-product-image="<%= product.getImage() %>"
                        data-max-qty="<%= product.getQuantity() %>">
                        Aggiungi al Carrello
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

<script>
function showGlobalMessage(message) {
	  let messageDiv = document.getElementById("global-error-message");
	  if (!messageDiv) {
	    messageDiv = document.createElement("div");
	    messageDiv.id = "global-error-message";
	    messageDiv.className = "global-error-message";
	    document.body.prepend(messageDiv);
	  }

	  messageDiv.textContent = message;
	  messageDiv.style.display = "block";

	  // Nascondi dopo 2 secondi
	  const timeoutId = setTimeout(() => {
	    messageDiv.style.display = "none";
	  }, 2000);

	  // Nascondi al click e rimuovi listener per evitare duplicazioni
	  function hideOnClick() {
	    clearTimeout(timeoutId);
	    messageDiv.style.display = "none";
	    document.removeEventListener("click", hideOnClick);
	  }

	  // Usa setTimeout minimo per permettere la visualizzazione prima di agganciare il listener
	  setTimeout(() => {
	    document.addEventListener("click", hideOnClick);
	  }, 100);
	}

	document.addEventListener("DOMContentLoaded", function () {
	  const addToCartButtons = document.querySelectorAll(".add-to-cart-btn");

	  addToCartButtons.forEach(button => {
	    button.addEventListener("click", function () {
	      const productName = this.getAttribute("data-product-name");
	      showGlobalMessage(`Prodotto aggiunto al carrello!`);
	    });
	  });
	});

</script>
</body>
</html>