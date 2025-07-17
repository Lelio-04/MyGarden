-- Rimozione e creazione database unificato

SET FOREIGN_KEY_CHECKS = 0;
DROP DATABASE IF EXISTS storage;
SET FOREIGN_KEY_CHECKS = 1;

CREATE DATABASE storage;
USE storage;

-- Tabella utenti
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    telefono VARCHAR(20),
    data_nascita DATE,
    indirizzo VARCHAR(255),
    citta VARCHAR(100),
    provincia VARCHAR(100),
    cap VARCHAR(10)
);

-- Tabella categorie
CREATE TABLE categories (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT
);

-- Tabella prodotti
CREATE TABLE product (
    code INT PRIMARY KEY AUTO_INCREMENT,
    name CHAR(100) NOT NULL,
    description VARCHAR(1000),
    price DECIMAL(10,2),
    quantity INT DEFAULT 0,
    image VARCHAR(256),
    category_id INT,
    is_deleted BOOLEAN DEFAULT FALSE, -- ✅ campo per soft delete
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL
);

-- Tabella carrello
CREATE TABLE cart_items (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    product_code INT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, product_code),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (product_code) REFERENCES product(code) ON DELETE CASCADE
);

-- Tabella ordini
CREATE TABLE orders (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total DECIMAL(10,2),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Tabella prodotti negli ordini
CREATE TABLE order_items (
    id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    product_code INT NOT NULL,
    quantity INT NOT NULL,
    price_at_purchase DECIMAL(10,2),
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (product_code) REFERENCES product(code)
);

CREATE TABLE order_info (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    address TEXT NOT NULL,
    city VARCHAR(50) NOT NULL,
    cap VARCHAR(10) NOT NULL,
    payment_method VARCHAR(50) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE
);

CREATE TABLE recensioni (
    id INT AUTO_INCREMENT PRIMARY KEY,
    prodotto_id INT NOT NULL,
    utente VARCHAR(100) NOT NULL,
    stelle INT NOT NULL CHECK (stelle BETWEEN 1 AND 5),
    testo TEXT NOT NULL,
    FOREIGN KEY (prodotto_id) REFERENCES product(code) ON DELETE CASCADE
);

-- Inserimento categorie (should be before products if products link to categories)
INSERT INTO categories (name, description) VALUES
('Piante da Interno', 'Ideali per ambienti interni, come appartamenti e uffici.'),
('Piante da Esterno', 'Perfette per balconi, terrazzi o giardini.'),
('Piante Aromatiche', 'Piante utilizzate anche in cucina per le loro proprietà aromatiche.'),
('Piante Fiorite', 'Piante con fiori colorati e decorativi.'),
('Piante Grasse', 'Succulente che richiedono poca acqua e manutenzione.'),
('Attrezzi', 'Attrezzi da giardino indispensabili per mantenere in ordine piante, fiori.');

-- Inserimento utenti
INSERT INTO users (username, email, password,telefono, data_nascita, indirizzo, citta, provincia, cap) VALUES
('admin', 'admin@gmail.com', '1c573dfeb388b562b55948af954a7b344dde1cc2099e978a992790429e7c01a4205506a93d9aef3bab32d6f06d75b7777a7ad8859e672fedb6a096ae369254d2','3451234567',
    '1990-05-15',
    'Via Roma 10',
    'Milano',
    'Milano',
    '20100');

INSERT INTO users (username, email, password, telefono, data_nascita, indirizzo, citta, provincia, cap) VALUES
(
    'utente',
    'utente@gmail.com',
    '1c573dfeb388b562b55948af954a7b344dde1cc2099e978a992790429e7c01a4205506a93d9aef3bab32d6f06d75b7777a7ad8859e672fedb6a096ae369254d2',
    '3451234567',
    '1990-05-15',
    'Via Roma 10',
    'Milano',
    'Milano',
    '20100'
);

-- Inserimento prodotti (THIS MUST COME BEFORE REVIEWS THAT REFERENCE THESE PRODUCTS)
INSERT INTO product (name, description, price, quantity, image,category_id,is_deleted) VALUES
('Aloe Vera', 'Pianta succulenta dalle proprietà curative, l’Aloe Vera è una pianta ornamentale apprezzata per il suo aspetto scultoreo e per le sue proprietà benefiche. Ideale per ambienti interni luminosi o spazi esterni riparati, si distingue per le sue foglie carnose e appuntite, di un verde grigio con margini seghettati. La sua struttura compatta e verticale la rende perfetta per decorare ingressi, terrazzi, soggiorni o uffici con uno stile naturale ed essenziale.', 9.99, 20, 'https://igiardinidigiulia.it/cdn/shop/files/aloevera-piantavera-piantadainterno.jpg?v=1744376819', 1,FALSE),
('Lavanda', 'Pianta profumata che attira api e farfalle, Lavandula Angustifolia, nota anche come lavanda vera, è una pianta aromatica perenne che unisce bellezza, profumo e resistenza. Con un’altezza di 45 cm e un vaso dal diametro di 24 cm, è ideale per impreziosire giardini, balconi e terrazzi con un tocco di eleganza mediterranea.', 5.99, 30, 'https://igiardinidigiulia.it/cdn/shop/files/lavandula-angustifolia-d24-h45i-giardini-di-giulia-844713.jpg?v=1742851959&width=720', 2,FALSE),
('Orchidea', 'Fiore tropicale elegante da appartamento, La Phalaenopsis, conosciuta anche come "orchidea farfalla", è una delle piante da interno più apprezzate per la sua bellezza raffinata e la straordinaria capacità di adattarsi a ogni stile d’arredo. Con i suoi fiori colorati e duraturi, le foglie lucide e le radici aeree argentate, rappresenta un perfetto equilibrio tra design e natura.', 14.90, 10, 'https://igiardinidigiulia.it/cdn/shop/files/orchidea-phalaenopsis-altezza-pianta-70-cm-vaso-di-ceramica-diametro-13-cmpiantei-giardini-di-giulia-321922.jpg?v=1742844629&width=720', 1,FALSE),
('Rosmarino', 'Aromatica da esterno, resistente e profumata, originario dell`Europa, Asia e Africa Il rosmarino è una pianta molto resistente e non necessita di molte cure. Utilizzato per la preparazioni di numerevoli piatti, il rosmarino ha una profumazione intensa. Questa pianta aromatica dal portamento cespuglioso viene raccolta tutto l`anno. Ama le calde temperature e l`esposizione diretta al sole.', 4.20, 25, 'https://bilder.obi-italia.it/39ea7bf5-5dcc-4740-bf6e-d51a178dd1ec/prZZB/266837_3088_1.jpg', 3,FALSE),
('Pothos', 'Pianta rampicante da interni purificatrice d’aria, Pothos Scindapsus Aurea, noto anche come "Pothos dorato", è una soluzione decorativa ideale per chi desidera arricchire la casa o l’ufficio con verde resistente e decorativo. Ogni pianta presenta foglie cuoriformi variegate nei toni del verde e giallo, creando giochi cromatici luminosi e naturali. Il portamento ricadente e la facilità di gestione rendono queste piante perfette per mensole, librerie o vasi sospesi. Inoltre, il Pothos è tra le piante più efficaci nel purificare l’aria, secondo studi NASA.', 7.50, 40, 'https://igiardinidigiulia.it/cdn/shop/files/Progettosenzatitolo-2025-06-20T112825.395.jpg?v=1750411716&width=720', 1,FALSE),
('Sansevieria', 'Pianta resistente, ideale per la camera da letto, la Sansevieria Hanii è una varietà nana della più classica Sansevieria, apprezzata per la sua struttura compatta a rosetta e le foglie carnose dal verde intenso. Con la sua altezza contenuta, si adatta perfettamente a scrivanie, mensole o piccoli tavoli, aggiungendo un tocco di natura ordinata e raffinata. Questa pianta è l’alleata perfetta per chi cerca una soluzione green a bassissima manutenzione. Ideale per ambienti con luce indiretta, tollera bene anche la penombra e necessita di pochissima acqua. La sua rusticità la rende una scelta eccellente anche per chi è alle prime armi con le piante.', 11.00, 18, 'https://igiardinidigiulia.it/cdn/shop/files/sansevieria-hanii-in-vaso-ceramica-diametro-8-cmpiantai-giardini-di-giulia-870714.jpg?v=1742850733&width=720', 1,FALSE),
('Ficus Benjamin', 'Il Ficus Benjamin è una delle piante da appartamento più apprezzate per la sua eleganza sobria e il suo fogliame rigoglioso. Le sue foglie piccole e lucide, di un verde brillante, formano una chioma folta e armoniosa, perfetta per dare un tocco di freschezza e vitalità agli ambienti interni.', 16.50, 12, 'https://igiardinidigiulia.it/cdn/shop/files/ficus-benjamin-altezza-pianta-55-cm-vaso-di-ceramica-boston-diametro-19-cmficusi-giardini-di-giulia-807984.jpg?v=1742847436&width=720', 1,FALSE),
('Felce di Boston', 'La Felce di Boston è una pianta originaria delle zone tropicali asiatiche con dimensioni compatte e fronde pennate strette ad apice appuntito. Questa specie si colloca al primo posto nel palmarès delle piante che depurano l’aria e filtrano meglio sostanze tossiche come la formaldeide e lo xilene. Può raggiungere 60 cm di altezza e 60 cm di ampiezza.', 8.90, 22, 'https://www.artplants.it/media/catalog/product/4/3/43824-nr-1.jpg', 1,FALSE),
('Cactus Mix', 'Assortimento di piccoli cactus da interno, questo kit di piantine grasse è perfetto per creare il tuo terrarium personalizzato! Ogni kit include una selezione di piante grasse di diverse varietà, ideali per la coltivazione in terrarium. Le piantine grasse sono scelte per la loro resistenza e bellezza, richiedendo poca acqua e una cura minima, il che le rende perfette anche per chi non ha il pollice verde. Grazie alle loro dimensioni compatte, sono ideali per creare composizioni verdi che durano nel tempo e donano un tocco naturale e decorativo agli ambienti interni.', 5.99, 40, 'https://igiardinidigiulia.it/cdn/shop/files/kit-piantine-grasse-per-terrariumi-giardini-di-giulia-672444.jpg?v=1742851113&width=720', 5,FALSE),
('Monstera', 'Pianta tropicale con foglie traforate giganti, la Monstera Thai Constellation è una delle piante d’appartamento più rare e affascinanti, apprezzata per le sue foglie variegate color crema che evocano il disegno di una costellazione. Questo esemplare è perfetto per chi cerca una presenza scenografica e al tempo stesso facile da gestire.', 19.90, 10, 'https://igiardinidigiulia.it/cdn/shop/files/monstera-thai-constellation-altezza-pianta-7080-cm-vaso-diametro-24-cmpiantei-giardini-di-giulia-109238.jpg?v=1742844578&width=720', 1,FALSE),
('Crassula Ovata', 'Albero di giada, pianta grassa portafortuna, la Crassula ovata, meglio conosciuta come “pianta di giada”, è una delle succulente più apprezzate e diffuse a livello globale. La sua notevole resistenza, unita a una bellezza estetica senza pari, la rende un elemento immancabile per chi ama il giardinaggio e desidera aggiungere un tocco di verde alle proprie abitazioni. Ma la Crassula ovata non è solo un piacere per gli occhi; è anche portatrice di significati simbolici, spesso legata alla prosperità e alla fortuna, specialmente in molte culture orientali. In questa guida, approfondiremo tutto ciò che serve conoscere riguardo alla cura, ai benefici e ai problemi più comuni associati a questa pianta affascinante.', 8.00, 25, 'https://www.artplants.it/media/catalog/product/cache/e70dcd51a72bd6ad5ddfb802a0ebeff1/3/3/33582-nr-1.webp', 5,FALSE),
('Peperomia', 'Pianta piccola e decorativa da interni, la Peperomia è una pianta da interno perfetta per chi desidera aggiungere un tocco di verde delicato ma distintivo agli ambienti domestici o lavorativi. Con le sue foglie carnose e lucide di colore verde brillante e i fiori bianchi a spiga che si elevano in modo elegante sopra il fogliame, è ideale per scrivanie, mensole e piccoli spazi.', 7.20, 30, 'https://igiardinidigiulia.it/cdn/shop/files/Progettosenzatitolo-2025-06-20T102154.027.jpg?v=1750407731&width=720', 1,FALSE),
('Zamioculcas', 'Pianta elegante a bassa manutenzione, la Zamioculcas Zamiifolia, nota anche come ZZ Plant, è tra le piante d’appartamento più resistenti, perfetta per chi desidera un tocco green elegante senza impegno. Le sue foglie spesse, lucide e di un verde intenso creano una presenza raffinata e moderna, adattandosi perfettamente sia a case che ad ambienti professionali.', 13.50, 15, 'https://www.artplants.it/media/catalog/product/cache/e70dcd51a72bd6ad5ddfb802a0ebeff1/2/6/26913-nr-1.webp', 1,FALSE),
('Begonia Rex', 'Pianta da foglia ornamentale, le Begonia rex sono amate per le foglie, splendide, vistose, coloratissime, a forma di cuore e solcate da motivi che le fanno sembrare arazzi vegetali. Originaria dell’India, perenne ma coltivata come annuale nei nostri climi, la Begonia rex ha dato origine a innumerevoli varietà, con foglie variamente macchiate e zonate, verde scuro, chiare, rosse o purpuree. Le piante raggiungono 30-40 cm di altezza e anche più di 50 cm di diametro. I fiori sbocciano raramente, in pannocchie rosa pallido.', 9.00, 20, 'https://www.artplants.it/media/catalog/product/cache/e70dcd51a72bd6ad5ddfb802a0ebeff1/6/6/66326-nr-1.webp', 4,FALSE),
('Kalanchoe', 'Pianta fiorita da interni molto resistente, La rustica Kalanchoe Calandiva può essere posizionata sia in casa che in giardino. La pianta pittoresca è altrettanto facile da curare. È una pianta forte. Il colore bianco/rosa della Kalanchoe dona una certa gioiosa serenità.Consigli per la cura: La Kalanchoe è una pianta molto semplice che richiede poca manutenzione.Se la Kalanchoe riceve un goccio d`acqua ogni 2 settimane, è sufficiente. A temperature più elevate in estate 1 volta a settimana. Posizionare preferibilmente la Kalanchoe in un luogo soleggiato, con una temperatura compresa tra i 12 e i 25 gradi.In primavera e in estate, puoi posizionare questa Kalanchoe anche all`aperto sul terrazzo!Il prodotto non è adatto al consumo.', 6.80, 28, 'https://bilder.obi-italia.it/7229532d-deba-4632-9329-c19205f757c7/prZZH/8719194200203_4883.jpg', 4,FALSE),
('Kokedama Maranta', 'Pianta dalle foglie variegate che si chiudono di notte, la Kokedama Maranta Leuconera, nota anche come “pianta che prega”, è una soluzione decorativa vivace e affascinante per ambienti interni. Le sue foglie verdi con venature rosse e movimenti naturali seguono la luce del giorno, donando dinamismo visivo e poesia agli spazi. Alta circa 35 cm, questa kokedama è avvolta in una sfera di muschio naturale che sostiene le radici e ne mantiene l’umidità, secondo la tradizionale tecnica giapponese.', 9.90, 18, 'https://igiardinidigiulia.it/cdn/shop/files/kokedama-maranta-altezza-pianta-35-cm-diametro-20-cmda-categorizzarei-giardini-di-giulia-987759.jpg?v=1742846047&width=720', 1,FALSE),
('Calathea', 'Pianta tropicale decorativa da appartamento, il Ficus Ginseng in vaso Oslo è una pianta ornamentale da interno capace di coniugare equilibrio visivo e forza simbolica. Le sue radici esposte e scolpite, abbinate a una chioma compatta e lucente, ne fanno una scelta decorativa d’effetto, perfetta per donare armonia e carattere a spazi domestici o professionali. Ideale per ambienti luminosi, questo bonsai si distingue per la sua resistenza e per il design del vaso in ceramica Oslo, che ne esalta l’estetica naturale con un tocco minimale e contemporaneo.', 14.30, 12, 'https://igiardinidigiulia.it/cdn/shop/files/Calathea_makoyana_in_vaso_12_pianta_verde_pianta_da_interno.jpg?v=1749028597&width=720', 1,FALSE),
('Dracena', 'La Dracaena Lemon Lime è una pianta da interno dal fogliame decorativo e vivace, perfetta per aggiungere colore ed energia agli spazi. Le sue foglie sottili e slanciate presentano una variegatura brillante con strisce verdi, lime e giallo limone, creando un effetto luminoso e moderno. Alta 100 cm e caratterizzata da un portamento verticale compatto, questa Dracaena si adatta facilmente a vari ambienti: soggiorni, studi, ingressi o uffici. Il vaso da 19 cm incluso, dal design sobrio e funzionale, esalta la struttura elegante della pianta senza appesantire l’ambiente.', 17.00, 10, 'https://igiardinidigiulia.it/cdn/shop/files/Progetto_senza_titolo_-_2024-07-16T120141.322_FINALE.jpg?v=1743672907&width=720', 1,FALSE),
('Cycas', 'Pianta antica simile a una palma, la Cycas Revoluta, nota anche come palma giapponese, è una pianta ornamentale sempreverde dal forte impatto visivo. Grazie al suo portamento regale e alle fronde piumate di un verde intenso, è perfetta per creare scenografie verdi eleganti su terrazzi, balconi e in giardino. Questa pianta, che unisce estetica classica e resistenza a lungo termine, è apprezzata per la sua facilità di coltivazione anche in condizioni climatiche non ottimali. Ideale come esemplare singolo o in composizioni tropicali, la Cycas dona un aspetto ordinato e maestoso a ogni spazio esterno.', 22.00, 6, 'https://igiardinidigiulia.it/cdn/shop/files/cycas-revoluta-d-24-cm-h-65-cmi-giardini-di-giulia-306283.jpg?v=1742851719&width=720', 2,FALSE),
('Anthurium', 'Pianta tropicale da fiore rosso brillante, l Anthurium Crystallinum è una pianta d appartamento affascinante, famosa per le sue foglie vellutate a forma di cuore, caratterizzate da venature bianche brillanti su uno sfondo verde intenso. Questa pianta da interni è perfetta per aggiungere un tocco di classe agli spazi abitativi o lavorativi. Grazie alla sua capacità di adattarsi a condizioni di luce indiretta, l Anthurium è ideale per piante per appartamento o piante per ufficio. Oltre alla bellezza, richiede cure minime, rendendola una delle piante resistenti più apprezzate per gli ambienti interni.', 15.50, 14, 'https://igiardinidigiulia.it/cdn/shop/files/AnthuriumCrystallinum.jpg?v=1742848281&width=720', 4,FALSE),
('Gelsomino', 'Rampicante profumato da terrazzo, il gelsomino del Madagascar è una pianta rampicante che può sviluppare germogli lunghi diversi metri. Durante l`estate, questa pianta produce bellissimi fiori bianchi, noti per il loro meraviglioso profumo. Per garantire una sana crescita e una fioritura rigogliosa, il gelsomino del Madagascar richiede un ambiente luminoso e ben ventilato, evitando però l`esposizione diretta al sole. Durante la stagione primaverile, è importante annaffiare abbondantemente la pianta per evitare che il terreno si secchi e assicurare un`adeguata idratazione. Durante l`inverno, la pianta entra in uno stato di riposo, quindi l`annaffiatura può essere ridotta e il terreno può essere lasciato asciugare leggermente tra un`annaffiatura e l`altra.', 10.90, 20, 'https://bilder.obi-italia.it/5550a8d7-6582-44a2-bf62-4e3a009c117e/prZZB/4883_Kranzschlinge_Weiss_1.jpg', 2,FALSE),
('Geranio', 'Fioritura abbondante, ottimo per balconi, il geranio è un geranio eretto della famiglia delle gru ed è una varietà a fioritura lunga e robusta con fiori grandi. È caratterizzato da una grande esposizione di fiori. Il geranio in piedi è particolarmente apprezzato come pianta da balcone o come decorazione da tavola in un vasetto. I gerani sono caratterizzati da fiori pieni ed espressivi. Sono comuni anche le varietà bicolore e con motivi. I diversi colori possono essere facilmente combinati tra se e creano così un fantastico effetto a lunga distanza. Il geranio cresce cespuglioso e ha germogli forti. È uno degli arbusti sempreverdi e raggiunge un altezza di circa 25 - 40 cm.', 5.40, 35, 'https://www.artplants.it/media/catalog/product/cache/e70dcd51a72bd6ad5ddfb802a0ebeff1/9/1/91018-1.webp', 4,FALSE),
('Ibisco', 'Fiore tropicale dai colori vivaci, originario della Cina e dell`India è un arbusto a foglia caduca, densamente ramificato, eretto, non ingombrante, che si inserisce agevolmente anche nei piccoli spazi. Si può foggiare facilmente a mezzo o ad alto fusto. Le foglie possono essere triangolari, ovate o trilobate, più o meno dentate, lunghe fino a 10 cm, di colore verde cupo. I fiori spuntano, ininterrottamente da giugno a settembre. Hanno la forma d`una campanula, larga circa 6 cm e sono formati da petali che possono essere rosa, bianchi, rossi o blu, mentre il centro è rosso cupo con lunghi stami bianchi e antere gialle. I frutti sono capsule grigio brune.', 12.60, 16, 'https://bilder.obi-italia.it/3843d2bd-6be6-4d44-bba8-6b4235f9eacc/prZZB/474536_1189_1.jpg', 4,FALSE),
('Spatifillo', 'Pianta purificatrice con fiori bianchi, lo Spathiphyllum Diamond, noto anche come "Pianta della Pace", è una pianta d’appartamento apprezzata per il suo portamento elegante e per le foglie verde scuro lucide, che contrastano con i suoi fiori bianchi puri a forma di spata. Ideale per creare un ambiente sereno e raffinato, si adatta perfettamente a casa o in ufficio. Grazie alle sue comprovate proprietà purificanti, lo Spathiphyllum aiuta a migliorare la qualità dell’aria interna, assorbendo sostanze nocive come benzene, formaldeide e tricloroetilene. Resistente e di facile manutenzione, prospera anche in condizioni di luce indiretta o moderata.', 11.30, 18, 'https://igiardinidigiulia.it/cdn/shop/files/spathiphyllum-diamond-d-14-cm-h-55-cmi-giardini-di-giulia-294512.jpg?v=1742852800&width=720', 1,FALSE),
('Ciclamino', 'Pianta da fiore invernale, il ciclamino "Midi" da appartamento (Cyclamen persicum) è conosciuto come la "viola domestica" ed è una delle piante fiorite da appartamento più amate. Per un sano sviluppo, preferisce ambienti luminosi ma senza l`esposizione diretta alla luce solare e il calore generato dal riscaldamento. Le temperature ideali oscillano intorno ai 15 °C, evitando di superare in modo costante una temperatura ambiente di 20 °C. Durante il periodo di fioritura, il ciclamino richiede una quantità adeguata di acqua. Tuttavia, è essenziale evitare il ristagno d`acqua e non annaffiare direttamente sul tubero. La pratica ottimale è l`immersione della pianta, evitando un`immersione completa.', 4.90, 32, 'https://bilder.obi-italia.it/1cf6d44a-abf0-455a-8feb-07d6a66d5f22/prZZB/di_grossbluetig_Rot_Topf_1.jpg', 4,FALSE),
('Nolina', 'Pianta con fusto rigonfio e foglie a cascata, la Beaucarnea recurvata, conosciuta anche come “pianta mangiafumo” o “Nolina”, è una pianta da interno ornamentale amatissima per il suo aspetto unico e scultoreo. Il tronco rigonfio a forma di bulbo, che funge da riserva d’acqua naturale, la rende una pianta semigrassa perfetta per chi cerca stile e praticità. Con un’altezza di 55 cm e un vaso da 23 cm di diametro, questa pianta è ideale per arredare ingressi, soggiorni o uffici con un tocco esotico ma ordinato. Le sue lunghe foglie ricurve, sottili e decorative, creano un effetto a fontana che aggiunge movimento e leggerezza agli spazi.', 13.00, 15, 'https://igiardinidigiulia.it/cdn/shop/files/Pianta_Beaucarnea_recurvata-pianta_da_interno-pianta_vera.jpg?v=1745477505&width=720', 1,FALSE),
('Yucca', 'Pianta a rosetta da appartamento o esterni, La Yucca è un genere di piante originario delle regioni a clima tropicale secco. In ambienti domestici, di solito non superano i 2 metri di altezza. Le piante coltivate in vaso richiedono ambienti caldi e luminosi, concimazioni liquide poco frequenti, annaffiature controllate durante l`estate e più diradate durante l`inverno. Si consiglia di rinvasare o rinterrare la pianta ogni primavera, utilizzando terriccio universale.', 16.70, 9, 'https://bilder.obi-italia.it/b4d1cbcc-5b41-48fb-81b3-5407842fe738/prZZB/image.jpg', 2,FALSE),
('Echeveria', 'Succulenta a forma di rosa, L`Echeveria è una delle piante succulente più consciute. E`disponibile nei colori rosso, oro, argento, bronzo e bianco. L`Echeveria è una pianta Easy-Care, necessita quindi di poche e semplici cure.', 4.50, 45, 'https://bilder.obi-italia.it/5a1a7d26-ae2a-474d-89ad-fae0bff731d9/pr07H/image.jpeg', 5,FALSE),
('Pala da giardino', 'Pala resistente per scavare, trapiantare e lavorare il terreno con facilità.', 14.99, 25, 'https://bilder.obi-italia.it/295db3ef-2678-4fd2-9384-24dd60a22a14/pr07H/image.jpeg', 6, false),
('Forbici da potatura', 'Forbici ergonomiche ideali per la potatura precisa di fiori e rami sottili.', 9.50, 40, 'https://bilder.obi-italia.it/7e80c2f5-83ce-46a2-aaad-6fbfe74388f0/prZZO/143951_2729_1.jpg', 6, false),
('Rastrello a mano', 'Compatto rastrello in acciaio per livellare e pulire il suolo del giardino.', 7.99, 30, 'https://bilder.obi-italia.it/235f16fe-a857-4cb9-b7d3-77ff2ad53e63/prZZH/370239_2080_1.jpg', 6, false),
('Zappa doppia', 'Zappa a doppia lama per rompere il terreno e rimuovere le erbacce.', 11.20, 15, 'https://bilder.obi-italia.it/bee863f5-68fc-43c4-8084-8a5228de4163/prZZO/ke_Doppelhacke_eingestielt.jpg', 6, false),
('Set attrezzi 5 in 1', 'Kit completo di attrezzi manuali per giardinaggio in una pratica custodia.', 24.90, 12, 'https://m.media-amazon.com/images/I/61b9dcB2ZlL.__AC_SY300_SX300_QL70_ML2_.jpg', 6, false),
('Annaffiatoio da 1,5L', 'Annaffiatoio in plastica resistente con beccuccio lungo per piante da interno e da esterno.', 6.80, 50, 'https://bilder.obi-italia.it/cd24821f-010c-4e86-b520-62eee6a20c05/prZZH/5438049_2699_1.jpg', 6, false),
('Guanti da giardinaggio', 'Guanti rinforzati e traspiranti per proteggere le mani durante i lavori in giardino.', 5.60, 60, 'https://bilder.obi-italia.it/69304008-b131-47ea-ace8-88c9fdad2edb/pr07H/image.jpeg', 6, false),
('Cesoie telescopiche', 'Cesoie regolabili per potare rami alti senza l’uso di scale.', 19.99, 10, 'https://bilder.obi-italia.it/25b8e426-3530-4e39-9a76-7d5c375972ee/prZZB/image.jpg', 6, false);

-- Recensioni per il Prodotto 1 (Aloe Vera) - Più recensioni, variegate
INSERT INTO recensioni (prodotto_id, utente, stelle, testo) VALUES
(1, 'Luca Bianchi', 5, 'L\'Aloe Vera è fantastica, proprio come descritta! Cresce a vista d\'occhio.'),
(1, 'Sara Rossi', 4, 'Buona qualità, ma la spedizione è stata un po\' lenta.'),
(1, 'Marco Verdi', 2, 'Non sono soddisfatto. La pianta è arrivata con foglie gialle.'),
(1, 'Giulia Neri', 5, 'Splendida! La migliore Aloe che abbia mai avuto. Consigliatissima.');

-- Recensioni per il Prodotto 2 (Lavanda) - Positive
INSERT INTO recensioni (prodotto_id, utente, stelle, testo) VALUES
(2, 'Eleonora Gialli', 5, 'Profumo inebriante, ha trasformato il mio balcone.'),
(2, 'Davide Blu', 4, 'Molto bella, ma mi aspettavo un po\' più grande.');

-- Recensioni per il Prodotto 3 (Orchidea) - Miste
INSERT INTO recensioni (prodotto_id, utente, stelle, testo) VALUES
(3, 'Chiara Rosa', 5, 'Orchidea meravigliosa, fioritura abbondante e duratura.'),
(3, 'Federico Marroni', 3, 'Nella media, i fiori sono durati poco.');

-- Recensione per il Prodotto 4 (Rosmarino) - Positiva
INSERT INTO recensioni (prodotto_id, utente, stelle, testo) VALUES
(4, 'Anna Viola', 5, 'Rosmarino robusto, perfetto per le mie ricette!');

-- Recensione per il Prodotto 5 (Pothos) - Media
INSERT INTO recensioni (prodotto_id, utente, stelle, testo) VALUES
(5, 'Giuseppe Argento', 3, 'Pothos un po\' piccolo, ma sano. Vedremo come crescerà.');

-- Recensioni per il Prodotto 6 (Sansevieria) - Positive
INSERT INTO recensioni (prodotto_id, utente, stelle, testo) VALUES
(6, 'Marianna Oro', 5, 'Pianta super resistente, la Sansevieria è un must per tutti.'),
(6, 'Luigi Fumo', 4, 'Buona qualità, adatta anche a poca luce.');

-- Recensione per il Prodotto 7 (Ficus Benjamin) - Positiva
INSERT INTO recensioni (prodotto_id, utente, stelle, testo) VALUES
(7, 'Sofia Cielo', 4, 'Ficus Benjamin folto, ha riempito bene il mio salotto.');

-- Recensione per il Prodotto 8 (Felce di Boston) - Negativa
INSERT INTO recensioni (prodotto_id, utente, stelle, testo) VALUES
(8, 'Tommaso Sabbia', 2, 'Arrivata quasi secca, difficile da recuperare.');

-- Recensioni per il Prodotto 9 (Cactus Mix) - Positive
INSERT INTO recensioni (prodotto_id, utente, stelle, testo) VALUES
(9, 'Valentina Bronzo', 5, 'Kit di cactus adorabile, varietà molto carina!'),
(9, 'Piero Luna', 5, 'Ottimo per il terrarium, tutte le piantine in salute.');

-- Recensione per il Prodotto 10 (Monstera) - Mista
INSERT INTO recensioni (prodotto_id, utente, stelle, testo) VALUES
(10, 'Angela Sole', 5, 'Monstera spettacolare, le variegature sono incredibili!'),
(10, 'Enrico Neve', 3, 'Prezzo elevato per le dimensioni ricevute.');

-- Recensione per il Prodotto 11 (Crassula Ovata) - Positiva
INSERT INTO recensioni (prodotto_id, utente, stelle, testo) VALUES
(11, 'Martina Mare', 4, 'Crassula Ovata ben curata, spero mi porti fortuna!');

-- Recensione per il Prodotto 12 (Peperomia) - Media
INSERT INTO recensioni (prodotto_id, utente, stelle, testo) VALUES
(12, 'Luca Fuoco', 3, 'Piantina simpatica, ma non mi ha entusiasmato.');

-- Recensione per il Prodotto 13 (Zamioculcas) - Positiva
INSERT INTO recensioni (prodotto_id, utente, stelle, testo) VALUES
(13, 'Giulia Bosco', 5, 'Perfetta per l\'ufficio, elegante e robusta.');

-- Recensione per il Prodotto 14 (Begonia Rex) - Mista
INSERT INTO recensioni (prodotto_id, utente, stelle, testo) VALUES
(14, 'Marco Monti', 4, 'Belle foglie colorate, un po\' delicata da trasportare.'),
(14, 'Silvia Collina', 2, 'Arrivata con molte foglie rovinate, delusa.');

-- Recensione per il Prodotto 15 (Kalanchoe) - Media
INSERT INTO recensioni (prodotto_id, utente, stelle, testo) VALUES
(15, 'Antonio Prato', 3, 'Fiori carini, ma la pianta sembra un po\' sofferente.');

-- Recensione per il Prodotto 16 (Kokedama Maranta) - Positiva
INSERT INTO recensioni (prodotto_id, utente, stelle, testo) VALUES
(16, 'Laura Verde', 5, 'La Kokedama è un\'opera d\'arte, la Maranta è stupenda!');

-- Recensione per il Prodotto 17 (Calathea) - Negativa
INSERT INTO recensioni (prodotto_id, utente, stelle, testo) VALUES
(17, 'Piero Fabbro', 1, 'Morto dopo una settimana, nonostante le cure.');

-- Recensione per il Prodotto 18 (Dracena) - Positiva
INSERT INTO recensioni (prodotto_id, utente, stelle, testo) VALUES
(18, 'Elisa Artista', 5, 'Colori brillanti e fogliame rigoglioso, la adoro!');

-- Recensione per il Prodotto 19 (Cycas) - Positiva
INSERT INTO recensioni (prodotto_id, utente, stelle, testo) VALUES
(19, 'Simone Agricoltore', 4, 'Cycas di dimensioni buone, un classico che fa sempre la sua figura.');

-- Recensione per il Prodotto 20 (Anthurium) - Mista
INSERT INTO recensioni (prodotto_id, utente, stelle, testo) VALUES
(20, 'Andrea Giardiniera', 5, 'Fiori rossi intensi, molto decorativa.'),
(20, 'Roberta Bricolage', 3, 'Il fiore è bello, ma le foglie sono un po\' spoglie.');

-- Recensione per il Prodotto 21 (Gelsomino) - Positiva
INSERT INTO recensioni (prodotto_id, utente, stelle, testo) VALUES
(21, 'Paolo Fiori', 5, 'Profumo meraviglioso, ha trasformato il mio terrazzo.');

-- Recensione per il Prodotto 22 (Geranio) - Media
INSERT INTO recensioni (prodotto_id, utente, stelle, testo) VALUES
(22, 'Maria Esperta', 3, 'Geranio classico, nessun difetto ma neanche eccellenze.');

-- Recensione per il Prodotto 23 (Ibisco) - Positiva
INSERT INTO recensioni (prodotto_id, utente, stelle, testo) VALUES
(23, 'Marco Viaggiatore', 4, 'Bellissimi colori tropicali, molto scenografico.');

-- Recensione per il Prodotto 24 (Spatifillo) - Positiva
INSERT INTO recensioni (prodotto_id, utente, stelle, testo) VALUES
(24, 'Anna AmanteVerde', 5, 'Pianta della pace, elegante e purificante. Top!');

-- Recensione per il Prodotto 25 (Ciclamino) - Mista
INSERT INTO recensioni (prodotto_id, utente, stelle, testo) VALUES
(25, 'Giulia Casalinga', 4, 'Fioritura abbondante, peccato per i pochi colori disponibili.'),
(25, 'Roberto Studente', 2, 'Deluso, i petali sono caduti subito.');

-- Recensione per il Prodotto 26 (Nolina) - Positiva
INSERT INTO recensioni (prodotto_id, utente, stelle, testo) VALUES
(26, 'Davide Designer', 5, 'Nolina unica, aggiunge un tocco scultoreo all\'ambiente.');

-- Recensione per il Prodotto 27 (Yucca) - Positiva
INSERT INTO recensioni (prodotto_id, utente, stelle, testo) VALUES
(27, 'Elena Sportiva', 4, 'Yucca resistente, perfetta per il mio patio.');

-- Recensione per il Prodotto 28 (Echeveria) - Positiva
INSERT INTO recensioni (prodotto_id, utente, stelle, testo) VALUES
(28, 'Carlo Collezionista', 5, 'Echeveria bellissima, la forma a rosa è incantevole.');

-- Recensione per il Prodotto 29 (Pala da giardino) - Positiva
INSERT INTO recensioni (prodotto_id, utente, stelle, testo) VALUES
(29, 'Francesco Contadino', 5, 'Pala robusta, un attrezzo affidabile per il giardino.');

-- Recensione per il Prodotto 30 (Forbici da potatura) - Mista
INSERT INTO recensioni (prodotto_id, utente, stelle, testo) VALUES
(30, 'Simona Ortolana', 4, 'Taglio preciso, ma a volte si bloccano.'),
(30, 'Luca Tuttofare', 3, 'Non il massimo della comodità, ma fanno il loro lavoro.');

-- Recensione per il Prodotto 31 (Rastrello a mano) - Positiva
INSERT INTO recensioni (prodotto_id, utente, stelle, testo) VALUES
(31, 'Alessio Hobby', 5, 'Rastrello perfetto per le piccole aeree, leggero e maneggevole.');

-- Recensione per il Prodotto 32 (Zappa doppia) - Positiva
INSERT INTO recensioni (prodotto_id, utente, stelle, testo) VALUES
(32, 'Giulia Campagna', 4, 'Utile per sarchiare, ma il manico è un po\' corto.');

-- Recensione per il Prodotto 33 (Set attrezzi 5 in 1) - Positiva
INSERT INTO recensioni (prodotto_id, utente, stelle, testo) VALUES
(33, 'Riccardo Appassionato', 5, 'Set completo, copre tutte le esigenze di giardinaggio base.');

-- Recensione per il Prodotto 34 (Annaffiatoio da 1,5L) - Media
INSERT INTO recensioni (prodotto_id, utente, stelle, testo) VALUES
(34, 'Chiara AmicaPiante', 3, 'Semplice annaffiatoio, ma il beccuccio è un po\' largo.');

-- Recensione per il Prodotto 35 (Guanti da giardinaggio) - Positiva
INSERT INTO recensioni (prodotto_id, utente, stelle, testo) VALUES
(35, 'Sara Protetta', 5, 'Guanti comodi e resistenti, non si rovinano facilmente.');

-- Recensione per il Prodotto 36 (Cesoie telescopiche) - Positiva
INSERT INTO recensioni (prodotto_id, utente, stelle, testo) VALUES
(36, 'Massimo Potatore', 5, 'Eccellenti per i rami alti, robuste e facili da usare.');