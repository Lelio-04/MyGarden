<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
 <%
     String username = (String) session.getAttribute("username");
     Boolean isAdmin = (Boolean) session.getAttribute("isAdmin");
     String sessionToken = (String) session.getAttribute("sessionToken");

     // Se loggato ma token mancante, lo generiamo
     if (username != null && sessionToken == null) {
         sessionToken = java.util.UUID.randomUUID().toString();
         session.setAttribute("sessionToken", sessionToken);
     }
 %>
 <%
     // Questo attributo è utile per marcare il link attivo nell'header
     request.setAttribute("activePage", "home");
 %>
 <!DOCTYPE html>
 <html lang="it">
 <head>
     <meta charset="UTF-8">
     <title>MyGarden - Home</title>
     <link rel="stylesheet" href="styles/styleBase.css">
     <link rel="stylesheet" href="styles/styleHeader.css">
     <link rel="stylesheet" href="styles/styleHomePage.css">
     <link rel="icon" href="images/favicon.png" type="image/png">
     
 </head>
 <body>

    <jsp:include page="header.jsp" />
    
    
    <section class="video-hero">
	    <video autoplay muted loop playsinline >
	        <source src="video/home-banner.mp4" type="video/mp4">
	        Il tuo browser non supporta il tag video.
	    </video>
	    <div class="video-overlay">
	        <h1>Benvenuto su MyGarden</h1>
	        <p>Scopri il verde perfetto per la tua casa e il tuo giardino.</p>
	    </div>
	</section>
	

    

     <main>
         <section class="featured-categories-section">
             <div class="container">
                 <h2>Esplora il Nostro Mondo Verde</h2>
                 <p>Trova la pianta perfetta per ogni spazio e ogni esigenza.</p>

                 <div class="category-grid">
                     <a href="product?categoria=Piante da Interno" class="category-card">
                         <img src="https://i.pinimg.com/736x/a4/46/45/a446450e863c1be420adbb2f664b53e9.jpg" alt="Piante da Interno">
                         <h3>Piante da Interno</h3>
                     </a>
                     <a href="product?categoria=Piante da Esterno" class="category-card">
                         <img src="https://i.pinimg.com/1200x/c4/f2/1c/c4f21c38fbdefd12a514ed814a6e4cde.jpg" alt="Piante da Esterno">
                         <h3>Piante da Esterno</h3>
                     </a>
                     <a href="product?categoria=Piante Aromatiche" class="category-card">
                         <img src="https://i.pinimg.com/1200x/3f/1f/89/3f1f894095e6d7494c10fe0d3b0aa551.jpg" alt="Piante Aromatiche" >
                         <h3>Piante Aromatiche</h3>
                     </a>
                     <a href="product?categoria=Piante Grasse" class="category-card">
                         <img src="https://i.pinimg.com/736x/5b/43/fd/5b43fd6ca8c6ddd5478b5924d91cf736.jpg" alt="Piante Grasse">
                         <h3>Piante Grasse</h3>
                     </a>
                 </div>
                 <div class="text-center" style="margin-top: 40px;">
                     <a href="product" class="btn btn-secondary-outline">Vedi tutte le categorie</a>
                 </div>
             </div>
         </section>

         <section class="why-choose-us-section">
             <div class="container">
                 <h2>Perché Scegliere MyGarden?</h2>
                 <p>La tua passione per il verde merita il meglio.</p>

                 <div class="features-grid">
                     <div class="feature-item">
                         <img src="https://egarden.store/wp-content/uploads/2020/01/egarden-category-sidebar-imballaggio.png" alt="Icona Qualità">
                         <h3>Qualità Garantita</h3>
                         <p>Solo le migliori piante, selezionate con cura dai nostri esperti.</p>
                     </div>
                     <div class="feature-item">
                         <img src="https://egarden.store/wp-content/uploads/2020/01/egarden-category-sidebar-spedizione.png" alt="Icona Spedizione">
                         <h3>Spedizione Sicura</h3>
                         <p>Consegna rapida e protetta, direttamente a casa tua.</p>
                     </div>
                     <div class="feature-item">
                         <img src="https://egarden.store/wp-content/uploads/2020/01/egarden-category-sidebar-servizio-clienti.png" alt="Icona Supporto">
                         <h3>Supporto Dedicato</h3>
                         <p>Siamo qui per consigliarti e aiutarti in ogni fase.</p>
                     </div>
                 </div>
             </div>
         </section>

         <% if (!Boolean.TRUE.equals(isAdmin)) { %>
         <section id="contattaci" class="contact-section">
             <div class="container">
                 <form class="contact-form" action="#" method="POST">
                     <h2>Contattaci</h2>
                     <p>Hai domande o suggerimenti? Scrivici!</p>
                     <div class="form-group">
                         <label for="email">Email *</label>
                         <input type="email" id="email" name="email" required placeholder="Inserisci la tua email">
                     </div>
                     <div class="form-group">
                         <label for="messaggio">Messaggio *</label>
                         <textarea id="messaggio" name="messaggio" rows="6" required placeholder="Scrivi qui il tuo messaggio..."></textarea>
                     </div>
                     <button type="submit" class="btn-contact">Invia Messaggio</button>
                 </form>
             </div>
         </section>
         <% } %>
     </main>
     <div id="sidebar-carrello" style="display:none; position: fixed; right: 0; top: 0; width: 350px; height: 100vh; background: white; border-left: 1px solid #ccc; padding: 20px; overflow-y: auto; z-index: 10000; box-shadow: -2px 0 10px rgba(0,0,0,0.2);">
         <button onclick="chiudiSidebar()" style="float:right; font-size: 20px; border:none; background:none; cursor:pointer;">&times;</button>
         <h3>🛒 Il tuo carrello</h3>
         <div id="carrello-items"></div>
         <hr>
         <strong>Totale: €<span id="carrello-totale">0.00</span></strong>
         <br><br>
         <button onclick="svuotaCarrello()" style="background:#e53935; color:white; border:none; padding:10px; cursor:pointer; border-radius:5px;">Svuota Carrello</button>

         <div id="checkout-section" style="margin-top: 20px; text-align: center;"></div>
     </div>

 <script>
   const isLoggedIn = <%= (username != null) ? "true" : "false" %>;
 </script>
 <script src="scripts/sidebar.js"></script>
    <jsp:include page="footer.jsp" />

 </body>
 </html>