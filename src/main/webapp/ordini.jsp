<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, it.unisa.order.OrderDAO, it.unisa.order.OrderBean" %>
<%@ page import="javax.sql.DataSource" %>
<%@ page session="true" %>
<%
    String username = (String) session.getAttribute("username");
%>
<%
    Integer userId = (Integer) session.getAttribute("userId");

    if (userId == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Recupera il DataSource dal ServletContext
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

                <!-- Icona profilo dinamica -->
                <a href="<%= (username != null) ? "profilo.jsp" : "login.jsp" %>" class="icon-link" title="<%= (username != null) ? "Profilo" : "Accedi" %>">
                    <svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path>
                        <circle cx="12" cy="7" r="4"></circle>
                    </svg>
                </a>

                <!-- Registrazione sempre visibile -->
                <% if (username != null) { %>
                    
                <% } else { %>
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
                <li><a href="index.jsp" id = "signed">Home</a></li>
                <% Boolean isAdmin3 = (Boolean) request.getSession().getAttribute("isAdmin");  
                   if(isAdmin3 != null && isAdmin3){
                	
                
                %>
                    
                <% } else { %>
                    <li><a href="#contattaci">Contattaci</a></li>
                <% } %>
                <% Boolean isAdmin = (Boolean) request.getSession().getAttribute("isAdmin");  
                   if(isAdmin != null && isAdmin){
                	
                
                %>
                    <li><a href="<%=request.getContextPath()%>/product">Gestione Catalogo</a></li>
                <% } else { %>
                    <li><a href="<%=request.getContextPath()%>/product">Catalogo</a></li>
                <% } %>
                <% Boolean isAdmin2 = (Boolean) request.getSession().getAttribute("isAdmin");  
                   if(isAdmin2 != null && isAdmin2){
                
                
                %>
                    <li><a href="">Gestione Ordini</a></li>
                <% } else { %>
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
        </div>
    <%
            }
        }
    %>
</body>
</html>
