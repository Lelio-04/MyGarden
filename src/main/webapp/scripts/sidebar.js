
let cart = [];

const ADD_TO_CART_SERVLET_URL = '/MyGardenProject/AddToCartServlet';
const REMOVE_FROM_CART_SERVLET_URL = '/MyGardenProject/remove-from-cart';
const UPDATE_CART_QUANTITY_SERVLET_URL = '/MyGardenProject/update-cart-quantity';
const GET_CART_SERVLET_URL = '/MyGardenProject/GetCartServlet';

const isUserLoggedIn = () => isLoggedIn === true || isLoggedIn === 'true';

function mapServerCartToClientCart(serverCartArray) {
    return serverCartArray.map(item => ({
        id: item.id,
        name: item.name,
        price: item.price,
        image: item.image,
        quantity: item.quantity,
        maxQty: item.maxQty
    }));
}


function openCart() {
    const sidebar = document.getElementById("cartSidebar");
    if (sidebar.classList.contains("open")) return;

    sidebar.classList.add("open");

    // Carica sempre il carrello dal server, anche se non sei loggato
    fetchCartFromServer(updateCartDisplay);
}



function closeCart() {
    document.getElementById("cartSidebar").classList.remove("open");
}

function loadGuestCart() {
    const stored = sessionStorage.getItem("guestCart");
    cart = stored ? JSON.parse(stored) : [];
}

function saveGuestCart() {
    sessionStorage.setItem("guestCart", JSON.stringify(cart));
}

function fetchCartFromServer(callback) {
    const xhr = new XMLHttpRequest();
    xhr.open("GET", GET_CART_SERVLET_URL, true);
    xhr.onreadystatechange = function () {
        if (xhr.readyState === 4 && xhr.status === 200) {
            try {
                const raw = JSON.parse(xhr.responseText);
                cart = mapServerCartToClientCart(raw);
                callback && callback();
            } catch (err) {
                console.error("Errore parsing JSON cart:", err);
            }
        }
    };
    xhr.send();
}

function updateCartDisplay() {
    const container = document.getElementById("cart-items");
    const totalPriceEl = document.getElementById("cart-total-price");

    container.innerHTML = "";

    if (!cart.length) {
        container.innerHTML = `<p class="empty-cart-message">Il carrello è vuoto.</p>`;
        totalPriceEl.textContent = "€0.00";
        return;
    }

    let total = 0;

	cart.forEach(item => {
	    const div = document.createElement('div');
	    div.className = 'cart-item';
	    div.innerHTML = `
	        <div class="cart-item-image">
	            <img src="${item.image}" alt="${item.name}">
	        </div>
	        <div class="cart-item-info">
	            <h4>${item.name}</h4>
	            <p>Prezzo: €${parseFloat(item.price).toFixed(2)}</p>
	        </div>
	        <div class="cart-item-actions">
	            <button class="decrease-btn">-</button>
	            <span>${item.quantity}</span>
	            <button class="increase-btn">+</button>
	            <button class="remove-btn">Rimuovi</button>
	        </div>
	    `;
	    container.appendChild(div);

	    div.querySelector('.decrease-btn').addEventListener('click', () => updateQty(item.id, -1));
	    div.querySelector('.increase-btn').addEventListener('click', () => updateQty(item.id, 1));
	    div.querySelector('.remove-btn').addEventListener('click', () => removeItem(item.id));

	    total += parseFloat(item.price) * item.quantity;
	});


    totalPriceEl.textContent = "€" + total.toFixed(2);
}

function updateQty(productId, delta) {
    const index = cart.findIndex(item => item.id === productId);
    if (index === -1) return;

    const item = cart[index];
    const newQty = item.quantity + delta;

    if (newQty <= 0) {
        cart.splice(index, 1);
    } else if (newQty > item.maxQty) {
        // mostra errore e blocca l'aumento
        showError(`Disponibili solo ${item.maxQty} pezzi per "${item.name}".`);
        return;
    } else {
        item.quantity = newQty;
        clearError();
    }

    syncCart(updateCartDisplay);
}


function removeItem(productId) {
    const index = cart.findIndex(i => i.id === productId);
    if (index !== -1) {
        cart.splice(index, 1);  // rimuovi elemento
        syncCart(() => {
            updateCartDisplay();
            openCart();
        });
    }
}


function addToCart(productId, name, price, image, quantity = 1, maxQty = 99, callback) {
    productId = parseInt(productId, 10);
    const existing = cart.find(item => item.id === productId);

    // Usa il maxQty già presente in carrello se c'è, altrimenti quello passato
    const effectiveMaxQty = existing ? existing.maxQty : maxQty;

    const currentQty = existing ? existing.quantity : 0;
    const totalQty = currentQty + quantity;

    if (totalQty > effectiveMaxQty) {
        showError(`Disponibili solo ${effectiveMaxQty} pezzi per "${name}".`);
        return;
    }

    clearError();

    if (existing) {
        existing.quantity = totalQty;
    } else {
        cart.push({ id: productId, name, price, image, quantity, maxQty: effectiveMaxQty });
    }

    syncCart(() => {
        updateCartDisplay();
        if (callback) callback();
    });
}


