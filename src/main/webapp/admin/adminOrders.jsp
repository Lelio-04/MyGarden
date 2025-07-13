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

    // ✅ Recupera token dalla sessione o cookie
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
<html>
<head>
    <meta charset="UTF-8">
    <title>Gestione Ordini - Admin</title>
    <link rel="stylesheet" href="styles/styleBase.css">
    <link rel="stylesheet" href="styles/styleOrders.css">
    <link rel="icon" href="images/favicon.png" type="image/png">
</head>
<body>

<header>
    <div class="header-top">
        <img src="images/logo.png" alt="MyGarden Logo" class="logo">
        <span class="site-title"><span class="yellow">My</span><span class="green">Garden Admin</span></span>
        <div class="header-icons">
            <a href="admin/adminOrders.jsp" class="icon-link" title="Ordini">
                📦
            </a>
            <a href="Logout" class="icon-link" title="Logout">
                🔓
            </a>
        </div>
    </div>

    <nav class="main-nav">
        <ul class="nav-links">
            <li><a href="index.jsp">Home</a></li>
            <li><a href="<%=request.getContextPath()%>/product">Gestione Catalogo</a></li>
            <li><a href="admin/adminOrders.jsp">Gestione Ordini</a></li>
            <li><a href="Logout">Logout</a></li>
        </ul>
    </nav>
</header>

<main>
    <h1>Ordini ricevuti</h1>

    <%
        if (allOrders == null || allOrders.isEmpty()) {
    %>
        <p class="no-orders">Nessun ordine trovato.</p>
    <%
        } else {
    %>
        <table border="1" cellpadding="8" cellspacing="0" style="width: 100%; border-collapse: collapse; margin-top: 20px;">
            <thead>
                <tr style="background-color: #4a7c59; color: white;">
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
                        <form action="adminOrderDetails.jsp" method="get">
   							 <input type="hidden" name="orderId" value="<%= order.getId() %>">
    						 <input type="hidden" name="token" value="<%= token %>">
   						     <button type="submit">Dettagli</button>
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

<footer>
    <p>&copy; 2025 MyGarden - Amministrazione</p>
</footer>

</body>
</html>
