<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, java.text.SimpleDateFormat, it.unisa.order.OrderDAO, it.unisa.order.OrderBean" %>
<%@ page import="javax.sql.DataSource" %>
<%@ page session="true" %>

<%
    String username = (String) session.getAttribute("username");
    Boolean isAdmin = (Boolean) session.getAttribute("isAdmin");

    if (username == null || isAdmin == null || !isAdmin) {
        response.sendRedirect("login.jsp?next=admin/adminOrders.jsp");
        return;
    }

    String token = (String) session.getAttribute("sessionToken");
    if (token == null && request.getCookies() != null) {
        for (Cookie c : request.getCookies()) {
            if ("sessionToken".equals(c.getName())) {
                token = c.getValue();
                break;
            }
        }
    }

    DataSource dataSource = (DataSource) application.getAttribute("DataSourceStorage");
    OrderDAO orderDAO = new OrderDAO(dataSource);
    List<OrderBean> allOrders = orderDAO.getAllOrders();

    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");
%>

<!DOCTYPE html>
<html lang="it">
<head>
    <meta charset="UTF-8">
    <title>Gestione Ordini - Admin</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/styles/styleAdminOrders.css">
    <link rel="icon" href="images/favicon.png" type="image/png">
</head>
<body>

<header class="admin-header">
    <div class="header-container">
        <h1 class="admin-title">Area Amministratore - Gestione Ordini</h1>
        <nav class="admin-nav">
            <a href="../index.jsp" class="nav-link">Torna al sito</a>
            <a href="./adminCatalogo.jsp" class="nav-link">Gestione Catalogo</a>
        </nav>
    </div>
</header>

<main class="main-content">
    <h2 class="section-title">Ordini ricevuti</h2>

    <%
        if (allOrders == null || allOrders.isEmpty()) {
    %>
        <p class="no-orders">⚠️ Nessun ordine trovato.</p>
    <%
        } else {
    %>
        <table class="orders-table">
            <thead>
                <tr>
                    <th>ID Ordine</th>
                    <th>ID Utente</th>
                    <th>Data</th>
                    <th>Totale (€)</th>
                    <th>Azioni</th>
                </tr>
            </thead>
            <tbody>
            <%
                for (OrderBean order : allOrders) {
            %>
                <tr>
                    <td><%= order.getId() %></td>
                    <td><%= order.getUserId() %></td>
                    <td><%= order.getCreatedAt() != null ? sdf.format(order.getCreatedAt()) : "-" %></td>
                    <td><%= String.format("%.2f", order.getTotal()) %></td>
                    <td>
                        <form action="adminOrderDetails.jsp" method="get" class="action-form">
                            <input type="hidden" name="orderId" value="<%= order.getId() %>">
                            <input type="hidden" name="token" value="<%= token %>">
                            <button type="submit" class="action-button">Dettagli</button>
                        </form>
                    </td>
                </tr>
            <%
                }
            %>
            </tbody>
        </table>
    <%
        }
    %>
</main>

<footer class="admin-footer">
    <p>&copy; 2025 MyGarden - Amministrazione</p>
</footer>

</body>
</html>
