// Funzione per caricare le categorie
function caricaCategorie() {
    fetch('/MyGardenProject/getCategories')
        .then(res => res.json())
        .then(categorie => {
            const categoriaSelect = document.getElementById('categoria');
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

// Funzione per gestire la ricerca
function ricercaProdotti(event) {
    event.preventDefault();

    const q = document.getElementById('q').value;
    const categoria = document.getElementById('categoria').value;

    const divProdotti = document.getElementById('prodotti');
    const catalogGrid = divProdotti.querySelector('.catalog-grid'); // Seleziona la griglia

    // Aggiungi la classe di caricamento mentre i prodotti vengono caricati
    divProdotti.classList.add('loading');
    catalogGrid.innerHTML = '';  // Pulisce i prodotti precedenti

    fetch(`/MyGardenProject/CercaProdottiServlet?q=${q}&categoria=${categoria}`)
        .then(res => res.json())
        .then(prodotti => {
            divProdotti.classList.remove('loading');  // Rimuovi la classe 'loading' quando i prodotti sono caricati

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
                                    data-max-qty="${prodotto.quantity}">
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
            divProdotti.classList.remove('loading');  // Rimuovi la classe 'loading' in caso di errore
            console.error('Errore durante il caricamento dei prodotti:', error);
        });
}

// Carica le categorie all'inizio
document.addEventListener('DOMContentLoaded', () => {
    caricaCategorie();
    document.getElementById('searchForm').addEventListener('submit', ricercaProdotti);
});
