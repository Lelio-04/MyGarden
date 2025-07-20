<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, it.unisa.order.OrderDAO, it.unisa.order.OrderBean, it.unisa.order.OrderItemBean" %>
<%@ page import="javax.sql.DataSource" %>
<%@ page session="true" %>

<%
    String username = (String) session.getAttribute("username");
    Integer userId = (Integer) session.getAttribute("userId");

    if (userId == null || username == null) {
        response.sendRedirect("login.jsp?next=ordini.jsp");
        return;
    }

    //Recupero del token dalla sessione o cookie
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
    List<OrderBean> orders = orderDAO.getOrdersByUser(userId);
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>I miei ordini</title>
    <link rel="stylesheet" href="styles/styleSidebar.css">
    <link rel="stylesheet" href="styles/styleOrders.css">
    <link rel="icon" href="images/favicon.png" type="image/png">
    <script>
      var isLoggedIn = <%= (username != null) ? "true" : "false" %>;
    </script>
    <script src="scripts/sidebar.js" defer></script>
</head>
<body>

	<jsp:include page="header.jsp" />

<h1>Storico Ordini</h1>

<%
    if (orders.isEmpty()) {
%>
    <p class="no-orders">Non hai ancora effettuato ordini.</p>
<%
    } else {
        for (OrderBean order : orders) {
%>
    <div class="order-box">
        <h3>Ordine #<%= order.getId() %></h3>
        <p>Data: <%= order.getCreatedAt() %></p>
        <p>Totale: € <%= String.format("%.2f", order.getTotal()) %></p>

        <%
            List<OrderItemBean> items = order.getOrderItems();
            if (items != null && !items.isEmpty()) {
        %>
            <p>Prodotti acquistati:</p>
            <ul>
                <% for (OrderItemBean item : items) { %>
                    <li style="margin-bottom: 10px; display: flex; align-items: center; gap: 12px;">
                        <img src="<%= item.getProductImage() %>" alt="<%= item.getProductName() %>" style="width: 80px; height: 80px; object-fit: cover; border-radius: 6px;">
                        <div>
                            <strong><%= item.getProductName() %></strong><br>
                            Quantità: <%= item.getQuantity() %><br>
                            Prezzo unitario: € <%= String.format("%.2f", item.getPriceAtPurchase()) %>
                        </div>
                    </li>
                <% } %>
            </ul>

        <%
            }
        %>
    </div>
<%
        }
    }
%>
	<jsp:include page="footer.jsp" />
</body>
</html>
