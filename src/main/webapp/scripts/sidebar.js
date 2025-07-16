// sidebar.js

// Questa variabile viene impostata nel tuo JSP. Assicurati che sia sempre disponibile.
// Esempio: <script> var isLoggedIn = <%= (username != null) ? "true" : "false" %>; </script>
// Per test locali senza JSP, puoi impostarla manualmente:
// var isLoggedIn = false; // true per simulare utente loggato, false per guest

// --- Funzioni per la Modale Personalizzata (Spostate qui per accessibilità) ---
let resolveModalPromise;

function showCustomModal(message, title, type) {
    return new Promise(resolve => {
        resolveModalPromise = resolve;

        const modalOverlay = document.getElementById('custom-modal-overlay');
        const modalTitle = document.getElementById('custom-modal-title');
        const modalMessage = document.getElementById('custom-modal-message');
        const modalButtons = document.getElementById('custom-modal-buttons');

        if (!modalOverlay || !modalTitle || !modalMessage || !modalButtons) {
            console.error("Elementi della modale non trovati. Assicurati che l'HTML della modale sia presente.");
            // Fallback a alert/confirm del browser se gli elementi non sono presenti
            if (type === 'alert') {
                alert(title + '\n' + message);
                resolve(true);
            } else if (type === 'confirm') {
                resolve(confirm(title + '\n' + message));
            }
            return;
        }

        modalTitle.textContent = title || 'Messaggio';
        modalMessage.textContent = message;
        modalButtons.innerHTML = ''; // Pulisci i bottoni precedenti

        if (type === 'alert') {
            const okButton = document.createElement('button');
            okButton.textContent = 'OK';
            okButton.className = 'custom-modal-button primary';
            okButton.onclick = () => {
                modalOverlay.classList.remove('is-visible');
                resolve(true); // Risolve a true per gli alert
            };
            modalButtons.appendChild(okButton);
        } else if (type === 'confirm') {
            const cancelButton = document.createElement('button');
            cancelButton.textContent = 'Annulla';
            cancelButton.className = 'custom-modal-button secondary';
            cancelButton.onclick = () => {
                modalOverlay.classList.remove('is-visible');
                resolve(false); // Risolve a false se l'utente annulla
            };
            modalButtons.appendChild(cancelButton);

            const confirmButton = document.createElement('button');
            confirmButton.textContent = 'Conferma';
            confirmButton.className = 'custom-modal-button primary';
            confirmButton.onclick = () => {
                modalOverlay.classList.remove('is-visible');
                resolve(true); // Risolve a true se l'utente conferma
            };
            modalButtons.appendChild(confirmButton);
        }

        modalOverlay.classList.add('is-visible');
    });
}

function showCustomAlert(message, title = 'Attenzione') {
    return showCustomModal(message, title, 'alert');
}

function showCustomConfirm(message, title = 'Conferma Azione') {
    return showCustomModal(message, title, 'confirm');
}

// --- Funzioni per l'apertura e chiusura della sidebar ---
function apriSidebarCarrello(event) {
    if (event && typeof event.preventDefault === 'function') {
        event.preventDefault();
    }

    const sidebar = document.getElementById('sidebar-carrello');
    const overlay = document.getElementById('sidebar-overlay') || createOverlay();

    // Mostra la sidebar e l'overlay con transizione
    sidebar.style.display = 'block';
    sidebar.offsetWidth; // Forza il reflow per la transizione CSS
    sidebar.classList.add('is-visible');
    overlay.classList.add('is-visible');

    // Se l'utente è loggato, recupera il carrello dal server
    if (isLoggedIn) {
        fetch('/MyGardenProject/GetCartServlet')
            .then(response => {
                if (!response.ok) {
                    // Se la risposta non è OK, tenta di leggere il testo dell'errore
                    return response.text().then(text => {
                        const errorMessage = response.statusText || 'Errore sconosciuto';
                        throw new Error(`Errore nel recupero del carrello: ${errorMessage} (Stato: ${response.status}) Risposta: ${text}`);
                    });
                }
                return response.json();
            })
            .then(data => {
                console.log('Dati carrello dal server:', data); // Log per debug
                aggiornaCarrelloUI(data);
            })
            .catch(error => {
                console.error('Errore durante il fetch del carrello (utente loggato):', error);
                const carrelloItemsDiv = document.getElementById('carrello-items');
                carrelloItemsDiv.innerHTML = '<p class="carrello-vuoto-msg" style="color: var(--color-error, red);">Errore nel caricamento del carrello. Riprova più tardi.</p>';
                const carrelloTotaleSpan = document.getElementById('carrello-totale');
                carrelloTotaleSpan.textContent = '0.00';
                const checkoutSection = document.getElementById('checkout-section');
                checkoutSection.innerHTML = '';
                // Usa la modale personalizzata al posto di alert()
                showCustomAlert('Non è stato possibile caricare il carrello. Si prega di riprovare.', 'Errore Carrello');
            });
    } else {
        // Se l'utente NON è loggato, recupera il carrello dal localStorage
        const guestCart = getGuestCart();
        console.log('Dati carrello guest:', guestCart); // Log per debug
        aggiornaCarrelloUI(guestCart); // Passa il carrello locale alla UI
    }
}

