<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, it.unisa.cart.*, it.unisa.db.*" %>
<%
    String username = (String) session.getAttribute("username");
    Boolean isAdmin = (Boolean) session.getAttribute("isAdmin");
%>


<!DOCTYPE html>
<html lang="it">
<head>
    <meta charset="UTF-8">
    <title>Carrello</title>
    <link rel="stylesheet" href="styles/styleBase.css">
    <link rel="stylesheet" href="styles/styleCarrello.css">
</head>
<body>
<header>
    <div class="header-top">
        <img src="images/logo.png" alt="MyGarden Logo" class="logo">
        <span class="site-title"><span class="yellow">My</span><span class="green">Garden</span></span>
        <div class="header-icons">
            
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

<main>
    <div id="cart-container">
        <p id="loading-msg">Caricamento carrello...</p>
        <!-- Qui verrà caricata dinamicamente la tabella carrello -->
    </div>
    <div id="cart-actions" style="display:none;">
        <p id="total-price"></p>
        <% if (username != null) { %>
            <button id="checkoutBtn">Effettua Ordine</button>
        <% } else { %>
            <p>Per effettuare l'ordine devi <a href="login.jsp">accedere</a>.</p>
        <% } %>
        <button id="clearCartBtn">Svuota Carrello</button>
    </div>
</main>


<footer>
    <p>&copy; 2025 MyGarden - Tutti i diritti riservati.</p>
</footer>

<!-- Sidebar Carrello -->

