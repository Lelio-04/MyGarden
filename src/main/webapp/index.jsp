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
     <link rel="preconnect" href="https://fonts.googleapis.com">
     <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
     <link href="https://fonts.googleapis.com/css2?family=Montserrat:wght@400;500;600;700;800&display=swap" rel="stylesheet">
 </head>
 <body>

    <jsp:include page="header.jsp" />

     <main>
         <section class="hero">
             <section class="evid">
                 <h2>Benvenuto su MyGarden</h2>
                 <p>Scopri il verde perfetto per la tua casa e il tuo giardino.</p>
                 <a href="catalogo.jsp" class="btn">Sfoglia il catalogo</a>
             </section>
         </section>

         <section class="featured-categories-section">
             <div class="container">
                 <h2>Esplora il Nostro Mondo Verde</h2>
                 <p>Trova la pianta perfetta per ogni spazio e ogni esigenza.</p>

                 <div class="category-grid">
                     <a href="product?categoria=Piante da Interno" class="category-card">
                         <img src="images/categoria_interni.jpg" alt="Piante da Interno">
                         <h3>Piante da Interno</h3>
                     </a>
                     <a href="product?categoria=Piante da Esterno" class="category-card">
                         <img src="images/categoria_esterni.jpg" alt="Piante da Esterno">
                         <h3>Piante da Esterno</h3>
                     </a>
                     <a href="product?categoria=Piante Aromatiche" class="category-card">
                         <img src="images/categoria_aromatiche.jpg" alt="Piante Aromatiche">
                         <h3>Piante Aromatiche</h3>
                     </a>
                     <a href="product?categoria=Piante Grasse" class="category-card">
                         <img src="images/categoria_grasse.jpg" alt="Piante Grasse">
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
                         <img src="images/icon_qualita.png" alt="Icona Qualità">
                         <h3>Qualità Garantita</h3>
                         <p>Solo le migliori piante, selezionate con cura dai nostri esperti.</p>
                     </div>
                     <div class="feature-item">
                         <img src="images/icon_spedizione.png" alt="Icona Spedizione">
                         <h3>Spedizione Sicura</h3>
                         <p>Consegna rapida e protetta, direttamente a casa tua.</p>
                     </div>
                     <div class="feature-item">
                         <img src="images/icon_supporto.png" alt="Icona Supporto">
                         <h3>Supporto Dedicato</h3>
                         <p>Siamo qui per consigliarti e aiutarti in ogni fase.</p>
                     </div>
                     <div class="feature-item">
                         <img src="images/icon_varieta.png" alt="Icona Varietà">
                         <h3>Vasta Selezione</h3>
                         <p>Dalle piante rare alle classiche, trova ciò che cerchi.</p>
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