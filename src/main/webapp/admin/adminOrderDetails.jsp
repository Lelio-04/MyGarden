<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, java.text.SimpleDateFormat" %>
<%@ page import="javax.sql.DataSource" %>
<%@ page import="it.unisa.order.OrderDAO, it.unisa.order.OrderItemBean" %>
<%@ page session="true" %>

<%
    // ✅ Controllo accesso admin
    Boolean isAdmin = (Boolean) session.getAttribute("isAdmin");
    if (isAdmin == null || !isAdmin) {
        response.sendRedirect("../login.jsp?next=admin/adminOrders.jsp");
        return;
    }

    // ✅ Controllo token CSRF
    String requestToken = request.getParameter("token");
    String sessionToken = (String) session.getAttribute("sessionToken");
    if (requestToken == null || sessionToken == null || !requestToken.equals(sessionToken)) {
        response.sendError(HttpServletResponse.SC_FORBIDDEN, "Token non valido.");
        return;
    }

    String orderIdStr = request.getParameter("orderId");
    if (orderIdStr == null) {
        response.sendRedirect("adminOrders.jsp");
        return;
    }

    int orderId = Integer.parseInt(orderIdStr);

    DataSource ds = (DataSource) application.getAttribute("DataSourceStorage");
    OrderDAO orderDAO = new OrderDAO(ds);
    List<OrderItemBean> items = orderDAO.getOrderItemsByOrderId(orderId);
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Dettagli Ordine Admin #<%= orderId %></title>
    <link rel="stylesheet" href="../styles/styleBase.css">
    <link rel="stylesheet" href="../styles/styleOrders.css">
</head>
<body>
<header>
    <h1>Dettagli Ordine #<%= orderId %></h1>
    <nav>
        <a href="adminOrders.jsp">← Torna agli ordini</a> |
        <a href="../Logout">Logout</a>
    </nav>
</header>

<main>
    <% if (items == null || items.isEmpty()) { %>
        <p>Nessun prodotto trovato per questo ordine.</p>
    <% } else { %>
        <table border="1" cellpadding="8" cellspacing="0" style="width:100%; border-collapse: collapse;">
            <thead style="background-color: #4a7c59; color: white;">
                <tr>
                    <th>Prodotto</th>
                    <th>Immagine</th>
                    <th>Quantità</th>
                    <th>Prezzo Unitario</th>
                    <th>Subtotale</th>
                </tr>
            </thead>
            <tbody>
                <% double totale = 0.0;
                   for (OrderItemBean item : items) {
                       double subtotal = item.getQuantity() * item.getPriceAtPurchase();
                       totale += subtotal;
                %>
                <tr>
                    <td><%= item.getProductName() %></td>
                    <td><img src="<%= item.getProductImage() %>" alt="img" style="width: 80px; height: 80px; object-fit: cover; border-radius: 6px;"></td>
                    <td><%= item.getQuantity() %></td>
                    <td>€ <%= String.format("%.2f", item.getPriceAtPurchase()) %></td>
                    <td>€ <%= String.format("%.2f", subtotal) %></td>
                </tr>
                <% } %>
                <tr style="font-weight: bold; background-color: #eee;">
                    <td colspan="4" style="text-align: right;">Totale</td>
                    <td>€ <%= String.format("%.2f", totale) %></td>
                </tr>
            </tbody>
        </table>
    <% } %>
</main>
</body>
</html>