function chiudiSidebar() {
    const sidebar = document.getElementById('sidebar-carrello');
    const overlay = document.getElementById('sidebar-overlay');

    if (sidebar) sidebar.classList.remove('is-visible');
    if (overlay) overlay.classList.remove('is-visible');

    // Aggiungi un listener per nascondere l'elemento solo dopo la transizione
    if (sidebar) {
        sidebar.addEventListener('transitionend', function handler() {
            if (sidebar && !sidebar.classList.contains('is-visible')) {
                sidebar.style.display = 'none';
            }
            sidebar.removeEventListener('transitionend', handler);
        }, { once: true }); // { once: true } assicura che il listener venga rimosso dopo l'esecuzione
    }

    if (overlay) {
        overlay.addEventListener('transitionend', function handler() {
            if (overlay && !overlay.classList.contains('is-visible')) {
                overlay.remove(); // Rimuovi l'overlay dal DOM
            }
            overlay.removeEventListener('transitionend', handler);
        }, { once: true });
    }
}

function createOverlay() {
    const overlay = document.createElement('div');
    overlay.id = 'sidebar-overlay';
    overlay.onclick = chiudiSidebar; // Chiudi la sidebar cliccando sull'overlay
    document.body.appendChild(overlay);
    return overlay;
}

// --- Gestione Carrello Locale (per utenti non loggati) ---
function getGuestCart() {
    try {
        const cartString = localStorage.getItem('guestCart');
        return cartString ? JSON.parse(cartString) : [];
    } catch (e) {
        console.error("Errore nel recupero del carrello guest da localStorage:", e);
        return []; // Restituisce un carrello vuoto in caso di errore
    }
}

function saveGuestCart(cart) {
    try {
        localStorage.setItem('guestCart', JSON.stringify(cart));
    } catch (e) {
        console.error("Errore nel salvataggio del carrello guest in localStorage:", e);
    }
}

// Variabile globale per memorizzare i dati del carrello attualmente visualizzati
let currentCartData = [];

