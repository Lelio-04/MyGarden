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
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Admin - Gestione Prodotti</title>
    <link rel="stylesheet" href="styles/styleBase.css">
    <link rel="stylesheet" href="styles/styleAdmin.css">
</head>
<body>

<header>
    <h1>Area Amministratore - Gestione Prodotti</h1>
    <nav>
        <a href="index.jsp">Torna al sito</a> |
        <a href="logout.jsp">Logout</a>
    </nav>
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
            <td>
                <a href="product?action=read&id=<%= p.getCode() %>">Modifica</a> |
                <a href="product?action=delete&id=<%= p.getCode() %>" onclick="return confirm('Sei sicuro di voler eliminare questo prodotto?');">Elimina</a>
            </td>
        </tr>
        <%
                }
            } else {
        %>
        <tr><td colspan="7">Nessun prodotto disponibile</td></tr>
        <% } %>
    </table>

    <h2><%= (selectedProduct != null) ? "Modifica Prodotto" : "Nuovo Prodotto" %></h2>
    <form method="post" action="product">
        <input type="hidden" name="action" value="<%= (selectedProduct != null) ? "update" : "insert" %>"/>
        <% if (selectedProduct != null) { %>
            <input type="hidden" name="id" value="<%= selectedProduct.getCode() %>"/>
        <% } %>

        <label>Nome:</label><br/>
        <input type="text" name="name" required value="<%= (selectedProduct != null) ? selectedProduct.getName() : "" %>"/><br/>

        <label>Descrizione:</label><br/>
        <textarea name="description" required><%= (selectedProduct != null) ? selectedProduct.getDescription() : "" %></textarea><br/>

        <label>Prezzo:</label><br/>
        <input type="number" name="price" min="0" required value="<%= (selectedProduct != null) ? selectedProduct.getPrice() : "" %>"/><br/>

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
