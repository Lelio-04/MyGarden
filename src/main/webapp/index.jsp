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
<!DOCTYPE html>
<html lang="it">
<head>
    <meta charset="UTF-8">
    <title>MyGarden - Home</title>
    <link rel="stylesheet" href="styles/styleBase.css">
    <link rel="stylesheet" href="styles/styleHomePage.css">
    <link rel="icon" href="images/favicon.png" type="image/png">
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