// --- Funzioni di Aggiornamento UI Carrello ---
function aggiornaCarrelloUI(cartData) {
    currentCartData = cartData || []; // Aggiorna la variabile globale
    const carrelloItemsDiv = document.getElementById('carrello-items');
    const carrelloTotaleSpan = document.getElementById('carrello-totale');
    const checkoutSection = document.getElementById('checkout-section');
    const svuotaCarrelloBtn = document.getElementById('svuota-carrello-btn');

    let totale = 0;

    carrelloItemsDiv.innerHTML = ''; // Pulisci il contenuto attuale

    if (currentCartData.length === 0) {
        carrelloItemsDiv.innerHTML = '<p class="carrello-vuoto-msg">Il carrello è vuoto.</p>';
        checkoutSection.innerHTML = ''; // Nascondi la sezione checkout se il carrello è vuoto
        if (svuotaCarrelloBtn) {
            svuotaCarrelloBtn.style.display = 'none'; // Nascondi il bottone svuota carrello
        }
    } else {
        currentCartData.forEach(function(item) {
            console.log('Processing cart item:', item); // Log per debug ogni item

            const product = item.product || {};

            const productName = product.name || 'Prodotto Sconosciuto';
            const productPrice = parseFloat(product.price) || 0;
            const productImage = product.image || '';
            const maxQty = parseInt(product.quantity) || 0; // Recupera la quantità massima disponibile dal prodotto

            console.log('Product details for UI:', { productName, productPrice, productImage, quantity: item.quantity, maxQty: maxQty });

            const itemDiv = document.createElement('div');
            itemDiv.classList.add('carrello-item');
            itemDiv.dataset.productCode = item.productCode; // Aggiungi il data-attribute per i bottoni +/-

            const imageUrl = productImage && productImage !== 'placeholder.png'
                                ? productImage
                                : `https://placehold.co/80x80/cccccc/333333?text=No+Image`;

            itemDiv.innerHTML = `
                <img src="${imageUrl}" alt="${productName}" class="carrello-item-image">
                <div class="carrello-item-details">
                    <span class="carrello-item-name">${productName}</span>
                    <div class="quantity-controls">
                        <span class="carrello-item-quantity">${item.quantity}</span>
						<button class="quantity-btn increase-qty" data-product-code="${item.productCode}" data-max-qty="${maxQty}">+</button>
						<button class="quantity-btn decrease-qty" data-product-code="${item.productCode}" data-max-qty="${maxQty}">-</button>
                    </div>
                    <span class="carrello-item-price">€${(productPrice * item.quantity).toFixed(2)}</span>
                </div>
                <button class="remove-item-btn" data-product-code="${item.productCode}">&times;</button>
            `;
            carrelloItemsDiv.appendChild(itemDiv);
            totale += productPrice * item.quantity;
        });

        carrelloItemsDiv.querySelectorAll('.remove-item-btn').forEach(button => {
            button.addEventListener('click', function() {
                const productCode = parseInt(this.dataset.productCode);
                console.log('Tentativo di rimozione. productCode dal bottone (convertito):', productCode);
                rimuoviDalCarrello(productCode);
            });
        });

        // ⭐ NUOVO: Aggiungi event listener ai bottoni + e - ⭐
        carrelloItemsDiv.querySelectorAll('.increase-qty').forEach(button => {
            button.addEventListener('click', function() {
                const productCode = parseInt(this.dataset.productCode);
                const maxQty = parseInt(this.dataset.maxQty);
                aumentaQuantita(productCode, maxQty);
            });
        });

        carrelloItemsDiv.querySelectorAll('.decrease-qty').forEach(button => {
            button.addEventListener('click', function() {
                const productCode = parseInt(this.dataset.productCode);
                diminuisciQuantita(productCode);
            });
        });

        // ⭐ MODIFICATO: Da link a bottone per intercettare il click ⭐
        checkoutSection.innerHTML = `
            <button id="btn-procedi-checkout" class="btn-checkout">Procedi al Checkout</button>
        `;
        if (svuotaCarrelloBtn) {
            svuotaCarrelloBtn.style.display = 'block';
        }

        // ⭐ NUOVO: Aggiungi event listener al bottone di checkout ⭐
        const checkoutButton = document.getElementById('btn-procedi-checkout');
        if (checkoutButton) {
            checkoutButton.addEventListener('click', checkStockBeforeCheckout);
        }
    }

    carrelloTotaleSpan.textContent = totale.toFixed(2);
}

