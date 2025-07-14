<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, javax.sql.DataSource" %>
<%
    String username = (String) session.getAttribute("username");

    if (username == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    DataSource ds = (DataSource) application.getAttribute("DataSourceUtenti");
    String email = "", telefono = "", dataNascita = "", indirizzo = "", citta = "", provincia = "", cap = "";

    try (Connection conn = ds.getConnection()) {
        String sql = "SELECT * FROM users WHERE username = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    email = rs.getString("email");
                    telefono = rs.getString("telefono");
                    dataNascita = rs.getString("data_nascita");
                    indirizzo = rs.getString("indirizzo");
                    citta = rs.getString("citta");
                    provincia = rs.getString("provincia");
                    cap = rs.getString("cap");
                }
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
%>

<!DOCTYPE html>
<html lang="it">
<head>
    <meta charset="UTF-8">
    <title>Profilo Utente</title>
    <link rel="stylesheet" href="styles/styleBase.css"> <!-- già include il tuo stile -->
   	<link rel="stylesheet" href="styles/styleProfilo.css">
    <link rel="icon" href="images/favicon.png" type="image/png">
</head>
<body>

<jsp:include page="header.jsp" />


<main>
    <div class="profile-section">
        <h3>Profilo Utente</h3>
        <ul class="profile-list">
            <li><strong>Username:</strong> <%= username %></li>
            <li><strong>Email:</strong> <%= email %></li>
            <li><strong>Telefono:</strong> <%= telefono %></li>
            <li><strong>Data di nascita:</strong> <%= dataNascita %></li>
            <li><strong>Indirizzo:</strong> <%= indirizzo %></li>
            <li><strong>Città:</strong> <%= citta %></li>
            <li><strong>Provincia:</strong> <%= provincia %></li>
            <li><strong>CAP:</strong> <%= cap %></li>
        </ul>
    </div>
</main>

   	<jsp:include page="footer.jsp" />
    
</body>
</html>
