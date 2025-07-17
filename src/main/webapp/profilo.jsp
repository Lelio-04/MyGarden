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
                email = rs.getString("email") != null ? rs.getString("email") : "";
                telefono = rs.getString("telefono") != null ? rs.getString("telefono") : "";
                dataNascita = rs.getString("data_nascita") != null ? rs.getString("data_nascita") : "";
                indirizzo = rs.getString("indirizzo") != null ? rs.getString("indirizzo") : "";
                citta = rs.getString("citta") != null ? rs.getString("citta") : "";
                provincia = rs.getString("provincia") != null ? rs.getString("provincia") : "";
                cap = rs.getString("cap") != null ? rs.getString("cap") : "";
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
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Profilo Utente</title>
    <link rel="stylesheet" href="styles/styleSidebar.css">
    <link rel="stylesheet" href="styles/styleProfilo.css">
    <link rel="icon" href="images/favicon.png" type="image/png">
    <script>
        const isLoggedIn = <%= (username != null) ? "true" : "false" %>;
    </script>
    <script src="scripts/sidebar.js"></script>
</head>
<body>

<jsp:include page="header.jsp" />

<main>
    <div class="profile-section">
        <h3>Profilo Utente</h3>
        <ul class="profile-list">
            <li><strong>Username:</strong> <span><%=username%></span></li>
            <li><strong>Email:</strong> <span><%=email%></span></li>
            <li><strong>Telefono:</strong> <span><%=telefono%></span></li>
            <li><strong>Data di nascita:</strong> <span><%=dataNascita%></span></li>
            <li><strong>Indirizzo:</strong> <span><%=indirizzo%></span></li>
            <li><strong>Città:</strong> <span><%=citta%></span></li>
            <li><strong>Provincia:</strong> <span><%=provincia%></span></li>
            <li><strong>CAP:</strong> <span><%=cap%></span></li>
        </ul>
    </div>
</main>

<jsp:include page="footer.jsp" />

</body>
</html>