// --- Funzione per controllare lo stock prima del checkout ---
async function checkStockBeforeCheckout() {
    console.log('Controllo stock prima del checkout...');
    let stockIssues = [];

    // ⭐ MODIFICA QUI: Se l'utente NON è loggato, salta il controllo stock e reindirizza ⭐
    if (!isLoggedIn) {
        console.log('Utente non loggato, bypasso il controllo stock e reindirizzo al checkout/login.');
        window.location.href = '/MyGardenProject/checkout-page'; // Questa pagina dovrebbe gestire il reindirizzamento al login
        return;
    }

    // Se il carrello è vuoto, non fare nulla (il bottone non dovrebbe essere visibile, ma per sicurezza)
    if (currentCartData.length === 0) {
        showCustomAlert('Il tuo carrello è vuoto. Aggiungi prodotti prima di procedere.', 'Carrello Vuoto');
        return;
    }

    // Per gli utenti loggati, è meglio rifare un fetch per avere i dati più aggiornati,
    // inclusa la disponibilità in magazzino.
    let cartToCheck = currentCartData; // Per i guest, usiamo currentCartData (ma questa parte non verrà eseguita per i guest ora)

    // Questa parte verrà eseguita solo se isLoggedIn è true
    try {
        const response = await fetch('/MyGardenProject/GetCartServlet');
        if (!response.ok) {
            throw new Error('Errore nel recupero del carrello per il controllo stock.');
        }
        cartToCheck = await response.json();
        console.log('Carrello ricaricato dal server per controllo stock:', cartToCheck);
    } catch (error) {
        console.error('Errore durante il ricaricamento del carrello per il controllo stock:', error);
        showCustomAlert('Impossibile verificare la disponibilità dei prodotti. Riprova più tardi.', 'Errore Verifica Stock');
        return; // Blocca il checkout in caso di errore nella verifica
    }


    for (const item of cartToCheck) {
        const product = item.product;
        // Assumi che product.quantity sia la disponibilità in magazzino dal DB
        const availableStock = product.quantity || 0; // Se non definito, considera 0
        const requestedQuantity = item.quantity;

        if (requestedQuantity > availableStock) {
            stockIssues.push({
                productName: product.name || 'Prodotto Sconosciuto',
                productCode: item.productCode,
                requestedQuantity: requestedQuantity,
                availableStock: availableStock
            });
        }
    }

    if (stockIssues.length > 0) {
        let alertMessage = 'Attenzione: I seguenti prodotti superano la quantità disponibile in magazzino. Le quantità verranno aggiustate al massimo disponibile al momento dell\'ordine:\n\n';
        stockIssues.forEach(issue => {
            alertMessage += `- "${issue.productName}" (codice: ${issue.productCode}): Richiesti ${issue.requestedQuantity}, disponibili ${issue.availableStock}.\n`;
        });
        alertMessage += '\nProcedendo, le quantità verranno automaticamente ridotte alla disponibilità massima.';

        const confirmed = await showCustomConfirm(alertMessage, 'Quantità Non Disponibile');
        if (!confirmed) {
            console.log('Checkout annullato dall\'utente a causa di problemi di stock.');
            return; // Blocca il checkout se l'utente annulla
        }

        // ⭐ Aggiorna le quantità sul server prima del reindirizzamento ⭐
        const updatedProductCodes = [];
        const updatedQuantities = [];

        cartToCheck.forEach(item => {
            const issue = stockIssues.find(si => si.productCode === item.productCode);
            if (issue) {
                // Se c'è un problema di stock per questo articolo, usa la quantità disponibile
                updatedProductCodes.push(item.productCode);
                updatedQuantities.push(issue.availableStock);
            } else {
                // Altrimenti, usa la quantità originale richiesta
                updatedProductCodes.push(item.productCode);
                updatedQuantities.push(item.quantity);
            }
        });

        // Costruisci i dati del form per la richiesta POST
        let formData = new URLSearchParams();
        updatedProductCodes.forEach(code => formData.append('productCode', code));
        updatedQuantities.forEach(qty => formData.append('quantity', qty));

        try {
            const updateResponse = await fetch('/MyGardenProject/update-cart-quantity', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded'
                },
                body: formData.toString()
            });

            if (!updateResponse.ok) {
                const errorText = await updateResponse.text();
                throw new Error(`Errore durante l'aggiornamento delle quantità del carrello: ${updateResponse.status} - ${errorText}`);
            }

            const updateResult = await updateResponse.json();
            if (updateResult.status === 'success') {
                console.log('Quantità del carrello aggiustate con successo sul server.');
                // Dopo l'aggiornamento riuscito, ricarica la sidebar per aggiornare la UI
                apriSidebarCarrello();
                // Potresti voler mostrare un alert di successo per l'aggiustamento prima del reindirizzamento
                // await showCustomAlert('Le quantità del carrello sono state aggiornate in base alla disponibilità.', 'Carrello Aggiornato');
            } else {
                throw new Error(`Errore dal server durante l'aggiornamento delle quantità: ${updateResult.message}`);
            }
        } catch (error) {
            console.error('Errore durante l\'invio dell\'aggiornamento delle quantità:', error);
            showCustomAlert('Si è verificato un errore durante l\'aggiornamento delle quantità del carrello. Riprova.', 'Errore Aggiornamento Carrello');
            return; // Blocca il checkout se l'aggiornamento fallisce
        }
    }

    // Se arriviamo qui, significa che non ci sono problemi di stock
    // o l'utente ha scelto di procedere e le quantità sono state aggiornate.
    console.log('Stock verificato. Procedo al checkout.');
    window.location.href = '/MyGardenProject/checkout-page'; // Reindirizza alla pagina di checkout
}


