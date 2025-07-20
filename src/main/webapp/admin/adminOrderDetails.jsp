<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, java.text.SimpleDateFormat" %>
<%@ page import="javax.sql.DataSource" %>
<%@ page import="it.unisa.order.OrderDAO, it.unisa.order.OrderItemBean" %>
<%@ page session="true" %>

<%
    //Controllo accesso admin
    Boolean isAdmin = (Boolean) session.getAttribute("isAdmin");
    if (isAdmin == null || !isAdmin) {
        response.sendRedirect("../login.jsp?next=admin/adminOrders.jsp");
        return;
    }

    //Controllo token CSRF
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
<%@ page import="java.util.*, it.unisa.db.ProductBean" %>
<%
    if (isAdmin == null || !isAdmin) {
        response.sendRedirect("login.jsp");
        return;
    }

    Collection<ProductBean> products = (Collection<ProductBean>) request.getAttribute("products");
    ProductBean selectedProduct = (ProductBean) request.getAttribute("product");
    String errorMessage = (String) request.getAttribute("errorMessage");

    String token = (String) session.getAttribute("sessionToken");
    if (token == null && request.getCookies() != null) {
        for (Cookie c : request.getCookies()) {
            if ("sessionToken".equals(c.getName())) {
                token = c.getValue();
                break;
            }
        }
    }
%>
 <%
     String username = (String) session.getAttribute("username");
     String activePage = (String) request.getAttribute("activePage");
     if (activePage == null) activePage = "";

     String currentPage = request.getRequestURI().substring(request.getContextPath().length());
     if (currentPage.startsWith("/")) {
         currentPage = currentPage.substring(1);
     }
     String cartMergeMessage = (String) session.getAttribute("cartMergeMessage");
     if (cartMergeMessage != null) {
         session.removeAttribute("cartMergeMessage");
     }
 %>


<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Dettagli Ordine Admin #<%= orderId %></title>
    <link rel="stylesheet" href="../styles/styleAdminOrderDet.css">
    <link rel="stylesheet" href="../styles/styleHeader.css">
</head>
<body>
<header>
     <div class="header-content-wrapper">
         <a href="../index.jsp" class="brand">MyGarden</a>

         <nav class="main-nav">
             <ul class="nav-links">
                 <li><a href="../index.jsp" id="signed">Home</a></li>

                 <% if (isAdmin != null && isAdmin) { %>
                     <li><a href="<%= request.getContextPath() %>/product">Torna al catalogo</a></li>
                     <li><a href="adminOrders.jsp">Torna agli ordini</a></li>
                 <% } else { %>
                     <%-- Mostra "Contattaci" SOLO se la pagina corrente è index.jsp --%>
                     <% if ("index.jsp".equals(currentPage)) { %>
                         <li><a href="#contattaci">Contattaci</a></li>
                     <% } %>
                     <li class="dropdown">
                         <a href="<%= request.getContextPath() %>/product" class="dropdown-toggle">Catalogo</a>
                         <ul class="dropdown-menu">
                             <li><a href="product?categoria=Piante da Interno">Piante da Interno</a></li>
                             <li><a href="product?categoria=Piante da Esterno">Piante da Esterno</a></li>
                             <li><a href="product?categoria=Piante Aromatiche">Piante Aromatiche</a></li>
                             <li><a href="product?categoria=Piante Grasse">Piante Grasse</a></li>
                             <li><a href="product?categoria=Piante Fiorite">Fiori</a></li>
                             <li><a href="product?categoria=Attrezzi">Attrezzi</a></li>
                         </ul>
                     </li>
                     <li><a href="carrello.jsp">Carrello</a></li>
                     <li><a href="ordini.jsp">Ordini</a></li>
                 <% } %>

                 <% if (username != null) { %>
					     <li><a href="../Logout">Logout</a></li>
					<% } else { %>
					    <li><a href="https://localhost/MyGardenProject/login.jsp">Accedi</a></li>
					<% } %>
             </ul>
         </nav>

         <div class="header-icons">

             <a href="<%= (username != null) ? "../profilo.jsp" : "https://localhost/MyGardenProject/login.jsp" %>" class="icon-link" title="<%= (username != null) ? "Profilo" : "Accedi" %>">
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
