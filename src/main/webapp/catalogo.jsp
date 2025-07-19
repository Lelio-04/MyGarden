<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, it.unisa.cart.*, it.unisa.db.*" %>
<%
    // Carica i prodotti dalla sessione o da un database
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
    <link rel="stylesheet" href="styles/styleCatalogo.css">
    <link rel="stylesheet" href="styles/styleSidebar.css">
    <link rel="icon" href="images/favicon.png" type="image/png">
    <script>
        var isLoggedIn = <%= (username != null) ? "true" : "false" %>;
    </script>
    <script src="scripts/sidebar.js" defer></script>
   
</head>
<body>
<%
    request.setAttribute("activePage", "catalogo");
%>
<jsp:include page="header.jsp" />

<!-- Form di ricerca -->
<form id="searchForm">
    <input type="text" id="q" placeholder="Nome prodotto" />
    <select id="categoria">
        <!-- Le categorie saranno caricate dinamicamente -->
    </select>
    <button type="submit">Cerca</button>
</form>

<!-- Sezione dei risultati -->
<div id="prodotti">
    <div class="catalog-container">
        <div class="catalog-grid">
            <% 
                if (products != null && !products.isEmpty()) {
                    for (Object obj : products) {
                        ProductBean bean = (ProductBean) obj;
            %>
            <div class="product-card">
                <a href="DettaglioProdottoServlet?code=<%= bean.getCode() %>">
                    <div class="product-image-wrapper">
                        <img src="<%= bean.getImage() %>" alt="<%= bean.getName() %>">
                    </div>
                </a>
                <div class="product-content">
                    <h3><%= bean.getName() %></h3>
                    <p class="price">€ <%= String.format(Locale.US, "%.2f", bean.getPrice()) %></p>

                    <% if (bean.getQuantity() > 0) { %>
                    <div class="quantity-row">
                        <span class="available">Disponibilità: <%= bean.getQuantity() %></span>
                        <input type="number" id="qty-<%= bean.getCode() %>" value="1" min="1" max="<%= bean.getQuantity() %>" required>
                    </div>
                    <button class="add-to-cart-btn"
                        data-product-id="<%= bean.getCode() %>"
                        data-product-name="<%= bean.getName() %>"
                        data-product-price="<%= String.format(Locale.US, "%.2f", bean.getPrice()) %>"
                        data-product-image="<%= bean.getImage() %>"
                        data-max-qty="<%= bean.getQuantity() %>">
                        Aggiungi al Carrello
                    </button>
                    <% } else { %>
                    <div class="not-available">Non disponibile</div>
                    <% } %>
                </div>
            </div>
            <% 
                    }
                } else {
            %>
            <p>Nessun prodotto trovato.</p>
            <% } %>
        </div>
    </div>
</div>
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
<jsp:include page="footer.jsp" />
</body>
</html>