// --- Funzioni Aggiunta/Rimozione/Svuotamento ---
async function aggiungiAlCarrello(productCode, productName, productPrice, productImage, maxQty, quantityToAdd = 1) { // Aggiunto quantityToAdd con default
    if (isNaN(productCode) || productCode === null || typeof productCode === 'undefined') {
        console.error('ID prodotto non valido:', productCode);
        await showCustomAlert('Impossibile aggiungere il prodotto al carrello: ID non valido.', 'Errore');
        return;
    }

    // Qui recuperiamo la quantità corrente nel carrello (server o locale)
    // È essenziale avere `currentCartData` popolato correttamente (es. tramite apriSidebarCarrello() o un caricamento iniziale)
    let currentQuantityInCart = 0;
    const currentCart = isLoggedIn ? await getLoggedInCartFromServer() : getGuestCart(); // Recupera il carrello attuale in base allo stato del login
    const existingItemInCart = currentCart.find(item => item.productCode === productCode);
    if (existingItemInCart) {
        currentQuantityInCart = existingItemInCart.quantity;
    }

    // Calcola la nuova quantità dopo l'aggiunta
    const newTotalQuantity = currentQuantityInCart + quantityToAdd;

    if (newTotalQuantity > maxQty) {
        await showCustomAlert(`Non è possibile aggiungere ${quantityToAdd} unità di questo prodotto. La disponibilità massima è ${maxQty}, e ne hai già ${currentQuantityInCart} nel carrello.`, 'Quantità Massima Raggiunta');
        return;
    }

    if (isLoggedIn) {
        // Utente loggato: invia al server la quantità desiderata
        fetch('/MyGardenProject/AddToCartServlet', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: `productCode=${productCode}&quantity=${quantityToAdd}` // ⭐ PASSAGGI QUI quantityToAdd ⭐
        })
        .then(response => {
            if (!response.ok) {
                return response.text().then(text => {
                    const errorMessage = response.statusText || 'Errore sconosciuto';
                    throw new Error(`Errore nell'aggiunta al carrello: ${errorMessage} (Stato: ${response.status}) Risposta: ${text}`);
                });
            }
            return response.json();
        })
        .then(data => {
            console.log('Prodotto aggiunto al carrello (server):', data);
            apriSidebarCarrello(); // Ricarica e aggiorna il carrello dal server
            showCustomAlert(`${quantityToAdd} ${productName} aggiunti al carrello!`, 'Successo');
        })
        .catch(error => {
            console.error('Errore durante l\'aggiunta al carrello (server):', error);
            showCustomAlert(`Errore nell'aggiunta al carrello. Riprova. Dettagli: ${error.message}`, 'Errore');
        });
    } else {
        // Utente NON loggato: gestisci localmente
        const guestCart = getGuestCart();
        let productFound = false;
        for (let i = 0; i < guestCart.length; i++) {
            if (guestCart[i].productCode === productCode) {
                // Incrementa la quantità esistente di quantityToAdd
                guestCart[i].quantity += quantityToAdd; // ⭐ INCREMENTO DI quantityToAdd ⭐
                productFound = true;
                break;
            }
        }
        if (!productFound) {
            // Aggiungi un nuovo articolo con la quantità desiderata
            guestCart.push({
                productCode: productCode,
                quantity: quantityToAdd, // ⭐ QUANTITÀ INIZIALE quantityToAdd ⭐
                product: {
                    id: productCode,
                    name: productName || 'Prodotto Sconosciuto',
                    price: parseFloat(productPrice) || 0,
                    image: productImage || '',
                    quantity: parseInt(maxQty) || 0
                }
            });
        }
        saveGuestCart(guestCart);
        apriSidebarCarrello(); // Ricarica e aggiorna il carrello dalla cache locale
        showCustomAlert(`${quantityToAdd} ${productName} aggiunti al carrello!`, 'Successo');
        console.log('Prodotto aggiunto al carrello (guest):', guestCart);
    }
}

