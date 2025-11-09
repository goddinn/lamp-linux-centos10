<?php
// php/config.php

/* Definições da Base de Dados */
define('DB_SERVER', 'localhost');
define('DB_USERNAME', 'clm_webapp'); // O utilizador criado no script SQL
define('DB_PASSWORD', 'pass_app'); // A password definida no script SQL
define('DB_NAME', 'clm-recrutamento');

/* Tentar conexão com a Base de Dados MariaDB */
$mysqli = new mysqli(DB_SERVER, DB_USERNAME, DB_PASSWORD, DB_NAME);

// Definir o charset para UTF-8 (mb4 para suporte completo a unicode)
$mysqli->set_charset("utf8mb4");

// Verificar conexão
if($mysqli->connect_error){
    // Em produção, não deve expor o erro detalhado.
    // Grave num log e mostre uma mensagem genérica.
    die("ERRO: Não foi possível conectar. " . $mysqli->connect_error);
}
?>
