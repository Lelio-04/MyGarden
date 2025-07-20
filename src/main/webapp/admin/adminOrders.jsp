<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, java.text.SimpleDateFormat, it.unisa.order.OrderDAO, it.unisa.order.OrderBean" %>
<%@ page import="javax.sql.DataSource, java.sql.*" %>
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
<%@ page import="java.util.*, it.unisa.db.ProductBean" %>
<%
    if (isAdmin == null || !isAdmin) {
        response.sendRedirect("login.jsp");
        return;
    }

    Collection<ProductBean> products = (Collection<ProductBean>) request.getAttribute("products");
    ProductBean selectedProduct = (ProductBean) request.getAttribute("product");
    String errorMessage = (String) request.getAttribute("errorMessage");

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
     String activePage = (String) request.getAttribute("activePage");
     if (activePage == null) activePage = "";

     // Ottieni il nome del file JSP corrente
     String currentPage = request.getRequestURI().substring(request.getContextPath().length());
     // Rimuovi il primo slash se presente per ottenere solo il nome del file
     if (currentPage.startsWith("/")) {
         currentPage = currentPage.substring(1);
     }
     String cartMergeMessage = (String) session.getAttribute("cartMergeMessage");
     if (cartMergeMessage != null) {
         session.removeAttribute("cartMergeMessage");
     }
 %>

<!DOCTYPE html>
<html lang="it">
<head>
    <meta charset="UTF-8">
    <title>Gestione Ordini - Admin</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/styles/styleAdminOrders.css">
    <link rel="stylesheet" href="../styles/styleHeader.css">
    <link rel="icon" href="images/favicon.png" type="image/png">
</head>
<body>

<header>
     <div class="header-content-wrapper">
         <a href="../index.jsp" class="brand">MyGarden</a>

         <nav class="main-nav">
             <ul class="nav-links">
                 <li><a href="../index.jsp" id="signed">Home</a></li>

                 <% if (isAdmin != null && isAdmin) { %>
                     <li><a href="<%= request.getContextPath() %>/product">Gestione Catalogo</a></li>
                     <li><a href="adminOrders.jsp">Gestione Ordini</a></li>
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
            <%!
public Map<Integer, String> getUserEmails(DataSource ds) {
    Map<Integer, String> emails = new HashMap<>();
    String sql = "SELECT id, email FROM users";

    try (Connection conn = ds.getConnection();
         PreparedStatement stmt = conn.prepareStatement(sql);
         ResultSet rs = stmt.executeQuery()) {

        while (rs.next()) {
            emails.put(rs.getInt("id"), rs.getString("email"));
        }

    } catch (SQLException e) {
        e.printStackTrace();
    }

    return emails;
}
%>
<%
    DataSource ds = (DataSource) application.getAttribute("DataSourceStorage");
    Map<Integer, String> userEmails = getUserEmails(ds);
%>

            
            <%
                for (OrderBean order : allOrders) {
            %>
                <tr>
                    <td><%= order.getId() %></td>
                    <td><%= userEmails.get(order.getUserId()) %></td>
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
