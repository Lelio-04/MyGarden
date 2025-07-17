let cart = [];
let isMerging = false;


const ADD_TO_CART_SERVLET_URL = '/MyGardenProject/AddToCartServlet';
const REMOVE_FROM_CART_SERVLET_URL = '/MyGardenProject/remove-from-cart';
const UPDATE_CART_QUANTITY_SERVLET_URL = '/MyGardenProject/update-cart-quantity';
const GET_CART_SERVLET_URL = '/MyGardenProject/GetCartServlet';

const isUserLoggedIn = () => isLoggedIn === true || isLoggedIn === 'true';

function mapServerCartToClientCart(serverCartArray) {
    return serverCartArray.map(item => ({
        id: item.productCode,
        name: item.product.name,
        price: item.product.price,
        image: item.product.image,
        quantity: item.quantity,
        maxQty: item.product.quantity
    }));
}
async function loadUserCartWithMergeCheck() {
    const cartMerged = localStorage.getItem('cartMerged');
    if (cartMerged !== 'true') {
        await mergeGuestCartWithUserCart(); // Merge if needed
    }
    await fetchCartFromServer(); // Always fetch the latest cart from the server
    updateCartDisplay(); // Update cart display
}
function openCart() {
    const sidebar = document.getElementById("cartSidebar");
    if (sidebar.classList.contains("open")) return;

    sidebar.classList.add("open");

    if (isUserLoggedIn()) {
        fetchCartFromServer().then(updateCartDisplay);  // <-- solo fetch
    } else {
        loadGuestCart();
        updateCartDisplay();
    }
}
async function initUserSession() {
    try {
        // If the cart has already been merged, no need to merge again
        if (sessionStorage.getItem('cartMerged') === 'true') {
            console.log("⛔ Merge già eseguito questa sessione.");
            return;
        }

        // Merge guest cart with the user cart if not already done
        await mergeGuestCartWithUserCart();

        // Fetch updated cart from the server after the merge
        await fetchCartFromServer();

        // Update cart display
        updateCartDisplay();
    } catch (error) {
        console.error('❌ Errore durante l\'inizializzazione della sessione:', error);
    }
}


// Modifica la funzione deduplicateCart per tenere traccia dei duplicati e unire le quantità

// Funzione di deduplicazione del carrello (da implementare)
function deduplicateCart(cart) {
    const seen = new Set();
    return cart.filter(item => {
        if (!seen.has(item.id)) {
            seen.add(item.id);
            return true;
        }
        return false;
    });
}

function closeCart() {
    document.getElementById("cartSidebar").classList.remove("open");
}

async function fetchCartFromServer() {
    try {
        const response = await fetch(GET_CART_SERVLET_URL);
        if (!response.ok) throw new Error(`Errore HTTP: ${response.status}`);
        const serverCartRaw = await response.json();
        cart = mapServerCartToClientCart(serverCartRaw);
    } catch (error) {
        console.error('Errore recupero carrello:', error);
    }
}

async function postFormUrlEncoded(url, data) {
    const formBody = new URLSearchParams(data).toString();
    return fetch(url, {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: formBody
    });
}

// Funzione per mostrare il modale con il messaggio
function showModal(message) {
    const modal = document.getElementById('cart-modal');
    const modalMessage = document.getElementById('modal-message');
    const closeButton = document.getElementById('modal-close');

    modalMessage.textContent = message;  // Imposta il messaggio del modale
    modal.style.display = 'block';  // Mostra il modale

    // Aggiungi un listener per chiudere il modale
    closeButton.onclick = function() {
        modal.style.display = 'none';  // Nascondi il modale quando viene cliccato il bottone di chiusura
    }

    // Chiudi il modale quando clicchi fuori dal contenitore
    window.onclick = function(event) {
        if (event.target === modal) {
            modal.style.display = 'none';
        }
    }
}

