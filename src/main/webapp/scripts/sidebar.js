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
        if (sessionStorage.getItem('cartMerged') === 'true') {
            console.log("⛔ Merge già eseguito questa sessione.");
            return;
        }
        await mergeGuestCartWithUserCart();
        await fetchCartFromServer();
        updateCartDisplay();
    } catch (error) {
        console.error('❌ Errore durante l\'inizializzazione della sessione:', error);
    }
}

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

function showModal(message) {
    const modal = document.getElementById('cart-modal');
    const modalMessage = document.getElementById('modal-message');
    const closeButton = document.getElementById('modal-close');

    modalMessage.textContent = message;  
    modal.style.display = 'block'; 

    closeButton.onclick = function() {
        modal.style.display = 'none';  
    }

    window.onclick = function(event) {
        if (event.target === modal) {
            modal.style.display = 'none';
        }
    }
}


let isRequestInProgress = false;  // Aggiungi questo flag per gestire le richieste multiple


// Funzione per prevenire invii multipli di richieste AJAX
function blockRequest() {
    if (isRequestInProgress) {
        console.log("⛔ Una richiesta è già in corso, blocco il nuovo invio.");
        return true; // Blocca la nuova richiesta
    }
    isRequestInProgress = true;  // Imposta il flag che la richiesta è in corso
    return false; // La richiesta può essere inviata
}

function unblockRequest() {
    isRequestInProgress = false;  // Sblocca il flag dopo che la richiesta è stata completata
}

async function addToCart(product) {
    if (blockRequest()) return;  // Blocca la richiesta se è già in corso

    if (!isUserLoggedIn() && product.id != "undefined") {
        try {
            const response = await fetch(`/MyGardenProject/get-product-info?id=${product.id}`);
            if (!response.ok) throw new Error('Errore recupero disponibilità.');

            const data = await response.json();

            if (typeof data.maxQty !== 'number') {
                showModal('Errore nel caricamento delle informazioni prodotto.');
                unblockRequest();  // Sblocca la richiesta
                return;
            }

            product.maxQty = data.maxQty;
        } catch (error) {
            console.error('Errore fetch maxQty per guest:', error);
            showModal('Errore durante il controllo disponibilità prodotto.');
            unblockRequest();  // Sblocca la richiesta
            return;
        }
    }

    if (product.quantity > product.maxQty) {
        showModal(`La quantità richiesta supera la disponibilità per ${product.name} (${product.maxQty}).`);
        unblockRequest();  // Sblocca la richiesta
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
                unblockRequest();  // Sblocca la richiesta
                return;
            }

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
        } finally {
            unblockRequest();  // Sblocca la richiesta una volta completata
        }
    } else {
        let item = cart.find(i => String(i.id) === String(product.id));

        if (item) {
            const totalQty = item.quantity + product.quantity;
            if (totalQty > product.maxQty) {
                showModal(`La somma delle quantità supera la disponibilità per ${product.name}.`);
                item.quantity = product.maxQty;
            } else {
                item.quantity = totalQty;
            }
        } else {
            if (product.quantity > product.maxQty) {
                showModal(`Disponibilità limitata. Imposto quantità a ${product.maxQty}.`);
                product.quantity = product.maxQty;
            }
            cart.push({ ...product });
        }

        saveGuestCart();
        updateCartDisplay();
        openCart();
        unblockRequest();  // Sblocca la richiesta
    }
}

async function removeFromCart(productCode) {
    if (blockRequest()) return;  // Blocca la richiesta se è già in corso

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
        } finally {
            unblockRequest();  // Sblocca la richiesta una volta completata
        }
    } else {
        cart = cart.filter(item => item.id !== productCode);
        saveGuestCart();
        updateCartDisplay();
        openCart();
        unblockRequest();  // Sblocca la richiesta
    }
}

