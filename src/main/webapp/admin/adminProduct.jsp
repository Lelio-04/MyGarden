<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, it.unisa.db.ProductBean" %>
<%
    Boolean isAdmin = (Boolean) session.getAttribute("isAdmin");
    if (isAdmin == null || !isAdmin) {
        response.sendRedirect("login.jsp");
        return;
    }

    Collection<ProductBean> products = (Collection<ProductBean>) request.getAttribute("products");
    ProductBean selectedProduct = (ProductBean) request.getAttribute("product");
    String errorMessage = (String) request.getAttribute("errorMessage");

    String token = (String) session.getAttribute("sessionToken");
    if (token == null && request.getCookies() != null) {
        for (Cookie c : request.getCookies()) {
            if ("sessionToken".equals(c.getName())) {
                token = c.getValue();
                break;
            }
        }
    }
%>
 <%
     String username = (String) session.getAttribute("username");
     String activePage = (String) request.getAttribute("activePage");
     if (activePage == null) activePage = "";

     // Ottieni il nome del file JSP corrente
     String currentPage = request.getRequestURI().substring(request.getContextPath().length());
     // Rimuovi il primo slash se presente per ottenere solo il nome del file
     if (currentPage.startsWith("/")) {
         currentPage = currentPage.substring(1);
     }
     String cartMergeMessage = (String) session.getAttribute("cartMergeMessage");
     if (cartMergeMessage != null) {
         session.removeAttribute("cartMergeMessage");
     }
 %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Admin - Gestione Prodotti</title>
    <link rel="stylesheet" href="styles/styleAdminCatalogo.css">
    <link rel="stylesheet" href="styles/styleHeader.css">
</head>
<body>

<header>
     <div class="header-content-wrapper">
         <a href="index.jsp" class="brand">MyGarden</a>

         <nav class="main-nav">
             <ul class="nav-links">
                 <li><a href="index.jsp" id="signed">Home</a></li>

                 <% if (isAdmin != null && isAdmin) { %>
                     <li><a href="<%= request.getContextPath() %>/product">Gestione Catalogo</a></li>
                     <li><a href="admin/adminOrders.jsp">Gestione Ordini</a></li>
                 <% } else { %>
                     <%-- Mostra "Contattaci" SOLO se la pagina corrente è index.jsp --%>
                     <% if ("index.jsp".equals(currentPage)) { %>
                         <li><a href="#contattaci">Contattaci</a></li>
                     <% } %>
                     <li class="dropdown">
                         <a href="<%= request.getContextPath() %>/product" class="dropdown-toggle">Catalogo</a>
                         <ul class="dropdown-menu">
                             <li><a href="product?categoria=Piante da Interno">Piante da Interno</a></li>
                             <li><a href="product?categoria=Piante da Esterno">Piante da Esterno</a></li>
                             <li><a href="product?categoria=Piante Aromatiche">Piante Aromatiche</a></li>
                             <li><a href="product?categoria=Piante Grasse">Piante Grasse</a></li>
                             <li><a href="product?categoria=Piante Fiorite">Fiori</a></li>
                             <li><a href="product?categoria=Attrezzi">Attrezzi</a></li>
                         </ul>
                     </li>
                     <li><a href="carrello.jsp">Carrello</a></li>
                     <li><a href="ordini.jsp">Ordini</a></li>
                 <% } %>

                 <% if (username != null) { %>
					    <li><a href="./Logout">Logout</a></li>
					<% } else { %>
					    <li><a href="https://localhost/MyGardenProject/login.jsp">Accedi</a></li>
					<% } %>
             </ul>
         </nav>

         <div class="header-icons">

             <a href="<%= (username != null) ? "profilo.jsp" : "https://localhost/MyGardenProject/login.jsp" %>" class="icon-link" title="<%= (username != null) ? "Profilo" : "Accedi" %>">
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
 </header>

<main>
    <% if (errorMessage != null) { %>
        <p class="error-message"><%= errorMessage %></p>
    <% } %>

    <h2>Lista Prodotti</h2>
    <table border="1">
        <tr>
            <th>Codice</th>
            <th>Nome</th>
            <th>Descrizione</th>
            <th>Prezzo</th>
            <th>Quantità</th>
            <th>Immagine</th>
            <th>Azioni</th>
        </tr>
        <%
            if (products != null) {
                for (ProductBean p : products) {
        %>
        <tr>
            <td><%= p.getCode() %></td>
            <td><%= p.getName() %></td>
            <td><%= p.getDescription() %></td>
            <td><%= p.getPrice() %></td>
            <td><%= p.getQuantity() %></td>
            <td><img src="<%= p.getImage() %>" alt="<%= p.getName() %>" width="50"/></td>
			<td class="action-buttons">
			    <a class="modify" href="product?action=read&id=<%= p.getCode() %>#form">Modifica</a>
			    <a class="delete" href="product?action=delete&id=<%= p.getCode() %>&token=<%= token %>"
			       onclick="return confirm('Sei sicuro di voler eliminare questo prodotto?');">
			       Elimina
			    </a>
			</td>
        </tr>
        <%
                }
            } else {
        %>
        <tr><td colspan="7">Nessun prodotto disponibile</td></tr>
        <% } %>
    </table>

    <h2 id="form"><%= (selectedProduct != null) ? "Modifica Prodotto" : "Nuovo Prodotto" %></h2>
    <form method="post" action="product">
        <input type="hidden" name="action" value="<%= (selectedProduct != null) ? "update" : "insert" %>"/>
        <% if (selectedProduct != null) { %>
            <input type="hidden" name="id" value="<%= selectedProduct.getCode() %>"/>
        <% } %>
        <input type="hidden" name="token" value="<%= token %>"/>

        <label>Nome:</label><br/>
        <input type="text" name="name" required value="<%= (selectedProduct != null) ? selectedProduct.getName() : "" %>"/><br/>

        <label>Descrizione:</label><br/>
        <textarea name="description" required><%= (selectedProduct != null) ? selectedProduct.getDescription() : "" %></textarea><br/>

        <label>Prezzo:</label><br/>
        <input type="number" name="price" step="0.01" min="0" required value="<%= (selectedProduct != null) ? selectedProduct.getPrice() : "" %>"/><br/>

        <label>Quantità:</label><br/>
        <input type="number" name="quantity" min="1" required value="<%= (selectedProduct != null) ? selectedProduct.getQuantity() : "1" %>"/><br/>

        <label>URL Immagine:</label><br/>
        <input type="text" name="image" required value="<%= (selectedProduct != null) ? selectedProduct.getImage() : "" %>"/><br/><br/>

        <button type="submit"><%= (selectedProduct != null) ? "Aggiorna" : "Inserisci" %></button>
        <button type="reset">Reset</button>
    </form>
</main>

<footer>
    <p>&copy; 2025 MyGarden - Area amministratore</p>
</footer>

</body>
</html>
