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
    <link rel="stylesheet" href="styles/styleBase.css">
    <style>
        .checkout-form {
            max-width: 600px;
            margin: 40px auto;
            padding: 20px;
            border: 1px solid #ddd;
            border-radius: 8px;
            background-color: #f9f9f9;
            margin-top: 200px
        }
        .checkout-form h2 { margin-bottom: 20px; }
        .checkout-form label { display: block; margin-top: 10px; font-weight: bold; }
        .checkout-form input, .checkout-form select, .checkout-form textarea {
            width: 100%; padding: 8px; margin-top: 5px; box-sizing: border-box;
        }
        .checkout-summary { margin-top: 30px; }
        .checkout-summary table {
            width: 100%; border-collapse: collapse;
        }
        .checkout-summary th, .checkout-summary td {
            padding: 8px; border-bottom: 1px solid #ccc;
        }
        .checkout-form button {
            margin-top: 20px; padding: 10px 20px;
            background-color: #3c8d40; color: white;
            border: none; border-radius: 4px; cursor: pointer;
        }
        .checkout-form button:hover { background-color: #2e7033; }
    </style>
</head>
<body>

<jsp:include page="header.jsp" />

<div class="checkout-form">
    <h2>Conferma Ordine</h2>

    <form action="checkout" method="post">
        <!-- ✅ Campo hidden per token -->
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
                        <td><%= product.getName() %></td>
                        <td><%= quantity %></td>
                        <td>€ <%= String.format("%.2f", price) %></td>
                        <td>€ <%= String.format("%.2f", subtotal) %></td>
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
<div id="sidebar-carrello" style="display:none; position: fixed; right: 0; top: 0; width: 350px; height: 100vh; background: white; border-left: 1px solid #ccc; padding: 20px; overflow-y: auto; z-index: 10000; box-shadow: -2px 0 10px rgba(0,0,0,0.2);">
    <button onclick="chiudiSidebar()" style="float:right; font-size: 20px; border:none; background:none; cursor:pointer;">&times;</button>
    <h3>🛒 Il tuo carrello</h3>
    <div id="carrello-items"></div>
    <hr>
    <strong>Totale: €<span id="carrello-totale">0.00</span></strong>
    <br><br>
    <button onclick="svuotaCarrello()" style="background:#e53935; color:white; border:none; padding:10px; cursor:pointer; border-radius:5px;">Svuota Carrello</button>
    
    <!-- Sezione acquisto o login -->
    <div id="checkout-section" style="margin-top: 20px; text-align: center;"></div>
</div>

<script>
  const isLoggedIn = <%= (username != null) ? "true" : "false" %>;
</script>
<script src="scripts/sidebar.js"></script>
</body>
</html>
