<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, it.unisa.cart.CartBean, it.unisa.db.ProductBean, it.unisa.register.User" %>
<%
    String username = (String) session.getAttribute("username");
    Integer userId = (Integer) session.getAttribute("userId");
    List<CartBean> cartItems = (List<CartBean>) request.getAttribute("cartItems");
    User user = (User) request.getAttribute("user");

    if (username == null || userId == null || user == null) {
        response.sendRedirect("login.jsp?next=checkout.jsp");
        return;
    }

    if (cartItems == null || cartItems.isEmpty()) {
        response.sendRedirect("carrello.jsp");
        return;
    }

    double total = 0;

    // ✅ Recupera token dalla sessione o cookie
    String token = (String) session.getAttribute("sessionToken");
    if (token == null && request.getCookies() != null) {
        for (Cookie c : request.getCookies()) {
            if ("sessionToken".equals(c.getName())) {
                token = c.getValue();
                break;
            }
        }
    }
%>

<!DOCTYPE html>
<html lang="it">
<head>
    <meta charset="UTF-8">
    <title>Checkout</title>
    <link rel="stylesheet" href="styles/styleSidebar.css">
    <link rel="stylesheet" href="styles/styleCheckout.css">
    <script>
	  const isLoggedIn = <%= (username != null) ? "true" : "false" %>;
	</script>
	<script src="scripts/sidebar.js"></script>
</head>
<body>

<jsp:include page="header.jsp" />

<div class="checkout-form">
    <h2>Conferma Ordine</h2>

    <form action="checkout" method="post">
        <!-- Campo hidden per token -->
        <input type="hidden" name="token" value="<%= token != null ? token : "" %>">

        <label for="fullName">Nome e Cognome</label>
        <input type="text" name="fullName" id="fullName" value="<%= user.getUsername() != null ? user.getUsername() : "" %>" required>

        <label for="address">Indirizzo di spedizione</label>
        <textarea name="address" id="address" rows="2" required><%= user.getIndirizzo() != null ? user.getIndirizzo() : "" %></textarea>

        <label for="city">Città</label>
        <input type="text" name="city" id="city" value="<%= user.getCitta() != null ? user.getCitta() : "" %>" required>

        <label for="cap">CAP</label>
        <input type="text" name="cap" id="cap" value="<%= user.getCap() != null ? user.getCap() : "" %>" required>

        <label for="payment">Metodo di pagamento</label>
        <select name="payment" id="payment" required>
            <option value="">-- Seleziona --</option>
            <option value="carta">Carta di Credito</option>
            <option value="paypal">PayPal</option>
            <option value="contrassegno">Pagamento alla consegna</option>
        </select>

        <div class="checkout-summary">
            <h3>Riepilogo ordine</h3>
            <table>
                <thead>
                    <tr>
                        <th>Prodotto</th>
                        <th>Quantità</th>
                        <th>Prezzo</th>
                        <th>Subtotale</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        for (CartBean item : cartItems) {
                            ProductBean product = item.getProduct();
                            double price = product.getPrice();
                            int quantity = item.getQuantity();
                            double subtotal = price * quantity;
                            total += subtotal;
                    %>
                    <tr>
                    <td>
      				<img src="<%= product.getImage() %>" alt="<%= product.getName() %>">
      				</td>
                        <td><%= product.getName() %></td>
                        <td><%= quantity %></td>
                        <td>€ <%= String.format("%.2f", price) %></td>
                    </tr>
                    <%
                        }
                    %>
                    <tr>
                        <td colspan="3"><strong>Totale</strong></td>
                        <td><strong>€ <%= String.format("%.2f", total) %></strong></td>
                    </tr>
                </tbody>
            </table>
        </div>

        <button type="submit">Conferma ed effettua ordine</button>
    </form>
</div>

<jsp:include page="footer.jsp" />

</body>
</html>