<script>
function aggiornaCarrello(carrello) {
	  const container = document.getElementById('cart-container');
	  const actions = document.getElementById('cart-actions');
	  const totaleSpan = document.getElementById('total-price');

	  container.innerHTML = '';
	  totaleSpan.textContent = '';

	  if (!Array.isArray(carrello) || carrello.length === 0) {
	    container.innerHTML = '<p>Il carrello è vuoto.</p>';
	    actions.style.display = 'none';
	    return;
	  }

	  let totale = 0;

	  // Creo la tabella del carrello
	  const table = document.createElement('table');
	  table.style.width = '100%';
	  table.style.borderCollapse = 'collapse';

	  const thead = document.createElement('thead');
	  const headerRow = document.createElement('tr');

	  ['Immagine', 'Prodotto', 'Quantità', 'Prezzo', 'Totale', 'Azioni'].forEach(text => {
	    const th = document.createElement('th');
	    th.textContent = text;
	    th.style.borderBottom = '2px solid #ccc';
	    th.style.padding = '8px';
	    headerRow.appendChild(th);
	  });
	  thead.appendChild(headerRow);
	  table.appendChild(thead);

	  const tbody = document.createElement('tbody');

	  carrello.forEach(item => {
	    const prodotto = item.product || {};
	    const nome = prodotto.name || "Nome non disponibile";
	    const prezzo = typeof prodotto.price === 'number' ? prodotto.price : parseFloat(prodotto.price) || 0;
	    const quantità = typeof item.quantity === 'number' ? item.quantity : Number(item.quantity) || 0;
	    const codice = item.productCode || prodotto.code || '';
	    const imgUrl = prodotto.image || '';
	    const disponibile = prodotto.quantity || 0;

	    totale += prezzo * quantità;

	    const tr = document.createElement('tr');

	    // Immagine prodotto
	    const tdImg = document.createElement('td');
	    if (imgUrl) {
	      const img = document.createElement('img');
	      img.src = imgUrl;
	      img.alt = nome;
	      img.style.width = '80px';
	      img.style.height = 'auto';
	      img.style.borderRadius = '4px';
	      tdImg.appendChild(img);
	    } else {
	      tdImg.textContent = 'N/A';
	    }
	    tdImg.style.padding = '8px';
	    tr.appendChild(tdImg);

	    // Nome prodotto
	    const tdNome = document.createElement('td');
	    tdNome.textContent = nome;
	    tdNome.style.padding = '8px';
	    tr.appendChild(tdNome);

	    // Quantità (input per modificare)
	    // Quantità (input per modificare)
const tdQty = document.createElement('td');
const inputQty = document.createElement('input');
inputQty.type = 'number';
inputQty.min = 1;
inputQty.max = disponibile;  // <-- aggiunto max
inputQty.value = quantità;
inputQty.style.width = '60px';
inputQty.dataset.productCode = codice;
inputQty.dataset.available = disponibile;

// Blocchiamo l'input in real-time se supera la disponibilità
inputQty.oninput = () => {
  if (inputQty.value > disponibile) {
    alert(`La quantità massima disponibile per questo prodotto è ${disponibile}.`);
    inputQty.value = disponibile;
  } else if (inputQty.value < 1) {
    inputQty.value = 1;
  }
  modificaQuantitàCarrello(codice, inputQty.value);
};

// Per sicurezza mantieni anche onchange (puoi anche rimuoverlo se vuoi)
inputQty.onchange = () => {
  if (inputQty.value > disponibile) {
    alert(`La quantità massima disponibile per questo prodotto è ${disponibile}.`);
    inputQty.value = disponibile;
  } else if (inputQty.value < 1) {
    inputQty.value = 1;
  }
  modificaQuantitàCarrello(codice, inputQty.value);
};

tdQty.appendChild(inputQty);
tdQty.style.padding = '8px';
tr.appendChild(tdQty);

	    // Prezzo unitario
	    const tdPrezzo = document.createElement('td');
	    tdPrezzo.textContent = prezzo.toFixed(2) + ' €';
	    tdPrezzo.style.padding = '8px';
	    tr.appendChild(tdPrezzo);

	    // Totale per prodotto
	    const tdTotale = document.createElement('td');
	    tdTotale.textContent = (prezzo * quantità).toFixed(2) + ' €';
	    tdTotale.style.padding = '8px';
	    tr.appendChild(tdTotale);

	    // Pulsante rimuovi
	    const tdAzioni = document.createElement('td');
	    const btnRemove = document.createElement('button');
	    btnRemove.textContent = 'Rimuovi';
	    btnRemove.style.background = '#e53935';
	    btnRemove.style.color = 'white';
	    btnRemove.style.border = 'none';
	    btnRemove.style.padding = '5px 10px';
	    btnRemove.style.cursor = 'pointer';
	    btnRemove.style.borderRadius = '4px';
	    btnRemove.dataset.productCode = codice;
	    btnRemove.onclick = () => {
	      rimuoviDalCarrello(codice);
	    };
	    tdAzioni.appendChild(btnRemove);
	    tdAzioni.style.padding = '8px';
	    tr.appendChild(tdAzioni);

	    tbody.appendChild(tr);
	  });

	  table.appendChild(tbody);
	  container.appendChild(table);

	  totaleSpan.textContent = 'Totale carrello: ' + totale.toFixed(2) + ' €';
	  actions.style.display = 'block';

	  document.getElementById('clearCartBtn').onclick = () => {
	    svuotaCarrello();
	  };

	  const checkoutBtn = document.getElementById('checkoutBtn');
	  if (checkoutBtn) {
		  checkoutBtn.onclick = (e) => {
			  e.preventDefault(); // blocca sempre il comportamento di default

			  // Controlla se qualche prodotto supera la disponibilità
			  const superaDisponibilita = carrello.some(item => item.quantity > item.product.quantity);

			  if (superaDisponibilita) {
			    alert('La quantità richiesta supera la disponibilità di uno o più prodotti. Riduci le quantità per procedere.');
			    return; // blocca la navigazione al checkout
			  }

			  // Se tutto ok, procedi
			  window.location.href = 'checkout-page';
			};

	  }
	}

	function modificaQuantitàCarrello(productCode, quantity) {
	  quantity = parseInt(quantity);
	  if (isNaN(quantity) || quantity < 1) {
	    alert("La quantità deve essere almeno 1.");
	    return;
	  }

	  fetch('update-cart', {
	    method: 'POST',
	    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
	    body: new URLSearchParams({
	      ['quantities[' + productCode + ']']: quantity
	    })
	  })
	  .then(res => {
	    if (!res.ok) throw new Error("Errore nell'aggiornamento quantità");
	    return res.json();
	  })
	  .then(response => {
	    if (response.success) {
	      return fetch('GetCartServlet')
	        .then(res => {
	          if (!res.ok) throw new Error('Errore nel recupero del carrello');
	          return res.json();
	        })
	        .then(carrello => {
	          const item = carrello.find(i => i.productCode == productCode);
	          if (item && quantity > item.product.quantity) {
	            alert(`La quantità richiesta (${quantity}) supera la disponibilità (${item.product.quantity}).`);
	            aggiornaCarrello(carrello);
	            return;
	          }
	          aggiornaCarrello(carrello);
	        });
	    } else {
	      throw new Error(response.error || "Errore generico");
	    }
	  })
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
	    if (!res.ok) throw new Error('Errore nella rimozione dal carrello');
	    return res.json();
	  })
	  .then(carrello => aggiornaCarrello(carrello))
	  .catch(err => {
	    console.error(err);
	    alert('Errore durante la rimozione dal carrello');
	  });
	}

	function svuotaCarrello() {
	  fetch('clear-cart', {
	    method: 'POST'
	  })
	  .then(res => {
	    if (!res.ok) throw new Error('Errore nello svuotare il carrello');
	    return res.json();
	  })
	  .then(() => aggiornaCarrello([]))
	  .catch(err => {
	    console.error(err);
	    alert('Errore nello svuotare il carrello');
	  });
	}

	function caricaCarrello() {
	  const loadingMsg = document.getElementById('loading-msg');
	  loadingMsg.style.display = 'block';

	  fetch('GetCartServlet')
	    .then(res => {
	      if (!res.ok) throw new Error('Errore nel recupero del carrello');
	      return res.json();
	    })
	    .then(carrello => aggiornaCarrello(carrello))
	    .catch(err => {
	      console.error(err);
	      const container = document.getElementById('cart-container');
	      container.innerHTML = '<p>Errore nel caricamento del carrello.</p>';
	      document.getElementById('cart-actions').style.display = 'none';
	    })
	    .finally(() => {
	      loadingMsg.style.display = 'none';
	    });
	}

	window.onload = caricaCarrello;


</script>

</body>
</html>
