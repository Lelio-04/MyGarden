<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String username = (String) session.getAttribute("username");
    Boolean isAdmin = (Boolean) session.getAttribute("isAdmin");
    String activePage = (String) request.getAttribute("activePage");
    if (activePage == null) activePage = "";
%>
<link rel="stylesheet" href="styles/dropdown.css">
<link rel="stylesheet" href="styles/styleHeader.css">

<header>
    <!-- Il div header-content-wrapper ora gestisce la larghezza massima e il centraggio del contenuto -->
    <div class="header-content-wrapper">
        <!-- Logo -->
        <a href="index.jsp" class="brand">MyGarden</a>

        <!-- NAVBAR -->
        <nav class="main-nav">
            <ul class="nav-links">
                <li><a href="index.jsp" id="signed">Home</a></li>

                <% if (isAdmin != null && isAdmin) { %>
                    <li><a href="<%= request.getContextPath() %>/product">Gestione Catalogo</a></li>
                    <li><a href="admin/adminOrders.jsp">Gestione Ordini</a></li>
                <% } else { %>
                    <li><a href="#contattaci">Contattaci</a></li>
                    <li class="dropdown">
                        <a href="<%= request.getContextPath() %>/product" class="dropdown-toggle">Catalogo</a>
                        <ul class="dropdown-menu">
                            <li><a href="product?categoria=Piante da Interno">Piante da Interno</a></li>
                            <li><a href="product?categoria=Piante da Esterno">Piante da Esterno</a></li>
                            <li><a href="product?categoria=Piante Aromatiche">Piante Aromatiche</a></li>
                            <li><a href="product?categoria=Piante Fiorite">Piante Fiorite</a></li>
                            <li><a href="product?categoria=Piante Grasse">Piante Grasse</a></li>
                        </ul>
                    </li>
                    <li><a href="carrello.jsp">Carrello</a></li>
                    <li><a href="ordini.jsp">Ordini</a></li>
                <% } %>

                <% if (username != null) { %>
                    <li><a href="Logout">Logout</a></li>
                <% } else { %>
                    <li><a href="login.jsp">Accedi</a></li>
                <% } %>
            </ul>
        </nav>

        <!-- ICONE -->
        <div class="header-icons">
            <a href="#" class="icon-link" title="Carrello" onclick="apriSidebarCarrello(event)">
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
</header>