async function addToCart(product) {
    if (!isUserLoggedIn()) {
        try {
            const response = await fetch(`/MyGardenProject/get-product-info?id=${product.id}`);
            if (!response.ok) throw new Error('Errore recupero disponibilità.');
            const data = await response.json();
            if (typeof data.maxQty !== 'number') {
                showModal('Errore nel caricamento delle informazioni prodotto.');
                return;
            }
            product.maxQty = data.maxQty;
        } catch (error) {
            console.error('Errore fetch maxQty per guest:', error);
            showModal('Errore durante il controllo disponibilità prodotto.');
            return;
        }
    }

    if (product.quantity > product.maxQty) {
        // Mostra il messaggio nel modale
        showModal(`La quantità richiesta supera la disponibilità per ${product.name} (${product.maxQty}). Manteniamo la quantità del carrello utente.`);
        return;
    }

    if (isUserLoggedIn()) {
        try {
            const response = await postFormUrlEncoded(ADD_TO_CART_SERVLET_URL, {
                productCode: product.id,
                quantity: product.quantity
            });

            const json = await response.json();

            if (!response.ok || json.status !== 'success') {
                showModal(`Errore: ${json.error || 'Impossibile aggiungere il prodotto.'}`);
                return;
            }

            // json.cart contiene l'array aggiornato degli elementi nel carrello
            cart = json.cart.map(item => ({
                id: item.productCode,
                quantity: item.quantity,
                name: item.product.name,
                price: item.product.price,
                image: item.product.image,
                maxQty: item.product.quantity
            }));

            updateCartDisplay();
            openCart();
        } catch (error) {
            console.error('Errore aggiunta prodotto:', error);
            showModal('Errore durante l\'aggiunta al carrello.');
        }
    } else {
        let item = cart.find(i => String(i.id) === String(product.id));
        if (item) {
            const totalQty = item.quantity + product.quantity;
            if (totalQty > product.maxQty) {
                // Mostra il messaggio nel modale
                showModal(`La somma delle quantità supera la disponibilità per ${product.name}. Manteniamo la quantità del carrello utente.`);
                item.quantity = product.maxQty; // Mantieni la quantità massima
            } else {
                item.quantity = totalQty;
            }
        } else {
            if (product.quantity > product.maxQty) {
                // Mostra il messaggio nel modale
                showModal(`Disponibilità limitata. Imposto quantità a ${product.maxQty}.`);
                product.quantity = product.maxQty;
            }
            cart.push({ ...product });
        }

        saveGuestCart();
        updateCartDisplay();
        openCart();
    }
}


async function removeFromCart(productCode) {
    if (isUserLoggedIn()) {
        try {
            const response = await fetch(REMOVE_FROM_CART_SERVLET_URL, {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: `productCode=${encodeURIComponent(productCode)}`
            });

            if (!response.ok) {
                const errorData = await response.json();
                throw new Error(errorData.message || 'Errore rimozione');
            }

            await fetchCartFromServer();
            updateCartDisplay();
            openCart();
        } catch (error) {
            console.error('Errore rimozione prodotto:', error);
            alert('Errore rimozione: ' + error.message);
        }
    } else {
        cart = cart.filter(item => item.id !== productCode);
        saveGuestCart();
        updateCartDisplay();
        openCart();
    }
}

async function updateQuantity(productId, change) {
    const item = cart.find(i => i.id == productId);
    if (!item) return;

    let newQty = item.quantity + change;
    if (newQty < 1) {
        await removeFromCart(productId);
        return;
    }

    if (newQty > item.maxQty) {
        alert(`Quantità massima per ${item.name}: ${item.maxQty}`);
        newQty = item.maxQty;
    }

    if (isUserLoggedIn()) {
        try {
            const response = await postFormUrlEncoded(UPDATE_CART_QUANTITY_SERVLET_URL, {
                productCode: productId,
                quantity: newQty
            });

            const json = await response.json();
            if (!response.ok || json.status !== 'success') {
                alert(`Errore: ${json.message || 'Impossibile aggiornare la quantità.'}`);
                return;
            }

            await fetchCartFromServer();
            updateCartDisplay();
        } catch (error) {
            console.error('Errore aggiornamento quantità:', error);
            alert('Errore aggiornamento quantità.');
        }
    } else {
        item.quantity = newQty;
        saveGuestCart();
        updateCartDisplay();
        openCart();
    }
}

