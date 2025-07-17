<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
 <%
     String username = (String) session.getAttribute("username");
     Boolean isAdmin = (Boolean) session.getAttribute("isAdmin");
     String activePage = (String) request.getAttribute("activePage");
     if (activePage == null) activePage = "";

     // Ottieni il nome del file JSP corrente
     String currentPage = request.getRequestURI().substring(request.getContextPath().length());
     // Rimuovi il primo slash se presente per ottenere solo il nome del file
     if (currentPage.startsWith("/")) {
         currentPage = currentPage.substring(1);
     }
 %>

 <link rel="stylesheet" href="styles/styleHeader.css">
 <%-- Includi gli stili per la modale qui. Se hai già questi stili in styleSidebar.css, puoi rimuovere questo blocco <style>. --%>
 <header>
     <div class="header-content-wrapper">
         <a href="index.jsp" class="brand">MyGarden</a>

         <nav class="main-nav">
             <ul class="nav-links">
                 <li><a href="index.jsp" id="signed">Home</a></li>

                 <% if (isAdmin != null && isAdmin) { %>
                     <li><a href="<%= request.getContextPath() %>/product">Gestione Catalogo</a></li>
                     <li><a href="admin/adminOrders.jsp">Gestione Ordini</a></li>
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
					    <li><a href="javascript:void(0);" onclick="logout()">Logout</a></li>
					<% } else { %>
					    <li><a href="https://localhost/MyGardenProject/login.jsp">Accedi</a></li>
					<% } %>
             </ul>
         </nav>

         <div class="header-icons">
         <% if ("carrello.jsp".equals(currentPage)) { %>
                  <a href="#" class="icon-link" title="Carrello" id="cart-button">
          <% } else{%>
             	<a href="#" class="icon-link" title="Carrello" id="cart-button" onclick="openCart()">
            <% }%>
             <svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
	        <circle cx="9" cy="21" r="1"></circle>
	        <circle cx="20" cy="21" r="1"></circle>
	        <path d="m1 1 4 4 14 1-1 9H6"></path>
	    </svg>
	</a>

             <a href="<%= (username != null) ? "profilo.jsp" : "https://localhost/MyGardenProject/login.jsp" %>" class="icon-link" title="<%= (username != null) ? "Profilo" : "Accedi" %>">
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
      <% if (!"carrello.jsp".equals(currentPage)) { %>
                  <div id="cartSidebar" class="cart-sidebar">
				        <a href="javascript:void(0)" class="close-btn" onclick="closeCart()">&times;</a>
				        <h2>Il tuo Carrello</h2>
				        <div id="cart-items">
				            <p class="empty-cart-message">Il carrello è vuoto.</p>
				        </div>
				        <div class="cart-total">
				            <span>Totale:</span>
				            <span id="cart-total-price">€0.00</span>
				        </div>
				        <button class="checkout-btn">Procedi al Checkout</button>
				    </div>
				    <!-- Modale di Avviso -->
					<div id="cart-modal" class="modal">
					    <div class="modal-content">
					        <span id="modal-close" class="close">&times;</span>
					        <p id="modal-message"></p>
					    </div>
					</div>
         <%}%>
 </header>