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

    // ✅ Recupero del token dalla sessione o cookie
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
    <link rel="stylesheet" href="styles/styleBase.css">
    <link rel="stylesheet" href="styles/styleOrders.css">
    <link rel="icon" href="images/favicon.png" type="image/png">
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
	<jsp:include page="footer.jsp" />
</body>
</html>