function updateCartDisplay() {
    const container = document.getElementById("cart-items");
    const totalElement = document.getElementById("cart-total-price");
    container.innerHTML = '';
    let total = 0;

    if (cart.length === 0) {
        container.innerHTML = '<p class="empty-cart-message">Il carrello è vuoto.</p>';
        totalElement.textContent = '€0.00';
        return;
    }

    for (const item of cart) {
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
                <button onclick="updateQuantity('${item.id}', -1)">-</button>
                <span>${item.quantity}</span>
                <button onclick="updateQuantity('${item.id}', 1)">+</button>
                <button onclick="removeFromCart('${item.id}')">Rimuovi</button>
            </div>
        `;
        container.appendChild(div);
        total += parseFloat(item.price) * item.quantity;
    }

    totalElement.textContent = `€${total.toFixed(2)}`;
}

function saveGuestCart() {
    localStorage.setItem('guestCart', JSON.stringify(cart));
}

function loadGuestCart() {
    try {
        cart = JSON.parse(localStorage.getItem('guestCart')) || [];
    } catch (e) {
        console.error('Errore parsing guestCart:', e);
        cart = [];
    }
}

const LAST_MERGE_KEY = 'lastMergeTimestamp';
const MERGE_TIMEOUT = 50000; // 5 secondi
async function mergeGuestCartWithUserCart() {
    const lastMergeTime = localStorage.getItem(LAST_MERGE_KEY);
    const currentTime = new Date().getTime();

    console.log(`Tempo corrente: ${currentTime}, Ultimo merge: ${lastMergeTime}`);

    // Se lastMergeTime è null, imposta un valore iniziale
    if (!lastMergeTime) {
        console.log("🔄 Primo merge, timestamp non trovato.");
        localStorage.setItem(LAST_MERGE_KEY, currentTime.toString());
    }

    // Se il merge è stato effettuato recentemente, blocca l'esecuzione
    if (lastMergeTime && (currentTime - parseInt(lastMergeTime) < MERGE_TIMEOUT)) {
        const timeDiff = currentTime - parseInt(lastMergeTime);
        console.log(`⛔ Merge già eseguito troppo recentemente (${timeDiff} ms fa)`);
        return; // Esci dalla funzione se il tempo di merge è troppo breve
    }

    try {
        const guestCartStr = localStorage.getItem('guestCart');
        console.log('Carrello guest:', guestCartStr);
        if (!guestCartStr) {
            console.log("⛔ Nessun carrello guest trovato.");
            return; // Nessun carrello guest trovato, esci
        }

        const parsedGuestCart = JSON.parse(guestCartStr);
        console.log('Carrello guest parsato:', parsedGuestCart);

        // Verifica che il carrello utente (cart) esista
        if (!Array.isArray(cart)) {
            console.log("🔄 Inizializzando un carrello vuoto.");
            cart = []; // Inizializza cart se non esiste
        }

        // Unisci il carrello guest con il carrello utente
        const mergedCart = [...cart];

        for (const guestItem of parsedGuestCart) {
            const existingItem = mergedCart.find(item => item.id === guestItem.id);

            if (existingItem) {
                const newQuantity = existingItem.quantity + guestItem.quantity;

                // Verifica se la quantità supera quella massima disponibile per il prodotto
                if (newQuantity > guestItem.maxQty) {
                    showModal(`⚠️ La quantità richiesta per ${guestItem.name} supera quella disponibile nel database! Aggiornamento alla quantità del carrello utente loggato`);
                    existingItem.quantity = guestItem.maxQty; // Imposta la quantità massima disponibile
                } else {
                    existingItem.quantity = newQuantity;
                }

            } else {
                mergedCart.push({ ...guestItem });
            }
        }

        // Deduplica il carrello
        cart = deduplicateCart(mergedCart);
        updateCartDisplay();

        const mergedCartJson = JSON.stringify(cart.map(item => ({
            productCode: item.id,
            quantity: item.quantity,
            product: {
                id: item.id,
                name: item.name,
                price: item.price,
                image: item.image,
                quantity: item.maxQty // Usa la quantità massima disponibile per il prodotto
            }
        })));

        const response = await fetch('/MyGardenProject/MergeCartServlet', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: mergedCartJson
        });

        const responseText = await response.text();
        console.log('Risposta dal server:', responseText);

        if (!response.ok) {
            console.error('❌ Errore durante il merge:', responseText);
            return;
        }

        console.log("✅ Merge completato con successo.");

        localStorage.removeItem('guestCart');
        sessionStorage.setItem('cartMerged', 'true');
        localStorage.setItem(LAST_MERGE_KEY, currentTime.toString());
    } catch (error) {
        console.error('❌ Errore durante il merge del carrello:', error);
    }
}


function logout() {
    // Rimuovi tutte le informazioni relative al carrello e alla sessione
    sessionStorage.removeItem('cartMerged');  // Rimuovi il flag del merge
    localStorage.removeItem('guestCart');
    localStorage.removeItem('lastMergeTimestamp'); // Resetta il tempo di merge
	localStorage.removeItem('MERGE_TIMEOUT');
    window.location.href = '/MyGardenProject/Logout';
}

async function initUserSession() {
    try {
        // Verifica se il merge è già stato eseguito
        if (sessionStorage.getItem('cartMerged') === 'true') {
            console.log("⛔ Merge già eseguito questa sessione.");
            return; // Non fare nulla se il merge è già stato eseguito
        }

        // Esegui il merge una sola volta
        await mergeGuestCartWithUserCart();

        // Aggiorna il carrello dal server
        await fetchCartFromServer();

        // Aggiorna l'interfaccia utente
        updateCartDisplay();
    } catch (error) {
        console.error('❌ Errore durante l\'inizializzazione della sessione:', error);
    }
}



document.addEventListener('DOMContentLoaded', async () => {
    if (isUserLoggedIn()) {
        await initUserSession(); // Initialize the user session and merge if necessary
    } else {
        // If guest, load guest cart and update the display
        loadGuestCart();
        updateCartDisplay();
    }

    // Handle adding products to cart
    document.querySelectorAll('.add-to-cart-btn').forEach(button => {
        button.addEventListener('click', async () => {
            if (button.disabled) return;
            button.disabled = true;

            const id = String(button.getAttribute('data-product-id'));
            const name = button.getAttribute('data-product-name');
            const price = parseFloat(button.getAttribute('data-product-price')) || 0;
            const image = button.getAttribute('data-product-image');
            const maxQty = parseInt(button.getAttribute('data-product-maxQty')) || 99;
            const qtyInput = document.getElementById(`qty-${id}`);
            const quantity = parseInt(qtyInput?.value) || 1;

            await addToCart({ id, name, price, image, quantity, maxQty });

            button.disabled = false;
        });
    });

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

    // Deduplicate and update the cart display after page load
    cart = deduplicateCart(cart);
    updateCartDisplay();
});