async function updateQuantity(productId, change) {
    if (blockRequest()) return;  // Blocca la richiesta se è già in corso

    const item = cart.find(i => i.id == productId);
    if (!item) {
        unblockRequest();  // Sblocca la richiesta se non ci sono problemi
        return;
    }

    let newQty = item.quantity + change;
    if (newQty < 1) {
        await removeFromCart(productId);
        unblockRequest();  // Sblocca la richiesta
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
                unblockRequest();  // Sblocca la richiesta
                return;
            }

            await fetchCartFromServer();
            updateCartDisplay();
        } catch (error) {
            console.error('Errore aggiornamento quantità:', error);
            alert('Errore aggiornamento quantità.');
        } finally {
            unblockRequest();  // Sblocca la richiesta una volta completata
        }
    } else {
        item.quantity = newQty;
        saveGuestCart();
        updateCartDisplay();
        openCart();
        unblockRequest();  // Sblocca la richiesta
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
                <button onclick="updateQuantity('${item.id}', -1)">-</button>
                <span>${item.quantity}</span>
                <button onclick="updateQuantity('${item.id}', 1)">+</button>
                <button onclick="removeFromCart('${item.id}')">Rimuovi</button>
            </div>
        `;
        container.appendChild(div);
        total += parseFloat(item.price) * item.quantity;
    });

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

const MERGE_TIMEOUT = 50000;
const LAST_MERGE_KEY = 'lastMergeTimestamp';

async function mergeGuestCartWithUserCart() {
    const lastMergeTime = localStorage.getItem(LAST_MERGE_KEY);
    const currentTime = new Date().getTime();

    if (lastMergeTime && (currentTime - parseInt(lastMergeTime) < MERGE_TIMEOUT)) {
        const timeDiff = currentTime - parseInt(lastMergeTime);
        console.log(`⛔ Merge troppo recente (${timeDiff} ms fa)`);
        return;
    }

    try {
        const guestCartStr = localStorage.getItem('guestCart');
        if (!guestCartStr) {
            console.log("⛔ Nessun carrello guest trovato.");
            return;
        }

        const parsedGuestCart = JSON.parse(guestCartStr);
        console.log('Carrello guest:', parsedGuestCart);

        const userCart = await fetchUserCartFromServer();
        console.log('Carrello utente prima del merge:', userCart);

        const mergedCart = mergeCarts(parsedGuestCart, userCart);
        console.log('Carrello unito:', mergedCart);  // Log dei carrelli uniti prima dell'aggiornamento

        // Log della cartella finale prima dell'update
        console.log('Carrello unito da inviare al server:', mergedCart);

        const updateResponse = await updateUserCart(mergedCart,true);

        console.log('Risposta aggiornamento carrello utente:', updateResponse);

        if (!updateResponse.success) {
            //console.error('❌ Errore durante l\'aggiornamento del carrello utente');
            return;
        }

        sessionStorage.setItem('cartMerged', 'true');
        localStorage.setItem(LAST_MERGE_KEY, currentTime.toString());
        localStorage.removeItem('guestCart');

        console.log("✅ Carrelli uniti e aggiornati con successo.");
        cart = mergedCart;
        updateCartDisplay();

        // Log the final cart after merge and update
        console.log('Carrello dell\'utente aggiornato con successo:', mergedCart);

    } catch (error) {
        console.error('❌ Errore durante la fusione dei carrelli:', error);
    }
}


async function fetchUserCartFromServer() {
    try {
        const response = await fetch('/MyGardenProject/GetCartServlet');
        if (!response.ok) throw new Error(`Errore HTTP: ${response.status}`);
        return await response.json();
    } catch (error) {
        console.error('Errore recupero carrello utente:', error);
        return [];
    }
}

function mergeCarts(guestCart, userCart) {
    // Unificare la struttura dei carrelli (normalizzare i dati)
    const normalizedGuestCart = guestCart.map(item => ({
        id: String(item.id),  // Assicurati che l'ID sia una stringa
        name: item.name,
        price: item.price,
        image: item.image,
        maxQty: item.maxQty,
        quantity: item.quantity
    }));

    const normalizedUserCart = userCart.map(item => ({
        id: String(item.productCode),  // Assicurati che l'ID sia una stringa
        name: item.product.name,
        price: item.product.price,
        image: item.product.image,
        maxQty: item.product.quantity, // Aggiungere maxQty se non esiste
        quantity: item.quantity
    }));

    // Inizializzare il carrello finale con i prodotti dell'utente
    const mergedCart = [...normalizedUserCart];

    // Unire i prodotti del carrello guest
    normalizedGuestCart.forEach(guestItem => {
        const existingItem = mergedCart.find(item => item.id === guestItem.id);

        if (existingItem) {
            // Se il prodotto esiste già, somma le quantità, ma non superare la maxQty
            const newQuantity = existingItem.quantity + guestItem.quantity;
            existingItem.quantity = Math.min(newQuantity, existingItem.maxQty);  // Limita la quantità alla maxQty
        } else {
            // Se il prodotto non esiste, aggiungilo al carrello unito
            mergedCart.push({ ...guestItem });
        }
    });

    // Eliminare i duplicati nel carrello unito (se la quantità è maggiore della maxQty, bisogna correggerla)
    const uniqueCart = [];
    mergedCart.forEach(item => {
        const existingItem = uniqueCart.find(cartItem => cartItem.id === item.id);
        if (!existingItem) {
            uniqueCart.push(item);
        } else {
            existingItem.quantity = Math.min(existingItem.quantity + item.quantity, item.maxQty);
        }
    });

    // Log dei prodotti uniti
    uniqueCart.forEach(item => {
        console.log(`Prodotto unito: ${item.name} | Quantità: ${item.quantity} | Prezzo: ${item.price}`);
    });

    return uniqueCart;
}

async function updateUserCart(cart, isMerged) {
    try {
        // Log per verificare il formato dei dati prima di inviarli
        console.log('Dati carrello da inviare:', cart);
		
        // Aggiungi il flag isMerged al carrello
        const requestData = {
            cart: cart,
            isMerged: isMerged // Aggiungi il campo isMerged per identificare il tipo di carrello
        };

        // Inviare la richiesta al server
        const response = await fetch('/MyGardenProject/update-cart', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(requestData)  // Invia direttamente il carrello con il flag
        });

        // Verifica che la risposta sia andata a buon fine (status HTTP 200-299)
        if (!response.ok) {
            throw new Error(`Errore HTTP: ${response.status} ${response.statusText}`);
        }

        // Gestire la risposta JSON
        const responseData = await response.json();

        // Log della risposta ricevuta
        console.log('Risposta dal server:', responseData);

        if (responseData.success) {
            console.log('Carrello aggiornato con successo!');
        } else {
            //console.error('Errore durante l\'aggiornamento del carrello:', responseData.error);
        }

        return responseData;  // Restituisce il risultato della risposta

    } catch (error) {
        // Gestione dell'errore con messaggio più dettagliato
        //console.error('Errore durante l\'aggiornamento del carrello dell\'utente:', error.message || error);
        return { success: false, error: error.message || 'Errore sconosciuto' };  // Restituisce un errore più dettagliato
    }
}


function logout() {
    sessionStorage.removeItem('cartMerged');
    localStorage.removeItem('guestCart');
    localStorage.removeItem('lastMergeTimestamp');
	localStorage.removeItem('MERGE_TIMEOUT');
    window.location.href = '/MyGardenProject/Logout';
}

document.addEventListener('DOMContentLoaded', async () => {
    if (isUserLoggedIn()) {
        await initUserSession();
    } else {
        loadGuestCart();
        updateCartDisplay();
    }

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

            // Add product to the cart (handling both guest and logged-in users)
            await addToCart({ id, name, price, image, quantity, maxQty });

            button.disabled = false;  // Re-enable the button after the operation
        });
    });

    // Handle opening the cart sidebar
    const cartBtn = document.getElementById('cart-button');
    cartBtn?.addEventListener('click', openCart);

    // Handle the checkout button click
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
// Funzione per caricare le categorie
document.addEventListener('DOMContentLoaded', async () => {
    if (isUserLoggedIn()) {
        await initUserSession();
    } else {
        loadGuestCart();
        updateCartDisplay();
    }

    // Aggiungi gli eventi di ricerca e di aggiunta al carrello
	const searchForm = document.getElementById('searchForm');
	    if (searchForm) {
	        searchForm.addEventListener('submit', ricercaProdotti);
	    }

	    // Verifica se l'elemento #prodotti esiste prima di aggiungere il listener per il carrello
	    const prodottiDiv = document.getElementById('prodotti');
	    if (prodottiDiv) {
	        prodottiDiv.addEventListener('click', async (event) => {
	            if (event.target && event.target.matches('.add-to-cart-btn')) {
	                const button = event.target;
	                if (button.disabled) return;  // Non fare nulla se il pulsante è disabilitato

	                button.disabled = true;  // Disabilita il pulsante per evitare doppie richieste

	                const id = String(button.getAttribute('data-product-id'));
	                const name = button.getAttribute('data-product-name');
	                const price = parseFloat(button.getAttribute('data-product-price')) || 0;
	                const image = button.getAttribute('data-product-image');
	                const maxQty = parseInt(button.getAttribute('data-product-maxQty')) || 99;
	                const qtyInput = document.getElementById(`qty-${id}`);
	                const quantity = parseInt(qtyInput?.value) || 1;

	                // Aggiungi il prodotto al carrello
	                await addToCart({ id, name, price, image, quantity, maxQty });

	                button.disabled = false;  // Rendi il pulsante abilitato dopo l'operazione
	            }
	        });
	    }
});
function caricaCategorie() {
    const categoriaSelect = document.getElementById('categoria');
    if (!categoriaSelect) {
        //console.error("Elemento #categoria non trovato!");
        return;  // Interrompe la funzione se l'elemento non esiste
    }

    fetch('/MyGardenProject/getCategories')
        .then(res => res.json())
        .then(categorie => {
            categoriaSelect.innerHTML = ''; // Pulisce le opzioni esistenti

            categorie.forEach(categoria => {
                const option = document.createElement('option');
                option.value = categoria.id; // Usa l'ID della categoria come valore
                option.textContent = categoria.name; // Nome della categoria come testo
                categoriaSelect.appendChild(option);
            });
        })
        .catch(error => {
            console.error('Errore durante il caricamento delle categorie:', error);
        });
}

// Richiama la funzione per caricare le categorie quando la pagina è pronta
document.addEventListener('DOMContentLoaded', () => {
    caricaCategorie();
});


// Funzione per gestire la ricerca dei prodotti
function ricercaProdotti(event) {
    event.preventDefault();

    const q = document.getElementById('q').value;  // Termini di ricerca
    const categoria = document.getElementById('categoria').value;  // Categoria selezionata

    const divProdotti = document.getElementById('prodotti');
    const catalogGrid = divProdotti.querySelector('.catalog-grid');  // Griglia dei prodotti

    // Aggiungi la classe di caricamento mentre i prodotti vengono caricati
    divProdotti.classList.add('loading');
    catalogGrid.innerHTML = '';  // Pulisce i prodotti precedenti

    fetch(`/MyGardenProject/CercaProdottiServlet?q=${q}&categoria=${categoria}`)
        .then(res => res.json())
        .then(prodotti => {
            divProdotti.classList.remove('loading');  // Rimuovi la classe di caricamento

            if (prodotti.length === 0) {
                catalogGrid.innerHTML = "<p>Nessun prodotto trovato.</p>";  // Messaggio se non ci sono prodotti
            } else {
                prodotti.forEach(prodotto => {
                    // Crea il div per ogni prodotto
                    const div = document.createElement('div');
                    div.classList.add('product-card');  // Applica la classe 'product-card'

                    // Inserisci i dettagli del prodotto nella card
                    div.innerHTML = `
                        <a href="DettaglioProdottoServlet?code=${prodotto.code}">
                            <div class="product-image-wrapper">
                                <img src="${prodotto.image}" alt="${prodotto.name}">
                            </div>
                        </a>
                        <div class="product-content">
                            <h3>${prodotto.name}</h3>
                            <p class="price">€ ${prodotto.price.toFixed(2)}</p>
                            ${prodotto.quantity > 0 ? `
                                <div class="quantity-row">
                                    <span class="available">Disponibilità: ${prodotto.quantity}</span>
                                    <input type="number" id="qty-${prodotto.code}" value="1" min="1" max="${prodotto.quantity}" required>
                                </div>
                                <button class="add-to-cart-btn"
                                    data-product-id="${prodotto.code}"
                                    data-product-name="${prodotto.name}"
                                    data-product-price="${prodotto.price.toFixed(2)}"
                                    data-product-image="${prodotto.image}"
                                    data-product-maxQty="${prodotto.quantity}">
                                    Aggiungi al Carrello
                                </button>
                            ` : `<div class="not-available">Non disponibile</div>`}
                        </div>
                    `;

                    // Aggiungi il div del prodotto alla griglia
                    catalogGrid.appendChild(div);
                });
            }
        })
        .catch(error => {
            divProdotti.classList.remove('loading');
            console.error('Errore durante il caricamento dei prodotti:', error);
        });
}