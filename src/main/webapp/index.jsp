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
     
     request.setAttribute("activePage", "home");
 %>
 <!DOCTYPE html>
 <html lang="it">
 <head>
     <meta charset="UTF-8">
     <title>MyGarden - Home</title>
     <link rel="stylesheet" href="styles/styleHomePage.css">
     <link rel="stylesheet" href="styles/styleSidebar.css">
     <link rel="icon" href="images/favicon.png" type="image/png">
      <script>
      var isLoggedIn = <%= (username != null) ? "true" : "false" %>;
      window.addEventListener('DOMContentLoaded', () => {
    	    const cartMerged = localStorage.getItem('cartMerged');
    	    const guestCart = localStorage.getItem('guestCart');

    	    if (!cartMerged && guestCart) {
    	        console.log("🔄 Tentativo di eseguire il merge del carrello...");
    	        mergeGuestCartWithUserCart();
    	    }
    	});

    </script>
    
    <script src="scripts/sidebar.js" defer></script>
 </head>
 <body>

    <jsp:include page="header.jsp" />
    
    
    <section class="video-hero">
	    <video autoplay muted loop playsinline >
	        <source src="video/home-banner.mp4" type="video/mp4">à

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
                     <a href="product?categoria=Piante Fiorite" class="category-card">
                         <img src="https://i.pinimg.com/736x/b8/e3/db/b8e3db14863858eaa31e23f1fe9862ce.jpg" alt="Piante Grasse">
                         <h3>Fiori</h3>
                     </a>
                     <a href="product?categoria=Attrezzi" class="category-card">
                         <img src="https://i.pinimg.com/736x/a9/39/a7/a939a773ec750ecef4d0352998e728af.jpg" alt="Piante Grasse">
                         <h3>Attrezzi</h3>
                     </a>
                 </div>
                 <div class="text-center" style="margin-top: 40px;">
                     <a href="product" class="btn btn-secondary-outline">Vai al catalogo</a>
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

    <jsp:include page="footer.jsp" />
 </body>
 </html>