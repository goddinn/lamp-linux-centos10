-- sql/schema.sql

-- Cria a base de dados se ela não existir
CREATE DATABASE IF NOT EXISTS `clm-recrutamento`
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

-- Seleciona a base de dados
USE `clm-recrutamento`;

-- Cria a tabela de candidaturas
CREATE TABLE IF NOT EXISTS `candidaturas` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `nome_completo` VARCHAR(255) NOT NULL,
    `telemovel` VARCHAR(20) NOT NULL,
    `email` VARCHAR(255) NOT NULL,
    `caminho_cv` VARCHAR(512) NOT NULL COMMENT 'Caminho relativo para o ficheiro do CV no servidor',
    `info_adicional` TEXT,
    `data_submissao` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- (Opcional, mas recomendado) Criar um utilizador de DB dedicado para a aplicação
-- Substitua 'SuaPasswordSegura123!' por uma password forte
CREATE USER IF NOT EXISTS 'clm_webapp'@'localhost' IDENTIFIED BY 'web_pass';

-- Conceder permissões apenas para esta base de dados
GRANT SELECT, INSERT, UPDATE, DELETE ON `clm-recrutamento`.* TO 'clm_webapp'@'localhost';

-- Aplicar as alterações
FLUSH PRIVILEGES;