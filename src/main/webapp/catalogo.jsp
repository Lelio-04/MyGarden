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
    <style>
        .not-available {
            display: inline-block;
            padding: 10px;
            background-color: #ffcdd2;
            color: #b71c1c;
            font-weight: bold;
            border-radius: 5px;
            margin-top: 10px;
            text-align: center;
        }
    </style>
</head>
<body>
	<%
    request.setAttribute("activePage", "catalogo");
	%>
	<jsp:include page="header.jsp" />

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

            <% if (bean.getQuantity() > 0) { %>
                <div class="quantity-row">
                    <span class="available">Disponibilità: <%= bean.getQuantity() %></span>
                    <input type="number" id="qty-<%= bean.getCode() %>" value="1" min="1" max="<%= bean.getQuantity() %>" required>
                </div>
                <button 
				  onclick="aggiungiAlCarrello(<%= bean.getCode() %>)" 
				  data-max-qty="<%= bean.getQuantity() %>">
				  Aggiungi al Carrello
				</button>


            <% } else { %>
                <div class="not-available">Non disponibile</div>
            <% } %>
        </div>
        <%
                }
            } else {
        %>
        <p>Nessun prodotto disponibile.</p>
        <% } %>
    </div>
</main>

	<jsp:include page="footer.jsp" />
	
<!-- Sidebar Carrello -->
<div id="sidebar-carrello" style="display:none; position: fixed; right: 0; top: 0; width: 350px; height: 100vh; background: white; border-left: 1px solid #ccc; padding: 20px; overflow-y: auto; z-index: 10000; box-shadow: -2px 0 10px rgba(0,0,0,0.2);">
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
  const isLoggedIn = <%= (username != null) ? "true" : "false" %>;
</script>
<script src="scripts/sidebar.js"></script>
</body>
</html>