// ⭐ AGGIUNGI QUESTA FUNZIONE SE NON L'HAI GIÀ PER RECUPERARE IL CARRELLO DAL SERVER ⭐
// (Questo è necessario per il controllo della quantità massima per utenti loggati)
async function getLoggedInCartFromServer() {
    try {
        const response = await fetch('/MyGardenProject/GetCartServlet'); // Assumi esista una servlet per ottenere il carrello utente
        if (!response.ok) {
            throw new Error(`Errore nel recupero carrello dal server: ${response.statusText}`);
        }
        const data = await response.json();
        // Assumi che il server restituisca un array di oggetti con productCode e quantity
        // Potresti dover mappare la risposta del server per farla corrispondere al formato del carrello guest
        return data.items || []; // Esempio: se il JSON ha un campo 'items'
    } catch (error) {
        console.error('Errore getLoggedInCartFromServer:', error);
        return [];
    }
}


async function rimuoviDalCarrello(productCode) {
    console.log('rimuoviDalCarrello chiamato con productCode:', productCode); // Log iniziale

    // Usa la modale personalizzata al posto di confirm()
    const confirmed = await showCustomConfirm('Sei sicuro di voler rimuovere questo articolo dal carrello?', 'Rimuovi Articolo');

    if (confirmed) {
        if (isLoggedIn) {
            // Utente loggato: invia al server
            console.log('Utente loggato. Invio richiesta di rimozione al server per productCode:', productCode); // Log per utente loggato
            fetch(`/MyGardenProject/remove-from-cart?productCode=${productCode}`, {
                method: 'POST'
            })
            .then(response => {
                if (!response.ok) {
                    return response.text().then(text => {
                        const errorMessage = response.statusText || 'Errore sconosciuto';
                        throw new Error(`Errore nella rimozione dal carrello: ${errorMessage} (Stato: ${response.status}) Risposta: ${text}`);
                    });
                }
                return response.json();
            })
            .then(data => {
                console.log('Articolo rimosso dal server:', data);
                apriSidebarCarrello(); // Ricarica dal server
                showCustomAlert('Articolo rimosso dal carrello!', 'Rimosso');
            })
            .catch(error => {
                console.error('Errore durante la rimozione dal carrello (server):', error);
                showCustomAlert('Errore nella rimozione dell\'articolo. Riprova.', 'Errore');
            });
        } else {
            // Utente NON loggato: gestisci localmente
            console.log('Utente guest. Rimozione locale per productCode:', productCode); // Log per utente guest
            let guestCart = getGuestCart();
            console.log('Carrello guest prima della rimozione:', JSON.stringify(guestCart)); // Log carrello guest prima
            // La correzione assicura che il confronto sia tra numeri interi
            guestCart = guestCart.filter(item => item.productCode !== productCode);
            saveGuestCart(guestCart);
            console.log('Carrello guest dopo la rimozione:', JSON.stringify(guestCart)); // Log carrello guest dopo
            apriSidebarCarrello(); // Ricarica dalla cache locale
            showCustomAlert('Articolo rimosso dal carrello!', 'Rimosso');
            console.log('Articolo rimosso dal carrello (guest).');
        }
    } else {
        console.log('Rimozione annullata dall\'utente.'); // Log se l'utente annulla
    }
}

async function svuotaCarrello() {
    // Usa la modale personalizzata al posto di confirm()
    const confirmed = await showCustomConfirm('Sei sicuro di voler svuotare il carrello?', 'Svuota Carrello');

    if (confirmed) {
        if (isLoggedIn) {
            // Utente loggato: invia al server
            fetch('/MyGardenProject/clear-cart', {
                method: 'POST'
            })
            .then(response => {
                if (!response.ok) {
                    const errorMessage = response.statusText || 'Errore sconosciuto';
                    throw new Error(`Errore nello svuotamento del carrello: ${errorMessage} (Stato: ${response.status})`);
                }
                return response.json();
            })
            .then(data => {
                console.log('Carrello svuotato dal server:', data);
                apriSidebarCarrello(); // Ricarica dal server
                showCustomAlert('Carrello svuotato!', 'Svuotato');
            })
            .catch(error => {
                console.error('Errore durante lo svuotamento del carrello (server):', error);
                showCustomAlert('Errore nello svuotamento del carrello. Riprova.', 'Errore');
            });
        } else {
            // Utente NON loggato: svuota localmente
            saveGuestCart([]); // Salva un carrello vuoto
            apriSidebarCarrello(); // Ricarica dalla cache locale
            showCustomAlert('Carrello svuotato!', 'Svuotato');
            console.log('Carrello svuotato (guest).');
        }
    }
}

