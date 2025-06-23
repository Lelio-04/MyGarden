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

-- Inserimento utenti di esempio
INSERT INTO users (username, email, password) VALUES
('admin', 'admin@gmail.com', '1c573dfeb388b562b55948af954a7b344dde1cc2099e978a992790429e7c01a4205506a93d9aef3bab32d6f06d75b7777a7ad8859e672fedb6a096ae369254d2'),
('utente', 'utente@gmail.com', '1c573dfeb388b562b55948af954a7b344dde1cc2099e978a992790429e7c01a4205506a93d9aef3bab32d6f06d75b7777a7ad8859e672fedb6a096ae369254d2');

-- Tabella prodotti
CREATE TABLE product (	
  code INT PRIMARY KEY AUTO_INCREMENT,
  name CHAR(20) NOT NULL,
  description CHAR(100),
  price  DECIMAL(10,2),
  quantity INT DEFAULT 0,
  image VARCHAR(256)
);

-- Inserimento prodotti di esempio
INSERT INTO product VALUES 
(1, 'Samsung F8000', 'TV 48 pollici', 550, 5, 'images/favicon.png'),
(2, 'Huawei P8', 'Smartphone', 390, 13, 'images/favicon.png'),
(3, 'Onkyo SR 646', 'Receiver', 510, 4, 'images/favicon.png'),
(4, 'Sony w808c', 'TV 43 pollici', 640, 11, 'images/favicon.png'),
(5, 'Dyson 6300', 'Aspirapolvere', 329, 3, 'images/favicon.png'),
(6, 'Asus 3200', 'Router', 189, 22, 'images/favicon.png'),
(7, 'XSamsung F8000', 'DioCane', 550, 5, 'https://www.giardinaggio.it/appartamento/singolepiante/chlorophytum/chlorophytum_NG1.jpg');

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

-- Inserimento prodotti nel carrello dell'utente 'utente'
-- Recupero id dinamico
SET @utente_id = (SELECT id FROM users WHERE username = 'utente');

DELETE FROM cart_items WHERE user_id = @utente_id;

INSERT INTO cart_items (user_id, product_code, quantity) VALUES
(@utente_id, 1, 1),
(@utente_id, 2, 2);

-- Visualizzazione finale per controllo
SELECT * FROM cart_items WHERE user_id = @utente_id;
