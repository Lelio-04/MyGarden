<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String username = (String) session.getAttribute("username");
%>
<!DOCTYPE html>
<html lang="it">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>MyGarden - Home</title>
    <link rel="stylesheet" href="styles/styleBase.css">
    <link rel="stylesheet" href="styles/styleHomePage.css">
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
                <li><a href="index.jsp" id = "home">Home</a></li>
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
                    <li><a href="carrello.jsp">Gestione Ordini</a></li>
                <% } else { %>
                    <li><a href="carrello.jsp">Carrello</a></li>
                <% } %>
                <% Boolean isAdmin3 = (Boolean) request.getSession().getAttribute("isAdmin");  
                   if(isAdmin3 != null && isAdmin3){
                	
                
                %>
                    
                <% } else { %>
                    <li><a href="#contattaci">Contattaci</a></li>
                <% } %>
                
                <% if (username != null) { %>
                    <li><a href="Logout">Logout</a></li>
                <% } else { %>
                    <li><a href="login.jsp">Accedi</a></li>
                <% } %>
            </ul>
        </nav>
    </header>

    <main>
        <section class="hero">
        	<section class = "evid">
            	<h2>Benvenuto su MyGarden</h2>
            	<p>Scopri il verde perfetto per la tua casa e il tuo giardino.</p>
            	<a href="catalogo.jsp" class="btn">Sfoglia il catalogo</a>
            </section>
            
        </section>

        <section id="contattaci" class="contact-section">
            <div class="container">
                
                <form class="contact-form" action="#" method="POST">
                <h2>Contattaci</h2>
                <p>Hai domande o suggerimenti? Scrivici!</p>
                    <div class="form-group">
                        <label for="email">Email *</label>
                        <input type="email" id="email" name="email" required placeholder = "Inserisci la tua email">
                    </div>
                    <div class="form-group">
                        <label for="messaggio">Messaggio *</label>
                        <textarea id="messaggio" name="messaggio" rows="6" required placeholder="Scrivi qui il tuo messaggio..."></textarea>
                    </div>
                    <button type="submit" class="btn-contact">Invia Messaggio</button>
                </form>
            </div>
        </section>
    </main>

    <footer>
        <p>&copy; 2025 MyGarden - Tutti i diritti riservati.</p>
    </footer>
    <script src="scripts/main.js"></script>
</body>
</html>
