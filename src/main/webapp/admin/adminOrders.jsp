<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, java.text.SimpleDateFormat, it.unisa.order.OrderDAO, it.unisa.order.OrderBean" %>
<%@ page import="javax.sql.DataSource" %>
<%@ page session="true" %>

<%
    // Controllo accesso admin
    Boolean isAdmin = (Boolean) session.getAttribute("isAdmin");
    if (isAdmin == null || !isAdmin) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Recupera datasource
    DataSource dataSource = (DataSource) application.getAttribute("DataSourceStorage");
    OrderDAO orderDAO = new OrderDAO(dataSource);

    // Recupera tutti gli ordini
    List<OrderBean> allOrders = orderDAO.getAllOrders();

    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Gestione Ordini - Admin</title>
    <link rel="stylesheet" href="styles/styleBase.css">
    <link rel="stylesheet" href="styles/styleHomePage.css">
</head>
<body>
    <header>
        <h1>Gestione Ordini - Admin</h1>
        <nav>
            <a href="${pageContext.request.contextPath}/Logout">Logout</a>
        </nav>
    </header>

    <main>
        <%
            if (allOrders == null || allOrders.isEmpty()) {
        %>
            <p>Nessun ordine trovato.</p>
        <%
            } else {
        %>
            <table border="1" cellpadding="8" cellspacing="0" style="width: 100%; border-collapse: collapse;">
                <thead>
                    <tr style="background-color: #4a7c59; color: white;">
                        <th>ID Ordine</th>
                        <th>ID Utente</th>
                        <th>Data</th>
                        <th>Totale (€)</th>
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
</body>
</html>