// --- NUOVE FUNZIONI: Aumento e Diminuzione Quantità ---

async function aggiornaQuantitaCarrello(productCode, newQuantity) {
    if (isNaN(productCode) || productCode === null || typeof productCode === 'undefined') {
        console.error('ID prodotto non valido:', productCode);
        await showCustomAlert('Impossibile aggiornare la quantità: ID prodotto non valido.', 'Errore');
        return;
    }

    if (newQuantity < 0) newQuantity = 0; // Previene quantità negative

    if (isLoggedIn) {
        // Utente loggato: invia al server
        fetch('/MyGardenProject/update-cart-quantity', { // Assumi un endpoint per l'aggiornamento
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded'
            },
            body: `productCode=${productCode}&quantity=${newQuantity}`
        })
        .then(response => {
            if (!response.ok) {
                return response.text().then(text => {
                    const errorMessage = response.statusText || 'Errore sconosciuto';
                    throw new Error(`Errore nell'aggiornamento quantità: ${errorMessage} (Stato: ${response.status}) Risposta: ${text}`);
                });
            }
            return response.json();
        })
        .then(data => {
            console.log('Quantità aggiornata sul server:', data);
            apriSidebarCarrello(); // Ricarica il carrello dal server
            if (newQuantity === 0) {
                showCustomAlert('Articolo rimosso dal carrello.', 'Rimosso');
            }
        })
        .catch(error => {
            console.error('Errore durante l\'aggiornamento quantità (server):', error);
            showCustomAlert('Errore nell\'aggiornamento della quantità. Riprova.', 'Errore');
        });
    } else {
        // Utente NON loggato: gestisci localmente
        let guestCart = getGuestCart();
        const itemIndex = guestCart.findIndex(item => item.productCode === productCode);

        if (itemIndex > -1) {
            if (newQuantity === 0) {
                guestCart.splice(itemIndex, 1); // Rimuovi l'elemento se la quantità è 0
                showCustomAlert('Articolo rimosso dal carrello.', 'Rimosso');
            } else {
                guestCart[itemIndex].quantity = newQuantity;
            }
            saveGuestCart(guestCart);
            apriSidebarCarrello(); // Ricarica dalla cache locale
            console.log('Quantità aggiornata (guest):', guestCart);
        }
    }
}

async function aumentaQuantita(productCode, maxQty) {
    const item = currentCartData.find(i => i.productCode === productCode);
    if (!item) {
        console.warn('Prodotto non trovato nel carrello per l\'aumento di quantità:', productCode);
        return;
    }

    const newQuantity = item.quantity + 1;

    // Controllo sul massimo disponibile
    if (newQuantity > maxQty) {
        await showCustomAlert(`Non è possibile superare la quantità massima disponibile per questo prodotto: ${maxQty}.`, 'Quantità Massima Raggiunta');
        return;
    }

    await aggiornaQuantitaCarrello(productCode, newQuantity);
}

async function diminuisciQuantita(productCode) {
    const item = currentCartData.find(i => i.productCode === productCode);
    if (!item) {
        console.warn('Prodotto non trovato nel carrello per la diminuzione di quantità:', productCode);
        return;
    }

    const newQuantity = item.quantity - 1;

    // Se la quantità scende a 0, chiedi conferma per la rimozione
    if (newQuantity === 0) {
        const confirmed = await showCustomConfirm('Riducendo la quantità a zero, l\'articolo verrà rimosso dal carrello. Continuare?', 'Rimuovi Articolo');
        if (!confirmed) {
            return; // L'utente ha annullato, non fare nulla
        }
    }

    await aggiornaQuantitaCarrello(productCode, newQuantity);
}


