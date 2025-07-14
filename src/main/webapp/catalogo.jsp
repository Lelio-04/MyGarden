<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, it.unisa.cart.*, it.unisa.db.*" %>
<%
    Collection<?> products = (Collection<?>) request.getAttribute("products");
    if (products == null) {
        response.sendRedirect("./product");
        return;
    }
    String username = (String) session.getAttribute("username");
    Boolean isAdmin = (Boolean) session.getAttribute("isAdmin");
%>

<!DOCTYPE html>
<html lang="it">
<head>
    <meta charset="UTF-8">
    <title>Catalogo Prodotti</title>
    <link rel="stylesheet" href="styles/styleBase.css">
    <link rel="stylesheet" href="styles/styleCatalogo.css">
    <link rel="icon" href="images/favicon.png" type="image/png">
    <style>
        .not-available {
            display: inline-block;
            padding: 10px;
            background-color: #ffcdd2;
            color: #b71c1c;
            font-weight: bold;
            border-radius: 5px;
            margin-top: 10px;
            text-align: center;
        }
    </style>
</head>
<body>
<header>
    <div class="header-top">
        <img src="images/logo.png" alt="MyGarden Logo" class="logo">
        <span class="site-title"><span class="yellow">My</span><span class="green">Garden</span></span>
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

    <nav class="main-nav">
        <ul class="nav-links">
            <li><a href="index.jsp">Home</a></li>
            <li><a href="<%=request.getContextPath()%>/product" id="signed"><%= (isAdmin != null && isAdmin) ? "Gestione Catalogo" : "Catalogo" %></a></li>
            <li><a href="cart"><%= (isAdmin != null && isAdmin) ? "Gestione Ordini" : "Carrello" %></a></li>
            
            <% if (username != null) { %>
                <li><a href="Logout">Logout</a></li>
            <% } else { %>
                <li><a href="login.jsp">Accedi</a></li>
            <% } %>
        </ul>
    </nav>
</header>

<main class="catalog-container">
    <div class="catalog-grid">
        <%
            if (!products.isEmpty()) {
                for (Object obj : products) {
                    ProductBean bean = (ProductBean) obj;
        %>
        <div class="product-card">
            <a href="DettaglioProdottoServlet?code=<%= bean.getCode() %>">
                <img src="<%= bean.getImage() %>" alt="<%= bean.getName() %>">
            </a>
            <h3><%= bean.getName() %></h3>
            <p class="price">€ <%= String.format("%.2f", bean.getPrice()) %></p>

            <% if (bean.getQuantity() > 0) { %>
                <div class="quantity-row">
                    <span class="available">Disponibilità: <%= bean.getQuantity() %></span>
                    <input type="number" id="qty-<%= bean.getCode() %>" value="1" min="1" max="<%= bean.getQuantity() %>" required>
                </div>
                <button 
				  onclick="aggiungiAlCarrello(<%= bean.getCode() %>)" 
				  data-max-qty="<%= bean.getQuantity() %>">
				  Aggiungi al Carrello
				</button>


            <% } else { %>
                <div class="not-available">Non disponibile</div>
            <% } %>
        </div>
        <%
                }
            } else {
        %>
        <p>Nessun prodotto disponibile.</p>
        <% } %>
    </div>
</main>

<footer>
    <p>&copy; 2025 MyGarden - Tutti i diritti riservati.</p>
