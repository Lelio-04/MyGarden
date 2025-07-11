<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, it.unisa.order.OrderDAO, it.unisa.order.OrderBean, it.unisa.db.DriverManagerConnectionPool" %>
<%@ page session="true" %>
<%
    Integer userId = (Integer) session.getAttribute("userId");

    if (userId == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    DriverManagerConnectionPool pool = new DriverManagerConnectionPool();
    OrderDAO orderDAO = new OrderDAO(pool);
    List<OrderBean> orders = orderDAO.getOrdersByUser(userId);
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>I miei ordini</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 40px;
        }
        h1 {
            color: #3b3b3b;
        }
        .order-box {
            border: 1px solid #ccc;
            border-radius: 8px;
            padding: 16px;
            margin-bottom: 20px;
            background-color: #f9f9f9;
        }
        .order-box h3 {
            margin-top: 0;
        }
        .no-orders {
            color: #888;
            font-style: italic;
        }
    </style>
</head>
<body>
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
        </div>
    <%
            }
        }
    %>
</body>
</html>
