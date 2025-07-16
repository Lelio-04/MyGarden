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
                     <li><a href="Logout">Logout</a></li>
                 <% } else { %>
                     <li><a href="login.jsp">Accedi</a></li>
                 <% } %>
             </ul>
         </nav>

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

 <!-- Sidebar Carrello (Spostata qui per essere inclusa in tutte le pagine) -->
 <div id="sidebar-carrello" style="display:none; position: fixed; right: 0; top: 0; width: 350px; height: 100vh; background: white; border-left: 1px solid #ccc; padding: 20px; overflow-y: auto; z-index: 10000; box-shadow: -2px 0 10px rgba(0,0,0,0.2);">
     <button onclick="chiudiSidebar()">&times;</button>
     <h3>🛒 Il tuo carrello</h3>
     <div id="carrello-items"></div>
     <hr>
     <strong>Totale: €<span id="carrello-totale">0.00</span></strong>
     <br><br>
     <button id="svuota-carrello-btn" onclick="svuotaCarrello()">Svuota Carrello</button>
     <div id="checkout-section"></div>
 </div>

 <!-- Modale Personalizzata HTML (Spostata qui per essere inclusa in tutte le pagine) -->
 <div id="custom-modal-overlay" class="custom-modal-overlay">
     <div class="custom-modal">
         <h3 id="custom-modal-title" class="custom-modal-title"></h3>
         <p id="custom-modal-message" class="custom-modal-message"></p>
         <div id="custom-modal-buttons" class="custom-modal-buttons">
             <!-- I bottoni verranno aggiunti dal JavaScript -->
         </div>
     </div>
 </div>