</footer>
<!-- Sidebar Carrello -->
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
  // Passa lo stato di login da JSP a JS
  const isLoggedIn = <%= (username != null) ? "true" : "false" %>;

  function aggiornaSidebar(carrello) {
	    const container = document.getElementById('carrello-items');
	    const totaleSpan = document.getElementById('carrello-totale');

	    container.innerHTML = '';
	    totaleSpan.textContent = '0.00';

	    if (!Array.isArray(carrello) || carrello.length === 0) {
	        container.innerHTML = '<p>Il carrello è vuoto.</p>';
	        aggiornaCheckoutSection(); // aggiorna anche la sezione acquisto/login
	        return;
	    }

	    let totale = 0;

	    carrello.forEach((item,index) => {
	        const nome = item.product?.name || "Nome non disponibile";
	        const prezzo = typeof item.product?.price === "number" ? item.product.price : parseFloat(item.product?.price) || 0;
	        const quantità = typeof item.quantity === "number" ? item.quantity : Number(item.quantity) || 0;

	        // Qui prendi la quantità massima disponibile da product.quantity (o un fallback)
	        const maxQuantity = (typeof item.product?.quantity === "number" && item.product.quantity > 0) ? item.product.quantity : 1000;

	        const codice = item.product?.code || item.productCode;

	        totale += prezzo * quantità;

	        const itemDiv = document.createElement('div');
	        itemDiv.style.display = 'flex';
	        itemDiv.style.alignItems = 'center';
	        itemDiv.style.marginBottom = '10px';

	        const img = document.createElement('img');
	        img.src = item.product?.image || "images/default.png";
	        img.alt = nome;
	        img.style.width = '60px';
	        img.style.height = '60px';
	        img.style.objectFit = 'cover';
	        img.style.marginRight = '10px';
	        img.style.borderRadius = '5px';

	        const infoDiv = document.createElement('div');
	        infoDiv.style.flex = '1';

	        const nomeDiv = document.createElement('div');
	        nomeDiv.textContent = nome;
	        nomeDiv.style.fontWeight = 'bold';

	        const qtyWrapper = document.createElement('div');
	        qtyWrapper.style.display = 'flex';
	        qtyWrapper.style.alignItems = 'center';
	        qtyWrapper.style.margin = '5px 0';

	        const minusBtn = document.createElement('button');
	        minusBtn.textContent = '−';
	        minusBtn.style.width = '30px';
	        minusBtn.style.height = '30px';
	        minusBtn.style.fontSize = '18px';
	        minusBtn.style.marginRight = '5px';
	        minusBtn.style.cursor = 'pointer';
	        minusBtn.style.borderRadius = '4px';
	        minusBtn.style.border = '1px solid #ccc';
	        minusBtn.style.backgroundColor = '#f5f5f5';

	        const qtyDisplay = document.createElement('span');
	        qtyDisplay.textContent = 'Quantità: '+quantità;
	        qtyDisplay.style.minWidth = '30px';
	        qtyDisplay.style.textAlign = 'center';
	        qtyDisplay.style.fontWeight = 'bold';

	        const plusBtn = document.createElement('button');
	        plusBtn.textContent = '+';
	        plusBtn.style.width = '30px';
	        plusBtn.style.height = '30px';
	        plusBtn.style.fontSize = '18px';
	        plusBtn.style.marginLeft = '5px';
	        plusBtn.style.marginRight = '5px';
	        plusBtn.style.cursor = 'pointer';
	        plusBtn.style.borderRadius = '4px';
	        plusBtn.style.border = '1px solid #ccc';
	        plusBtn.style.backgroundColor = '#f5f5f5';

	        minusBtn.onclick = () => {
	            let newQty = quantità - 1;
	            if (newQty <= 0) {
	                rimuoviDalCarrello(codice); // rimuove completamente dal carrello
	            } else {
	                modificaQuantitàCarrello(codice, newQty); // aggiorna quantità
	            }
	        };
	        plusBtn.onclick = () => {
	            let newQty = Math.min(maxQuantity, quantità + 1);
	            if (newQty !== quantità) {
	                modificaQuantitàCarrello(codice, newQty);
	            }
	        };
			
	        qtyWrapper.appendChild(qtyDisplay);
	        qtyWrapper.appendChild(plusBtn);
	        qtyWrapper.appendChild(minusBtn);


	        const prezzoDiv = document.createElement('div');
	        prezzoDiv.textContent = 'Prezzo: ' + prezzo.toFixed(2) + ' €';

	        infoDiv.appendChild(nomeDiv);
	        infoDiv.appendChild(qtyWrapper);
	        infoDiv.appendChild(prezzoDiv);

	        const removeBtn = document.createElement('button');
	        removeBtn.textContent = 'Rimuovi';
	        removeBtn.style.marginLeft = '10px';
	        removeBtn.style.background = '#e53935';
	        removeBtn.style.color = 'white';
	        removeBtn.style.border = 'none';
	        removeBtn.style.cursor = 'pointer';
	        removeBtn.style.borderRadius = '4px';
	        removeBtn.onclick = () => rimuoviDalCarrello(codice);

	        itemDiv.appendChild(img);
	        itemDiv.appendChild(infoDiv);
	        itemDiv.appendChild(removeBtn);

	        container.appendChild(itemDiv);
	        
	        if (index < carrello.length - 1) {
	            const divider = document.createElement('hr');
	            divider.style.borderTop = '1px solid #ccc';
	            divider.style.margin = '10px 0';
	            container.appendChild(divider);
	        }
	    });

	    totaleSpan.textContent = totale.toFixed(2);
	    document.getElementById('sidebar-carrello').style.display = 'block';

	    // Aggiorna la sezione acquisto/login
	    aggiornaCheckoutSection();
	}


  function aggiornaCheckoutSection() {
	    const checkoutDiv = document.getElementById('checkout-section');
	    checkoutDiv.innerHTML = '';

	    if (!isLoggedIn) {
	        const p = document.createElement('p');
	        p.style.fontWeight = 'bold';
	        p.style.color = '#b71c1c';
	        p.innerHTML = 'Devi <a href="login.jsp" style="color:#1976d2; text-decoration: underline;">accedere</a> per acquistare i prodotti.';
	        checkoutDiv.appendChild(p);
	        return;
	    }

	    fetch('GetCartServlet')
	        .then(res => {
	            if (!res.ok) throw new Error('Errore nel recupero del carrello');
	            return res.json();
	        })
	        .then(carrello => {
	            let superaDisponibilita = false;

	            for (const item of carrello) {
	                if (item.quantity > item.product.quantity) {
	                    superaDisponibilita = true;
	                    break;
	                }
	            }

	            const form = document.createElement('form');
	            form.method = 'POST';
	            form.action = 'checkout-page';

	            form.addEventListener('submit', function(e) {
	                if (superaDisponibilita) {
	                    e.preventDefault();
	                    alert('Ci sono prodotti nel carrello con quantità superiori alla disponibilità. Riduci le quantità per procedere.');
	                }
	            });

	            const btn = document.createElement('button');
	            btn.type = 'submit';
	            btn.textContent = 'Acquista';
	            btn.style.background = '#4CAF50';
	            btn.style.color = 'white';
	            btn.style.border = 'none';
	            btn.style.padding = '10px 20px';
	            btn.style.fontSize = '16px';
	            btn.style.cursor = 'pointer';
	            btn.style.borderRadius = '5px';

	            // Puoi anche lasciare il button abilitato, così l'alert esce se cliccato comunque
	            btn.disabled = false;

	            form.appendChild(btn);
	            checkoutDiv.appendChild(form);
	        })
	        .catch(err => {
	            console.error(err);
	            const p = document.createElement('p');
	            p.style.color = '#b71c1c';
	            p.textContent = 'Errore nel caricamento del carrello. Riprova più tardi.';
	            checkoutDiv.appendChild(p);
	        });
	}


  function aggiungiAlCarrello(productCode) {
	    const qtyInput = document.getElementById('qty-' + productCode);
	    const addingQuantity = qtyInput ? parseInt(qtyInput.value) : 1;

	    const addButton = document.querySelector(`button[data-product-code="${productCode}"]`);
	    const maxQuantity = addButton ? parseInt(addButton.getAttribute('data-max-qty')) : Infinity;

	    fetch('GetCartServlet')
	        .then(res => {
	            if (!res.ok) throw new Error("Errore nel recupero del carrello");
	            return res.json();
	        })
	        .then(carrello => {
	            const itemInCart = carrello.find(item => Number(item.productCode) === Number(productCode));
	            const currentQuantity = itemInCart ? parseInt(itemInCart.quantity) : 0;

	            if (currentQuantity + addingQuantity > maxQuantity) {
	                alert(`Non puoi aggiungere ${addingQuantity} unità. Hai già ${currentQuantity} nel carrello e la disponibilità massima è ${maxQuantity}.`);
	                throw new Error("Quantità massima superata");
	            }

	            return fetch('AddToCartServlet', {
	                method: 'POST',
	                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
	                body: new URLSearchParams({
	                    productCode: productCode,
	                    quantity: addingQuantity
	                })
	            });
	        })
	        .then(response => {
	            if (!response.ok) {
	                return response.json().then(err => {
	                    alert(err.error || "Errore nell'aggiunta al carrello");
	                    throw new Error(err.error || "Errore nel server");
	                });
	            }
	            return response.json();
	        })
	        .then(carrello => {
	            aggiornaSidebar(carrello);
	        })
	        .catch(err => {
	            console.error(err);
	            // Se vuoi, qui puoi fare altre azioni di fallback
	        });
	}


  function chiudiSidebar() {
      document.getElementById('sidebar-carrello').style.display = 'none';
  }
  function apriSidebarCarrello() {
	  document.getElementById('sidebar-carrello').style.display = 'block';
      fetch('GetCartServlet')
          .then(res => {
              if (!res.ok) throw new Error("Errore nel recupero del carrello");
              return res.json();
          })
          .then(carrello => {
              aggiornaSidebar(carrello);
          })
          .catch(err => {
              console.error("Errore nel caricamento del carrello:", err);
              alert("Errore durante il caricamento del carrello.");
          });
  }

  function modificaQuantitàCarrello(productCode, quantity) {
	    quantity = parseInt(quantity);
	    if (isNaN(quantity) || quantity < 1) {
	        alert("La quantità deve essere almeno 1.");
	        apriSidebarCarrello();
	        return;
	    }
	    // Non posso controllare la quantità massima qui, perché non ho accesso alla disponibilità,
	    // ma dato che l'input ha max, il controllo più importante è già fatto.
	    
	    fetch('update-cart', {
	        method: 'POST',
	        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
	        body: new URLSearchParams({
	            ['quantities[' + productCode + ']']: quantity
	        })
	    })
	    .then(res => {
	        if (!res.ok) throw new Error("Errore nell'aggiornamento quantità");
	        return res.json ? res.json() : apriSidebarCarrello();
	    })
	    .then(() => apriSidebarCarrello())
	    .catch(err => {
	        console.error(err);
	        alert("Errore durante l'aggiornamento della quantità");
	    });
	}


  function rimuoviDalCarrello(productCode) {
      fetch('remove-from-cart', {
          method: 'POST',
          headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
          body: 'productCode=' + encodeURIComponent(productCode)
      })
      .then(res => {
          if (!res.ok) throw new Error("Errore nella rimozione dal carrello");
          return res.json ? res.json() : apriSidebarCarrello();
      })
      .then(() => apriSidebarCarrello())
      .catch(err => {
          console.error(err);
          alert("Errore durante la rimozione dal carrello");
      });
  }

  function svuotaCarrello() {
      fetch('clear-cart', {
          method: 'POST'
      })
      .then(res => {
          if (!res.ok) throw new Error("Errore nello svuotare il carrello");
          return res.json ? res.json() : apriSidebarCarrello();
      })
      .then(() => aggiornaSidebar([]))
      .catch(err => {
          console.error(err);
          alert("Errore nello svuotare il carrello");
      });
  }
</script>
</body>
</html>