// --- Inizializzazione degli Event Listener ---
document.addEventListener('DOMContentLoaded', function() {
    const addToCartButtons = document.querySelectorAll('.add-to-cart-btn');

    addToCartButtons.forEach(button => {
        button.addEventListener('click', function() {
            const productId = parseInt(this.dataset.productId);
            const productName = this.dataset.productName;
            const productPrice = parseFloat(this.dataset.productPrice);
            const productImage = this.dataset.productImage;
            const maxQty = parseInt(this.dataset.maxQty); // Recupera la quantità massima disponibile

            // ⭐ NOVITÀ: Recupera la quantità desiderata dall'input numerico
            // L'ID dell'input è "qty-" seguito dal productCode
            const quantityInput = document.getElementById(`qty-${productId}`);
            let quantityToAdd = 1; // Quantità di default, se l'input non è trovato o è invalido

            if (quantityInput) {
                const inputValue = parseInt(quantityInput.value);
                // Valida l'input per assicurarti che sia un numero, >= 1 e non superi la quantità massima disponibile
                if (!isNaN(inputValue) && inputValue >= 1 && inputValue <= maxQty) {
                    quantityToAdd = inputValue;
                } else {
                    console.warn(`Quantità non valida per il prodotto ${productId}: ${quantityInput.value}. Verrà aggiunta 1 unità.`);
                    showCustomAlert('La quantità inserita non è valida. Aggiunta 1 unità.', 'Attenzione');
                    quantityInput.value = 1; // Resetta l'input a 1 per coerenza
                }
            }

            console.log('Adding to cart:', { productId, productName, productPrice, productImage, maxQty, quantityToAdd }); // Log per debug
            // ⭐ Passa la quantità desiderata alla funzione aggiungiAlCarrello
            aggiungiAlCarrello(productId, productName, productPrice, productImage, maxQty, quantityToAdd);
        });
    });

    const cartButton = document.getElementById('cart-button');
    if (cartButton) {
        cartButton.addEventListener('click', apriSidebarCarrello);
    }

    const svuotaCarrelloBtn = document.getElementById('svuota-carrello-btn');
    if (svuotaCarrelloBtn) {
        svuotaCarrelloBtn.addEventListener('click', svuotaCarrello);
    }

    // --- Delega degli eventi per i bottoni dinamici del carrello ---
    // Questo blocco dovrebbe essere già presente e funzionante
    document.body.addEventListener('click', async function(event) {
        if (event.target.classList.contains('remove-item-btn')) {
            const productCode = parseInt(event.target.dataset.productCode);
            await rimuoviDalCarrello(productCode);
        } else if (event.target.classList.contains('increase-qty')) {
            const productCode = parseInt(event.target.dataset.productCode);
            const maxQty = parseInt(event.target.dataset.maxQty);
            await aumentaQuantita(productCode, maxQty);
        } else if (event.target.classList.contains('decrease-qty')) {
            const productCode = parseInt(event.target.dataset.productCode);
            await diminuisciQuantita(productCode);
        } else if (event.target.id === 'btn-procedi-checkout') {
            await checkStockBeforeCheckout();
        } else if (event.target.id === 'svuota-carrello-btn') {
            await svuotaCarrello();
        }
    });

    // ⭐ Logica per l'unione carrello al login/caricamento pagina per utente loggato ⭐
    if (typeof isLoggedIn !== 'undefined' && isLoggedIn) {
        const guestCart = getGuestCart();
        if (guestCart.length > 0) {
            const productCodes = guestCart.map(item => item.productCode);
            const quantities = guestCart.map(item => item.quantity);

            let formData = new URLSearchParams();
            productCodes.forEach(code => formData.append('productCode', code));
            quantities.forEach(qty => formData.append('quantity', qty));

            fetch('/MyGardenProject/MergeCartServlet', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: formData.toString()
            })
            .then(response => {
                if (!response.ok) {
                    return response.text().then(text => { throw new Error(`Errore durante l'unione del carrello guest: ${response.status} - ${text}`); });
                }
                return response.json();
            })
            .then(data => {
                console.log('Unione carrello guest completata:', data);
                if (data.status === 'success') {
                    saveGuestCart([]);
                    showCustomAlert('Il tuo carrello temporaneo è stato unito al tuo account!', 'Carrello Unito');
                } else {
                    showCustomAlert(`Errore nell'unione del carrello: ${data.message}`, 'Errore Unione Carrello');
                }
            })
            .catch(error => {
                console.error('Errore nel fetch dell\'unione carrello:', error);
                showCustomAlert('Si è verificato un errore durante l\'unione del carrello. Potrebbe essere necessario aggiungerli manualmente.', 'Errore Grave');
            });
        }
    }
});