function syncCart(callback) {
    // Sempre invia il carrello al server, anche se guest
	if (!isUserLoggedIn()) {
	    saveGuestCart(); // <--- salva localmente anche prima della sync
	}
    const xhr = new XMLHttpRequest();
    xhr.open("POST", "/MyGardenProject/update-cart", true);
    xhr.setRequestHeader("Content-Type", "application/json");

    xhr.onreadystatechange = function () {
        if (xhr.readyState === 4) {
            if (xhr.status === 200) {
				fetchCartFromServer(() => {
				        callback && callback();
				    });
            } else {
                console.error("Errore sincronizzazione carrello:", xhr.responseText);
                // In caso di errore, fallback locale
                if (!isUserLoggedIn()) {
                    saveGuestCart();
                    callback && callback();
                }
            }
        }
    };

    // Manda il carrello in formato {cart: [{productCode, quantity}, ...]}
    const payload = JSON.stringify({ cart: cart.map(item => ({ productCode: item.id, quantity: item.quantity })) });
    xhr.send(payload);
}

function logout() {
	sessionStorage.removeItem("guestCart");
    window.location.href = '/MyGardenProject/Logout';
}

document.addEventListener('DOMContentLoaded', () => {
    if (isUserLoggedIn()) {
        fetchCartFromServer(updateCartDisplay);
    } else {
        loadGuestCart();
        updateCartDisplay();
    }

    const prodottiDiv = document.getElementById('prodotti');
    if (prodottiDiv) {
        prodottiDiv.addEventListener('click', event => {
            if (event.target && event.target.matches('.add-to-cart-btn')) {
                const button = event.target;
                if (button.disabled) return;
                button.disabled = true;

                const id = parseInt(button.getAttribute('data-product-id'), 10);
                const name = button.getAttribute('data-product-name');
                const price = parseFloat(button.getAttribute('data-product-price')) || 0;
                const image = button.getAttribute('data-product-image');
                let maxQty = parseInt(button.getAttribute('data-product-maxQty'), 10) || 99;

                const existingItem = cart.find(item => item.id === id);
                if (existingItem) {
                    maxQty = existingItem.maxQty;
                }

                const qtyInput = document.getElementById(`qty-${id}`);
                let quantity = parseInt(qtyInput?.value, 10) || 1;

                if (quantity < 1) quantity = 1;
                if (quantity > maxQty) quantity = maxQty;

                const currentQty = existingItem ? existingItem.quantity : 0;

                if (currentQty + quantity > maxQty) {
                    showError(`Disponibili solo ${maxQty} pezzi (hai già ${currentQty})`);
                    button.disabled = false;
                    openCart();
                    return;
                } else {
                    clearError();
                }

                addToCart(id, name, price, image, quantity, maxQty, () => {
                    openCart();
                    button.disabled = false;
                });
            }
        });
    }

    const cartBtn = document.getElementById('cart-button');
    cartBtn?.addEventListener('click', openCart);

    document.querySelectorAll('.checkout-btn').forEach(btn => {
        btn.addEventListener('click', e => {
            e.preventDefault();
            const checkoutUrl = '/MyGardenProject/checkout-page';
            window.location.href = isUserLoggedIn()
                ? checkoutUrl
                : `/MyGardenProject/Login?next=${encodeURIComponent(checkoutUrl)}`;
        });
    });

    // Rende visibile il carrello all'apertura della pagina (se ci sono articoli)
    updateCartDisplay();
});

function showError(message) {
    const errorDiv = document.getElementById('cart-error-message');
    if (errorDiv) {
        errorDiv.textContent = message;
        errorDiv.style.display = 'block';
    }
}

function clearError() {
    const errorDiv = document.getElementById('cart-error-message');
    if (errorDiv) {
        errorDiv.textContent = '';
        errorDiv.style.display = 'none';
    }
}

// Funzione per caricare le categorie con XMLHttpRequest
function caricaCategorie() {
    const categoriaSelect = document.getElementById('categoria');
    if (!categoriaSelect) return;

    const xhr = new XMLHttpRequest();
    xhr.open('GET', '/MyGardenProject/getCategories', true);
    xhr.responseType = 'json';

    xhr.onload = function() {
        if (xhr.status >= 200 && xhr.status < 300) {
            const categorie = xhr.response;
            categoriaSelect.innerHTML = '';
            categorie.forEach(categoria => {
                const option = document.createElement('option');
                option.value = categoria.id;
                option.textContent = categoria.name;
                categoriaSelect.appendChild(option);
            });
        } else {
            console.error('Errore durante il caricamento delle categorie:', xhr.statusText);
        }
    };

    xhr.onerror = function() {
        console.error('Errore di rete durante il caricamento delle categorie.');
    };

    xhr.send();
}

