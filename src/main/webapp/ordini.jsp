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
<header>
    <div class="header-top">
        <img src="images/logo.png" alt="MyGarden Logo" class="logo">
        <span class="site-title">
            <span class="yellow">My</span><span class="green">Garden</span>
        </span>
        <div class="header-icons">
            <a href="carrello.jsp" class="icon-link" title="Carrello">
                <svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <circle cx="9" cy="21" r="1"></circle>
                    <circle cx="20" cy="21" r="1"></circle>
                    <path d="m1 1 4 4 14 1-1 9H6"></path>
                </svg>
            </a>
            <a href="<%= (username != null) ? "profilo.jsp" : "login.jsp" %>" class="icon-link" title="<%= (username != null) ? "Profilo" : "Accedi" %>">
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

    <nav class="main-nav">
        <ul class="nav-links">
            <li><a href="index.jsp" id="signed">Home</a></li>
            <% Boolean isAdmin = (Boolean) session.getAttribute("isAdmin"); %>
            <% if (isAdmin != null && isAdmin) { %>
                <li><a href="<%=request.getContextPath()%>/product">Gestione Catalogo</a></li>
                <li><a href="#">Gestione Ordini</a></li>
            <% } else { %>
                <li><a href="#contattaci">Contattaci</a></li>
                <li><a href="<%=request.getContextPath()%>/product">Catalogo</a></li>
                <li><a href="carrello.jsp">Carrello</a></li>
            <% } %>
            <li><a href="ordini.jsp">Ordini</a></li>
            <% if (username != null) { %>
                <li><a href="Logout">Logout</a></li>
            <% } else { %>
                <li><a href="login.jsp">Accedi</a></li>
            <% } %>
        </ul>
    </nav>
</header>

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

</body>
</html>
