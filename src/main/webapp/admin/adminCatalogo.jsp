<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, it.unisa.db.ProductBean" %>

<%
    Boolean isAdmin = (Boolean) session.getAttribute("isAdmin");
    if (isAdmin == null || !isAdmin) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    // ✅ Recupero token da sessione o cookie
    String token = (String) session.getAttribute("sessionToken");
    if (token == null && request.getCookies() != null) {
        for (Cookie c : request.getCookies()) {
            if ("sessionToken".equals(c.getName())) {
                token = c.getValue();
                break;
            }
        }
    }

    Collection<?> products = (Collection<?>) request.getAttribute("products");
    if (products == null) {
        response.sendRedirect("../product");
        return;
    }

    ProductBean product = (ProductBean) request.getAttribute("product");
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Gestione Prodotti - Admin</title>
</head>
<body>

<header>
    <div class="header-top">
        <span class="site-title">MyGarden Admin</span>
    </div>
    <nav class="main-nav">
        <ul class="nav-links">
            <li><a href="index.jsp">Home</a></li>
            <li><a href="adminProduct.jsp">Gestione Catalogo</a></li>
            <li><a href="/admin/adminOrders.jsp">Ordini</a></li>
            <li><a href="Logout">Logout</a></li>
        </ul>
    </nav>
</header>

<main>
    <h2>Catalogo Prodotti</h2>

    <table>
        <thead>
        <tr>
            <th>Codice</th>
            <th>Nome</th>
            <th>Descrizione</th>
            <th>Prezzo</th>
            <th>Quantità</th>
            <th>Immagine</th>
            <th>Azioni</th>
        </tr>
        </thead>
        <tbody>
        <%
            if (!products.isEmpty()) {
                for (Object obj : products) {
                    ProductBean p = (ProductBean) obj;
        %>
        <tr>
            <td><%= p.getCode() %></td>
            <td><%= p.getName() %></td>
            <td><%= p.getDescription() %></td>
            <td>€ <%= p.getPrice() %></td>
            <td><%= p.getQuantity() %></td>
            <td><img src="<%= p.getImage() %>" alt="img" width="60"></td>
            <td>
                <!-- ✅ Azioni con token -->
                <form action="product" method="get" style="display:inline;">
                    <input type="hidden" name="action" value="read">
                    <input type="hidden" name="id" value="<%= p.getCode() %>">
                    <input type="hidden" name="token" value="<%= token %>">
                    <button type="submit">Dettagli</button>
                </form>
                <form action="product" method="post" style="display:inline;" onsubmit="return confirm('Sei sicuro di voler eliminare questo prodotto?');">
                    <input type="hidden" name="action" value="delete">
                    <input type="hidden" name="id" value="<%= p.getCode() %>">
                    <input type="hidden" name="token" value="<%= token %>">
                    <button type="submit">Elimina</button>
                </form>
            </td>
        </tr>
        <%
                }
            } else {
        %>
        <tr><td colspan="7">Nessun prodotto disponibile.</td></tr>
        <% } %>
        </tbody>
    </table>

    <h3>Inserisci Nuovo Prodotto</h3>
    <form action="product" method="post">
        <input type="hidden" name="action" value="insert">
        <input type="hidden" name="token" value="<%= token %>">

        <label for="name">Nome:</label><br>
        <input type="text" name="name" required><br><br>

        <label for="description">Descrizione:</label><br>
        <textarea name="description" rows="3" required></textarea><br><br>

        <label for="price">Prezzo:</label><br>
        <input type="number" name="price" min="0" step="0.01" required><br><br>

        <label for="quantity">Quantità:</label><br>
        <input type="number" name="quantity" min="1" required><br><br>

        <label for="image">URL Immagine:</label><br>
        <input type="text" name="image"><br><br>

        <button type="submit">Aggiungi</button>
        <button type="reset">Reset</button>
    </form>

    <% if (product != null) { %>
    <h3>Dettagli Prodotto</h3>
    <ul>
        <li>Codice: <%= product.getCode() %></li>
        <li>Nome: <%= product.getName() %></li>
        <li>Descrizione: <%= product.getDescription() %></li>
        <li>Prezzo: € <%= product.getPrice() %></li>
        <li>Quantità: <%= product.getQuantity() %></li>
    </ul>
    <% } %>
</main>

<footer>
    <p>&copy; 2025 MyGarden - Area Amministratore</p>
</footer>
</body>
</html>