// Funzione per gestire la ricerca dei prodotti con XMLHttpRequest
function ricercaProdotti(event) {
    event.preventDefault();

    const q = document.getElementById('q').value;
    const categoria = document.getElementById('categoria').value;

    const divProdotti = document.getElementById('prodotti');
    const catalogGrid = divProdotti.querySelector('.catalog-grid');

    divProdotti.classList.add('loading');
    catalogGrid.innerHTML = '';

    const xhr = new XMLHttpRequest();
    xhr.open('GET', `/MyGardenProject/CercaProdottiServlet?q=${encodeURIComponent(q)}&categoria=${encodeURIComponent(categoria)}`, true);
    xhr.responseType = 'json';

    xhr.onload = function() {
        divProdotti.classList.remove('loading');
        if (xhr.status >= 200 && xhr.status < 300) {
            const prodotti = xhr.response;

            if (!prodotti || prodotti.length === 0) {
                catalogGrid.innerHTML = "<p>Nessun prodotto trovato.</p>";
                return;
            }

            prodotti.forEach(prodotto => {
                const div = document.createElement('div');
                div.classList.add('product-card');

                div.innerHTML = `
                    <a href="DettaglioProdottoServlet?code=${prodotto.code}">
                        <div class="product-image-wrapper">
                            <img src="${prodotto.image}" alt="${prodotto.name}">
                        </div>
                    </a>
                    <div class="product-content">
                        <h3>${prodotto.name}</h3>
                        <p class="price">€ ${parseFloat(prodotto.price).toFixed(2)}</p>
                        ${prodotto.quantity > 0 ? `
                            <div class="quantity-row">
                                <span class="available">Disponibilità: ${prodotto.quantity}</span>
                                <input type="number" id="qty-${prodotto.code}" value="1" min="1" max="${prodotto.quantity}" required>
                            </div>
                            <button class="add-to-cart-btn"
                                data-product-id="${prodotto.code}"
                                data-product-name="${prodotto.name}"
                                data-product-price="${parseFloat(prodotto.price).toFixed(2)}"
                                data-product-image="${prodotto.image}"
                                data-product-maxQty="${prodotto.quantity}">
                                Aggiungi al Carrello
                            </button>
                        ` : `<div class="not-available">Non disponibile</div>`}
                    </div>
                `;
                catalogGrid.appendChild(div);
            });
        } else {
            console.error('Errore durante il caricamento dei prodotti:', xhr.statusText);
        }
    };

    xhr.onerror = function() {
        divProdotti.classList.remove('loading');
        console.error('Errore di rete durante il caricamento dei prodotti.');
    };

    xhr.send();
}

// Evento DOMContentLoaded aggiornato con caricaCategorie e ricercaProdotti
document.addEventListener('DOMContentLoaded',() => {
    if (isUserLoggedIn()) {
        fetchCartFromServer(updateCartDisplay);
    } else {
        loadGuestCart();
        updateCartDisplay();
    }

    caricaCategorie();

    const searchForm = document.getElementById('searchForm');
    if (searchForm) {
        searchForm.addEventListener('submit', ricercaProdotti);
    }

    const prodottiDiv = document.getElementById('prodotti');
    if (prodottiDiv) {
        prodottiDiv.addEventListener('click',(event) => {
            if (event.target && event.target.matches('.add-to-cart-btn')) {
                const button = event.target;
                if (button.disabled) return;

                button.disabled = true;

                const id = button.getAttribute('data-product-id');
                const name = button.getAttribute('data-product-name');
                const price = parseFloat(button.getAttribute('data-product-price')) || 0;
                const image = button.getAttribute('data-product-image');
                let maxQty = parseInt(button.getAttribute('data-product-maxQty')) || 99;

                const existingItem = cart.find(item => item.id == id);
                if (existingItem) maxQty = existingItem.maxQty;

                const qtyInput = document.getElementById(`qty-${id}`);
                let quantity = parseInt(qtyInput?.value) || 1;

                if (quantity < 1) quantity = 1;
                if (quantity > maxQty) quantity = maxQty;

                const currentQty = existingItem ? existingItem.quantity : 0;
                if (currentQty + quantity > maxQty) {
                    showError(`Disponibili solo ${maxQty} pezzi (hai già ${currentQty})`);
                    button.disabled = false;
                    openCart();
                    return;
                } else {
                    clearError();
                }

                addToCart(id, name, price, image, quantity, maxQty, () => {
                    openCart();
                    button.disabled = false;
                });
            }
        });
    }
});

