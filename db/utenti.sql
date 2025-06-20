-- Elimina e ricrea il database
DROP DATABASE IF EXISTS utenti;
CREATE DATABASE utenti;
USE utenti;

-- Crea la tabella utenti
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL
);

-- Inserisce l'utente admin con password "admin" hashata in SHA-512
INSERT INTO users (username, email, password)
VALUES (
    'admin',
    'admin@gmail.com',
    "1c573dfeb388b562b55948af954a7b344dde1cc2099e978a992790429e7c01a4205506a93d9aef3bab32d6f06d75b7777a7ad8859e672fedb6a096ae369254d2"
);