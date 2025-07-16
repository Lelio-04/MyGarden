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
        await mergeGuestCartWithUserCart();
    }
    await fetchCartFromServer();
    updateCartDisplay();
}

function openCart() {
    const sidebar = document.getElementById("cartSidebar");
    if (sidebar.classList.contains("open")) return;

    sidebar.classList.add("open");

    if (isUserLoggedIn()) {
        fetchCartFromServer().then(updateCartDisplay);
    } else {
        loadGuestCart();
        updateCartDisplay();
    }
}

async function initUserSession() {
    if (localStorage.getItem('cartMerged') !== 'true') {
        await mergeGuestCartWithUserCart();
    }
    await fetchCartFromServer();
    updateCartDisplay();
}

function deduplicateCart(cartArray) {
    const map = new Map();
    for (let item of cartArray) {
        if (map.has(item.id)) {
            const existing = map.get(item.id);
            existing.quantity = Math.min(existing.quantity + item.quantity, item.maxQty);
        } else {
            map.set(item.id, { ...item });
        }
    }
    return Array.from(map.values());
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

async function addToCart(product) {
    if (!isUserLoggedIn()) {
        try {
            const response = await fetch(`/MyGardenProject/get-product-info?id=${product.id}`);
            if (!response.ok) throw new Error('Errore recupero disponibilità.');
            const data = await response.json();
            if (typeof data.maxQty !== 'number') {
                alert('Errore nel caricamento delle informazioni prodotto.');
                return;
            }
            product.maxQty = data.maxQty;
        } catch (error) {
            console.error('Errore fetch maxQty per guest:', error);
            alert('Errore durante il controllo disponibilità prodotto.');
            return;
        }
    }

    if (product.quantity > product.maxQty) {
        alert(`La quantità richiesta supera la disponibilità per ${product.name} (${product.maxQty}).`);
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
                alert(`Errore: ${json.error || 'Impossibile aggiungere il prodotto.'}`);
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
            alert('Errore durante l\'aggiunta al carrello.');
        }
    } else {
        let item = cart.find(i => String(i.id) === String(product.id));
        if (item) {
            const totalQty = item.quantity + product.quantity;
            if (totalQty > product.maxQty) {
                alert(`Puoi aggiungere solo ${product.maxQty - item.quantity} unità di ${product.name}.`);
                item.quantity = product.maxQty;
            } else {
                item.quantity = totalQty;
            }
        } else {
            if (product.quantity > product.maxQty) {
                alert(`Disponibilità limitata. Imposto quantità a ${product.maxQty}.`);
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

async function mergeGuestCartWithUserCart() {
    if (isMerging) {
        console.warn("⛔ Merge già in corso (client-side lock)");
        return;
    }
    isMerging = true;

    try {
        const now = Date.now();
        const lastMerge = parseInt(localStorage.getItem('lastMergeTimestamp') || '0', 10);
        if (now - lastMerge < 1000) {
            console.warn("⛔ Merge eseguito troppo recentemente (cooldown)");
            return;
        }

        if (localStorage.getItem('cartMerged') === 'true') {
            console.info("⛔ Merge già eseguito (flag cartMerged presente)");
            return;
        }

        const guestCartStr = localStorage.getItem('guestCart');
        if (!guestCartStr) {
            console.info("⛔ Nessun carrello guest presente");
            return;
        }

        const parsedGuestCart = JSON.parse(guestCartStr);
        if (!Array.isArray(parsedGuestCart) || parsedGuestCart.length === 0) {
            console.info("⛔ Carrello guest vuoto");
            return;
        }

        const guestCartJson = JSON.stringify(parsedGuestCart.map(item => ({
            productCode: item.id,
            quantity: item.quantity,
            product: {
                id: item.id,
                name: item.name,
                price: item.price,
                image: item.image,
                quantity: item.maxQty
            }
        })));

        const response = await fetch('/MyGardenProject/MergeCartServlet', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: guestCartJson
        });

        const text = await response.text();
        console.log('📦 MergeCartServlet response:', text);

        if (!response.ok) {
            console.error('❌ Errore HTTP durante il merge:', text);
            return;
        }

        const mergedCart = JSON.parse(text);
        cart = deduplicateCart(mapServerCartToClientCart(mergedCart));
        updateCartDisplay();

        localStorage.setItem('cartMerged', 'true');
        localStorage.setItem('lastMergeTimestamp', now.toString());
        localStorage.removeItem('guestCart');
        console.log("✅ Merge completato con successo");
    } catch (error) {
        console.error('❌ Errore durante il merge del carrello:', error);
    } finally {
        isMerging = false;
    }
}

function logout() {
    localStorage.removeItem('cartMerged');
    localStorage.removeItem('lastMergeTimestamp');
    localStorage.removeItem('guestCart');
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

    cart = deduplicateCart(cart);
    updateCartDisplay();
});
