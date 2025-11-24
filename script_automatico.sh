#!/bin/bash

# ==============================================================================
# SCRIPT DE CONFIGURAÇÃO AUTOMÁTICA - LAMP STACK (CLM SOLUTIONS)
# ==============================================================================
# DEVE SER EXECUTADO COMO ROOT.
# ==============================================================================

# --- Variáveis de Configuração ---
STATIC_IP="192.168.1.33/24"
GATEWAY="192.168.1.254"
DNS_SERVERS="8.8.8.8 1.1.1.1"
NETWORK_INTERFACE="ens160"

SSH_PORT="22"
ADMIN_USERS="cleber luis manuel admin"
FTP_USER="recrutador_clm"
FTP_PASS="recruta"

# Email para alertas do Let's Encrypt
ADMIN_EMAIL_PARA_SSL="admin@lamp-clm.duckdns.org"
DOMAIN_NAME="lamp-clm.duckdns.org"
ROOT_DB_PASS="root_lampdb"

# --- Sair em caso de erro ---
set -e

echo "--- [FASE 1/10] INICIANDO CONFIGURAÇÃO DO SISTEMA BASE ---"

# 1.1. Definir Hostname
hostnamectl set-hostname lamp-clm
echo "127.0.0.1   lamp-clm" >> /etc/hosts
echo "::1         lamp-clm" >> /etc/hosts
echo "Hostname 'lamp-clm' definido."

# 1.2. Configurar IP Estático
echo "Configurando IP estático $STATIC_IP para $NETWORK_INTERFACE..."
nmcli connection modify $NETWORK_INTERFACE ipv4.method manual
nmcli connection modify $NETWORK_INTERFACE ipv4.addresses $STATIC_IP
nmcli connection modify $NETWORK_INTERFACE ipv4.gateway $GATEWAY
nmcli connection modify $NETWORK_INTERFACE ipv4.dns "$DNS_SERVERS"
nmcli connection up $NETWORK_INTERFACE
echo "Rede configurada."

# 1.3. Configurar NTP (Chrony)
echo "Instalando e configurando Chrony (NTP)..."
dnf -y install chrony

# Configurar Chrony para usar servidores Google
cat > /etc/chrony.conf << 'EOF'
# Use public servers from the pool.ntp.org project.
# Please consider joining the pool (https://www.pool.ntp.org/join.html).
#
# Servidor NTP da Google
pool time1.google.com iburst
pool time2.google.com iburst
pool time3.google.com iburst

# Use NTP servers from DHCP.
sourcedir /run/chrony-dhcp

# Record the rate at which the system clock gains/losses time.
driftfile /var/lib/chrony/drift

# Allow the system clock to be stepped in the first three updates
# if its offset is larger than 1 second.
makestep 1.0 3

# Enable kernel synchronization of the real-time clock (RTC).
rtcsync
logdir /var/log/chrony
EOF

systemctl enable --now chronyd
echo "NTP configurado."

# 1.4. Ativar Repositórios (EPEL & CRB)
echo "Ativando repositórios EPEL e CRB..."
dnf config-manager --set-enabled crb
dnf -y install epel-release
dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-10.noarch.rpm
echo "Repositórios ativados."


echo "--- [FASE 2/10] INSTALANDO PACOTES DE SERVIÇOS E SEGURANÇA ---"
dnf -y update # Atualizar o sistema 

dnf -y install httpd mod_ssl 
    mariadb-server php php-fpm php-mysqlnd php-json php-fileinfo vsftpd fail2ban certbot python3-certbot-apache mod_security setroubleshoot-server setroubleshoot-plugins policycoreutils-python-utils curl git wget
echo "Todos os pacotes foram instalados."
echo "--- [FASE 3/10] IMPLEMENTANDO APLICAÇÃO WEB (CLM SOLUTIONS) ---"
# 3.1. Criar estrutura de diretórios
mkdir -p /var/www/html/{css,js,php,sql,uploads/curriculos,assets}

# 3.2. Criar ficheiro index.html
cat > /var/www/html/index.html << 'EOF'
<!DOCTYPE html>
<html lang="pt">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CLM Solutions - Consultoria em Cibersegurança</title>
    <link rel="stylesheet" href="css/style.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600;700&display=swap" rel="stylesheet">
</head>
<body>

    <header class="navbar">
        <div class="container">
            <a href="#" class="nav-logo">
                <strong>CLM</strong> Solutions
            </a>
            <nav>
                <ul>
                    <li><a href="#sobre">Sobre Nós</a></li>
                    <li><a href="#servicos">Serviços</a></li>
                    <li><a href="#recrutamento">Recrutamento</a></li>
                    <li><a href="#contacto" class="btn btn-outline">Contacto</a></li>
                </ul>
            </nav>
        </div>
    </header>

    <main>
        <section class="hero">
            <div class="container fade-in-section">
                <h1>Protegemos o Futuro Digital da Sua Empresa</h1>
                <p>Consultoria especializada em Cibersegurança, da estratégia à implementação.</p>
                <a href="#servicos" class="btn btn-primary">Descubra os Nossos Serviços</a>
            </div>
        </section>

        <section id="sobre" class="container section-padding fade-in-section">
            <h2 class="section-title">Sobre a CLM Solutions</h2>
            <p class="section-subtitle">Somos o seu parceiro estratégico na mitigação de riscos digitais. Com uma equipa de especialistas certificados, a CLM Solutions oferece soluções de cibersegurança de ponta, alinhadas com as necessidades do seu negócio.</p>
        </section>

        <section id="servicos" class="section-padding bg-light">
            <div class="container">
                <h2 class="section-title">Os Nossos Serviços</h2>
                <div class="servicos-grid">
                    <div class="servico-card fade-in-section">
                        <i class="servico-icon">🛡️</i>
                        <h3>Pentesting & Análise de Vulnerabilidades</h3>
                        <p>Identificamos e corrigimos falhas de segurança antes que sejam exploradas por atacantes.</p>
                    </div>
                    <div class="servico-card fade-in-section">
                        <i class="servico-icon">📋</i>
                        <h3>Consultoria GDPR & Compliance</h3>
                        <p>Garantimos que a sua organização cumpre todas as normativas de proteção de dados.</p>
                    </div>
                    <div class="servico-card fade-in-section">
                        <i class="servico-icon">📡</i>
                        <h3>SOC as a Service (SOCaaS)</h3>
                        <p>Monitorização, deteção e resposta a incidentes de segurança 24/7/365.</p>
                    </div>
                </div>
            </div>
        </section>

        <section id="recrutamento" class="section-padding">
            <div class="container">
                <h2 class="section-title">Junta-te à Nossa Equipa</h2>
                <p class="section-subtitle">Procuramos os melhores talentos em cibersegurança. Envie a sua candidatura.</p>
                
                <form id="form-recrutamento" class="recrutamento-form" enctype="multipart/form-data">
                    <div class="form-group">
                        <label for="nome_completo">Nome Completo</label>
                        <input type="text" id="nome_completo" name="nome_completo" required>
                    </div>
                    <div class="form-group">
                        <label for="telemovel">Número de Telemóvel</label>
                        <input type="tel" id="telemovel" name="telemovel" required>
                    </div>
                    <div class="form-group">
                        <label for="email">Email</label>
                        <input type="email" id="email" name="email" required>
                    </div>
                    <div class="form-group">
                        <label for="cv">Upload de CV (PDF, DOC, DOCX - Máx 5MB)</label>
                        <input type="file" id="cv" name="cv" accept=".pdf,.doc,.docx" required>
                    </div>
                    <div class="form-group">
                        <label for="info_adicional">Informação Adicional (Opcional)</label>
                        <textarea id="info_adicional" name="info_adicional" rows="4"></textarea>
                    </div>
                    
                    <div id="form-mensagem"></div> <button type="submit" class="btn btn-primary">Enviar Candidatura</button>
                </form>
            </div>
        </section>

    </main>

    <footer class="footer">
        <div class="container">
            <p>&copy; 2025 CLM Solutions. Todos os direitos reservados.</p>
            <p> lamp-clm.duckdns.org | Criado em CentOS10 </p>

            <div class="project-authorship">
                <p><strong>Autores do projeto:</strong> Manuel Godinho, Luís Vera e Cleber Monteiro (GRSI0325)</p>
                <p><strong>Curso:</strong> Gestão de Redes e Sistemas Informáticos em ATEC Palmela</p>
                <p><strong>Formador:</strong> Dário Quental</p>
                <p><strong>Repositório:</strong> <a href="https://github.com/goddinn/lamp-linux-centos10" target="_blank" rel="noopener noreferrer">github.com/goddinn/lamp-linux-centos10</a></p>
            </div>
            </div>
    </footer>

    <script src="js/main.js"></script>
</body>
</html>
EOF

# 3.3. Ficheiro style.css
cat > /var/www/html/css/style.css << 'EOF'
/* css/style.css */

/* --- Variáveis Globais (Inspirado em logicalis.pt) --- */
:root {
    --primary-color: #00a0dc; /* Um teal/azul vibrante */
    --dark-blue: #0d2c4b;     /* Azul escuro corporativo */
    --light-gray: #f4f7f6;
    --text-color: #333;
    --text-light: #555;
    --white: #ffffff;
    --font-family: 'Poppins', sans-serif;
}

/* --- Reset Básico --- */
* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
}

html {
    scroll-behavior: smooth;
}

body {
    font-family: var(--font-family);
    color: var(--text-color);
    line-height: 1.6;
}

/* --- Componentes Reutilizáveis --- */
.container {
    max-width: 1100px;
    margin: 0 auto;
    padding: 0 20px;
}

.section-padding {
    padding: 80px 0;
}

.section-title {
    font-size: 2.5rem;
    color: var(--dark-blue);
    text-align: center;
    margin-bottom: 20px;
}

.section-subtitle {
    font-size: 1.1rem;
    text-align: center;
    color: var(--text-light);
    max-width: 700px;
    margin: 0 auto 40px auto;
}

.bg-light {
    background-color: var(--light-gray);
}

.btn {
    display: inline-block;
    padding: 12px 28px;
    border-radius: 5px;
    text-decoration: none;
    font-weight: 600;
    transition: all 0.3s ease;
}

.btn-primary {
    background-color: var(--primary-color);
    color: var(--white);
    border: 2px solid var(--primary-color);
}

.btn-primary:hover {
    background-color: #007ea8;
    border-color: #007ea8;
}

.btn-outline {
    background-color: transparent;
    color: var(--primary-color);
    border: 2px solid var(--primary-color);
}

.btn-outline:hover {
    background-color: var(--primary-color);
    color: var(--white);
}

/* --- Navegação --- */
.navbar {
    background-color: var(--white);
    box-shadow: 0 2px 10px rgba(0,0,0,0.05);
    position: sticky;
    top: 0;
    z-index: 100;
}

.navbar .container {
    display: flex;
    justify-content: space-between;
    align-items: center;
    height: 80px;
}

.nav-logo {
    text-decoration: none;
    font-size: 1.5rem;
    color: var(--dark-blue);
}

.navbar nav ul {
    display: flex;
    list-style: none;
    align-items: center;
}

.navbar nav li {
    margin-left: 25px;
}

.navbar nav a {
    text-decoration: none;
    color: var(--text-light);
    font-weight: 500;
    transition: color 0.3s ease;
}

.navbar nav a:hover {
    color: var(--primary-color);
}

/* --- Secção Hero --- */
.hero {
    background: linear-gradient(rgba(13, 44, 75, 0.85), rgba(13, 44, 75, 0.85)), url('../assets/hero-bg.jpg') no-repeat center center/cover;
    height: 70vh;
    display: flex;
    align-items: center;
    justify-content: center;
    text-align: center;
    color: var(--white);
}

.hero h1 {
    font-size: 3.5rem;
    margin-bottom: 20px;
}

.hero p {
    font-size: 1.25rem;
    margin-bottom: 30px;
}

/* --- Secção Serviços --- */
.servicos-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
    gap: 30px;
}

.servico-card {
    background-color: var(--white);
    padding: 30px;
    border-radius: 8px;
    box-shadow: 0 5px 20px rgba(0,0,0,0.05);
    transition: transform 0.3s ease, box-shadow 0.3s ease;
}

.servico-card:hover {
    transform: translateY(-10px);
    box-shadow: 0 10px 25px rgba(0,0,0,0.1);
}

.servico-icon {
    font-size: 2.5rem;
    color: var(--primary-color);
    margin-bottom: 15px;
}

.servico-card h3 {
    color: var(--dark-blue);
    margin-bottom: 10px;
}

/* --- Formulário de Recrutamento --- */
.recrutamento-form {
    max-width: 700px;
    margin: 0 auto;
    background: var(--white);
    padding: 30px;
    border-radius: 8px;
    box-shadow: 0 5px 20px rgba(0,0,0,0.05);
}

.form-group {
    margin-bottom: 20px;
}

.form-group label {
    display: block;
    margin-bottom: 8px;
    font-weight: 600;
    color: var(--dark-blue);
}

.form-group input[type="text"],
.form-group input[type="tel"],
.form-group input[type="email"],
.form-group textarea,
.form-group input[type="file"] {
    width: 100%;
    padding: 12px;
    border: 1px solid #ccc;
    border-radius: 5px;
    font-family: var(--font-family);
}

.form-group input[type="file"] {
    padding: 8px;
}

.form-group textarea {
    resize: vertical;
}

#form-mensagem {
    margin-bottom: 20px;
    padding: 15px;
    border-radius: 5px;
    display: none; /* Escondido por defeito */
    font-weight: 500;
}

#form-mensagem.success {
    background-color: #e6f7f2;
    color: #00704e;
    border: 1px solid #00a0dc;
    display: block;
}

#form-mensagem.error {
    background-color: #fdeaea;
    color: #d93025;
    border: 1px solid #d93025;
    display: block;
}


/* --- Rodapé --- */

.footer {
    background-color: var(--dark-blue);
    color: #a0b4c8;
    text-align: center;
    padding: 40px 20px;
    margin-top: 40px;
}

.footer p {
    margin-bottom: 10px;
}

.fade-in-section {
    opacity: 0;
    transform: translateY(30px);
    transition: opacity 0.6s ease-out, transform 0.6s ease-out;
}

.fade-in-section.visible {
    opacity: 1;
    transform: translateY(0);
}

/* --- Responsividade --- */
@media (max-width: 768px) {
    .navbar .container {
        flex-direction: column;
        height: auto;
        padding: 20px;
    }

    .navbar nav ul {
        flex-direction: column;
        margin-top: 20px;
        width: 100%;
        text-align: center;
    }

    .navbar nav li {
        margin: 10px 0;
    }

    .hero h1 {
        font-size: 2.5rem;
    }
}

.project-authorship {
    margin-top: 30px;
    padding-top: 20px;
    border-top: 1px solid #3d5a76; /* Linha separadora subtil */
    font-size: 0.9rem;
    color: #8c9aab; /* Tom ligeiramente mais esbatido */
}

.project-authorship p {
    margin-bottom: 5px; /* Espaçamento mais apertado para o bloco */
}

.project-authorship strong {
    color: #a0b4c8; /* Cor original do texto do footer para ênfase */
}

.project-authorship a {
    color: var(--primary-color); /* Link com a cor primária do site */
    text-decoration: none;
    font-weight: 600;
}

.project-authorship a:hover {
    text-decoration: underline;
}
EOF

# 3.4. Criar ficheiro main.js
cat > /var/www/html/js/main.js << 'EOF'
// js/main.js

document.addEventListener('DOMContentLoaded', () => {

    /**
     * 1. Animação de Scroll (Fade-in)
     * Observa elementos com a classe .fade-in-section
     */
    const fadeElements = document.querySelectorAll('.fade-in-section');

    const observerOptions = {
        root: null, // viewport
        rootMargin: '0px',
        threshold: 0.1 // 10% do elemento visível
    };

    const observerCallback = (entries, observer) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.classList.add('visible');
                observer.unobserve(entry.target); // Para de observar após animar
            }
        });
    };

    const scrollObserver = new IntersectionObserver(observerCallback, observerOptions);

    fadeElements.forEach(el => scrollObserver.observe(el));


    /**
     * 2. Processamento do Formulário de Recrutamento (AJAX)
     */
    const form = document.getElementById('form-recrutamento');
    const formMessage = document.getElementById('form-mensagem');

    if (form) {
        form.addEventListener('submit', function(e) {
            e.preventDefault(); // Impede o envio tradicional

            const formData = new FormData(this);
            const submitButton = this.querySelector('button[type="submit"]');
            
            // Desativa o botão e mostra feedback
            submitButton.disabled = true;
            submitButton.textContent = 'A processar...';
            formMessage.className = '';
            formMessage.textContent = '';

            fetch('php/processar_candidatura.php', {
                method: 'POST',
                body: formData
            })
            .then(response => response.json())
            .then(data => {
                if (data.status === 'success') {
                    // Sucesso
                    formMessage.className = 'success';
                    formMessage.textContent = data.message;
                    form.reset(); // Limpa o formulário
                } else {
                    // Erro
                    formMessage.className = 'error';
                    // Usamos .textContent para prevenir XSS ao inserir a mensagem de erro
                    formMessage.textContent = data.message; 
                }
            })
            .catch(error => {
                // Erro de rede ou JSON mal formado
                console.error('Erro na submissão:', error);
                formMessage.className = 'error';
                formMessage.textContent = 'Erro de ligação. Tente novamente mais tarde.';
            })
            .finally(() => {
                // Reativa o botão
                submitButton.disabled = false;
                submitButton.textContent = 'Enviar Candidatura';
            });
        });
    }
});
EOF

# 3.5. Ficheiro config.php

cat > /var/www/html/php/config.php << 'EOF'
<?php
// php/config.php

/* Definições da Base de Dados */
define('DB_SERVER', 'localhost');
define('DB_USERNAME', 'clm_webapp'); // O utilizador criado no script SQL
define('DB_PASSWORD', 'app_pass'); // A password definida no script SQL
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
EOF

# 3.6. Criar ficheiro processar_candidatura.php
cat > /var/www/html/php/processar_candidatura.php << 'EOF'
<?php
// CORREÇÃO: Desativar display_errors para evitar JSON inválido
ini_set('display_errors', 0);
ini_set('log_errors', 1);
error_reporting(E_ALL);
// php/processar_candidatura.php

// Incluir a configuração da base de dados
require_once 'config.php';

// Definir o tipo de resposta como JSON
header('Content-Type: application/json');

// Resposta padrão
$response = [
    'status' => 'error',
    'message' => 'Ocorreu um erro desconhecido.'
];

// 1. Verificar se o método é POST
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    $response['message'] = 'Método não permitido.';
    echo json_encode($response);
    exit;
}

// 2. Definir variáveis e diretório de upload
// O caminho é relativo ao script PHP, por isso usamos '../'
$uploadDir = '../uploads/curriculos/';
$maxFileSize = 5 * 1024 * 1024; // 5 MB
$allowedTypes = [
    'pdf' => 'application/pdf',
    'doc' => 'application/msword',
    'docx' => 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
];

// 3. Sanitizar e Validar Inputs de Texto
$nome_completo = trim($_POST['nome_completo'] ?? '');
$telemovel = trim($_POST['telemovel'] ?? '');
$email = trim($_POST['email'] ?? '');
$info_adicional = trim($_POST['info_adicional'] ?? '');

if (empty($nome_completo) || empty($telemovel) || empty($email)) {
    $response['message'] = 'Por favor, preencha todos os campos obrigatórios.';
    echo json_encode($response);
    exit;
}

if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    $response['message'] = 'Formato de email inválido.';
    echo json_encode($response);
    exit;
}

// Validar telemóvel (exemplo simples: + e números, 9 a 15 dígitos)
if (!preg_match('/^(\+)?[\d\s]{9,15}$/', $telemovel)) {
    $response['message'] = 'Formato de número de telemóvel inválido.';
    echo json_encode($response);
    exit;
}


// 4. Validação e Processamento do Upload do CV
if (!isset($_FILES['cv']) || $_FILES['cv']['error'] !== UPLOAD_ERR_OK) {
    $response['message'] = 'Erro no upload do CV. Código: ' . $_FILES['cv']['error'];
    echo json_encode($response);
    exit;
}

// 4.1. Validar Tamanho
if ($_FILES['cv']['size'] > $maxFileSize) {
    $response['message'] = 'Ficheiro demasiado grande. O limite é 5MB.';
    echo json_encode($response);
    exit;
}

// 4.2. Validar Tipo e Extensão (Medida de segurança crucial)
$fileInfo = new finfo(FILEINFO_MIME_TYPE);
$fileMimeType = $fileInfo->file($_FILES['cv']['tmp_name']);
$fileExt = strtolower(pathinfo($_FILES['cv']['name'], PATHINFO_EXTENSION));

if (!array_key_exists($fileExt, $allowedTypes) || !in_array($fileMimeType, $allowedTypes)) {
    $response['message'] = 'Tipo de ficheiro não permitido. Apenas PDF, DOC e DOCX.';
    echo json_encode($response);
    exit;
}

// 4.3. Criar nome de ficheiro seguro e único
// Isso previne directory traversal e colisões de nomes.
$safeFileName = preg_replace("/[^a-zA-Z0-9._-]/", "", basename($_FILES['cv']['name']));
$uniqueFileName = uniqid() . '_' . $safeFileName;
$targetPath = $uploadDir . $uniqueFileName;

// 4.4. Mover o ficheiro
if (!move_uploaded_file($_FILES['cv']['tmp_name'], $targetPath)) {
    $response['message'] = 'Falha ao mover o ficheiro para o diretório final.';
    echo json_encode($response);
    exit;
}

// 5. Inserir na Base de Dados (com Prepared Statements)
// O $targetPath é o caminho *relativo ao root do site* ou absoluto do servidor
// Vamos guardar o caminho relativo ao script para consistência
$dbPath = 'uploads/curriculos/' . $uniqueFileName;

$sql = "INSERT INTO candidaturas (nome_completo, telemovel, email, caminho_cv, info_adicional) VALUES (?, ?, ?, ?, ?)";

if ($stmt = $mysqli->prepare($sql)) {
    // "sssss" = 5 variáveis do tipo string
    $stmt->bind_param("sssss", $nome_completo, $telemovel, $email, $dbPath, $info_adicional);

    if ($stmt->execute()) {
        $response['status'] = 'success';
        $response['message'] = 'Candidatura enviada com sucesso! Entraremos em contacto em breve.';
    } else {
        $response['message'] = 'Erro ao guardar a candidatura na base de dados.';
        // Em produção, registar $stmt->error num log, não o expor ao user
    }
    
    $stmt->close();
} else {
    $response['message'] = 'Erro ao preparar a query para a base de dados.';
    // Em produção, registar $mysqli->error num log
}

// 6. Fechar conexão e enviar resposta
$mysqli->close();
echo json_encode($response);

?>
EOF

# 3.7. Ficheiro schema.sql
cat > /var/www/html/sql/schema.sql << 'EOF'
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
CREATE USER IF NOT EXISTS 'clm_webapp'@'localhost' IDENTIFIED BY 'app_pass';

-- Conceder permissões apenas para esta base de dados
GRANT SELECT, INSERT, UPDATE, DELETE ON `clm-recrutamento`.* TO 'clm_webapp'@'localhost';

-- Aplicar as alterações
FLUSH PRIVILEGES;
EOF

# 3.8. Ficheiro .htaccess para uploads
cat > /var/www/html/uploads/curriculos/.htaccess << 'EOF'
# /var/www/html/uploads/curriculos/.htaccess

# 1. Impedir a listagem do conteúdo do diretório
Options -Indexes

# 2. Negar todo o acesso web (HTTP) a este diretório
# Esta é a medida mais segura.
# Os ficheiros SÓ serão acessíveis via FTP (para o recrutador)
# ou pelo sistema de ficheiros (para a aplicação).
Require all denied
EOF
echo "Ficheiros do website implementados."


echo "--- [FASE 4/10] CONFIGURANDO SERVIÇOS (MARIADB, PHP, APACHE) ---"

# 4.1. Iniciar e Proteger MariaDB
echo "Iniciando e protegendo o MariaDB..."
systemctl enable --now mariadb
echo "A definir a password root do MariaDB..."
mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$ROOT_DB_PASS';"

# Password está definida, criar o .my.cnf
echo "Criando ficheiro .my.cnf para acesso root seguro..."
cat > /root/.my.cnf << EOF
[client]
user=root
password=$ROOT_DB_PASS
EOF
chmod 600 /root/.my.cnf
echo "Ficheiro de credenciais MariaDB criado."
echo "Aplicando regras de segurança ao MariaDB..."
mysql -e "DELETE FROM mysql.user WHERE User='';"
mysql -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
mysql -e "DROP DATABASE IF EXISTS test;"
mysql -e "FLUSH PRIVILEGES;"

echo "Base de dados MariaDB protegida."

# 4.2. Importar Schema da Aplicação
echo "Importando schema da base de dados 'clm-recrutamento'..."
# Este comando agora também usará o /root/.my.cnf
mysql < /var/www/html/sql/schema.sql
echo "Schema importado."

# 4.3. Tuning MariaDB
echo "Aplicando otimizações ao MariaDB..."
cat > /etc/my.cnf.d/99-clm-tuning.cnf << 'EOF'
[mysqld]
# 1. Ajuste para 60% da RAM total (assumindo ~3.5GB RAM)
innodb_buffer_pool_size = 2100M
# 2. Tamanho do ficheiro de log
innodb_log_file_size = 256M
# 3. Máximo de conexões
max_connections = 100
EOF
systemctl restart mariadb
echo "MariaDB otimizado."

# 4.4. Tuning PHP
echo "Aplicando otimizações ao PHP..."
sed -i "s/^memory_limit = .*/memory_limit = 256M/" /etc/php.ini
sed -i "s/^post_max_size = .*/post_max_size = 25M/" /etc/php.ini
sed -i "s/^upload_max_filesize = .*/upload_max_filesize = 20M/" /etc/php.ini
sed -i "s/^;date.timezone =.*/date.timezone = \"Europe\/Lisbon\"/" /etc/php.ini
systemctl enable --now php-fpm
systemctl restart php-fpm
echo "PHP otimizado."

# 4.5. Tuning Apache
echo "Aplicando otimizações ao Apache..."
# 00-tuning.conf para KeepAlive e mod_deflate
cat > /etc/httpd/conf.d/00-tuning.conf << 'EOF'
# /etc/httpd/conf.d/00-tuning.conf

# 1. KeepAlive (Permite que um cliente faça múltiplos pedidos na mesma ligação)
KeepAlive On
MaxKeepAliveRequests 100
KeepAliveTimeout 5

# 2. Tempo (em segundos) que o servidor espera por pedidos ou envio de dados.
Timeout 30

# 3. mod_deflate (Comprime ficheiros de texto como HTML, CSS, JS antes de os enviar)
<IfModule mod_deflate.c>
    # Ativa a compressão para estes tipos de ficheiros
    AddOutputFilterByType DEFLATE text/html text/plain text/xml text/css text/javascript
    AddOutputFilterByType DEFLATE application/javascript application/x-javascript application/json
</IfModule>
EOF

# Ajustar MaxRequestWorkers (antigo MaxClients)
sed -i "s/MaxRequestWorkers .*/MaxRequestWorkers 150/" /etc/httpd/conf.modules.d/00-mpm.conf

# Ativar Apache
systemctl enable --now httpd
echo "Apache otimizado e iniciado."

echo "--- [FASE 5/10] CONFIGURANDO VSFTPD (FTP SEGURO) ---"

# 5.1. Criar utilizador FTP
echo "Criando utilizador FTP '$FTP_USER'..."
groupadd www-ftp-share
useradd -m -d /var/www/html/uploads/curriculos -s /sbin/nologin -g www-ftp-share $FTP_USER
echo "$FTP_PASS" | passwd --stdin $FTP_USER
echo "Utilizador FTP criado."

# 5.2. Adicionar utilizador 'apache' ao grupo partilhado
usermod -a -G www-ftp-share apache

# 5.3. Configurar permissões do diretório de upload
chown -R apache:www-ftp-share /var/www/html/uploads/curriculos
chmod -R 775 /var/www/html/uploads/curriculos
chmod g+s /var/www/html/uploads/curriculos # Novos ficheiros herdam o grupo
echo "Permissões de upload configuradas."

# 5.4. Configurar vsftpd.conf
cat > /etc/vsftpd/vsftpd.conf << 'EOF'
anonymous_enable=NO
local_enable=YES
write_enable=YES
local_umask=022
dirmessage_enable=YES
xferlog_enable=YES
connect_from_port_20=YES
xferlog_std_format=YES
listen=NO
listen_ipv6=YES
pam_service_name=vsftpd

# --- Configuração do Chroot Jail ---
chroot_local_user=YES
allow_writeable_chroot=YES

# --- Lista de utilizadores permitidos ---
userlist_enable=YES
userlist_file=/etc/vsftpd/user_list
userlist_deny=NO
EOF

# 5.5. Adicionar utilizador à lista de permissões
echo "$FTP_USER" > /etc/vsftpd/user_list

# 5.6. Iniciar VSFTPD
systemctl enable --now vsftpd
echo "Servidor VSFTPD configurado e iniciado."


echo "--- [FASE 6/10] CONFIGURANDO SSH SEGURO ---"
echo "Configurando SSH na porta $SSH_PORT..."
# 6.1. Fazer backup da configuração original
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

# 6.2. Aplicar configurações de segurança
sed -i -E "s/^#?Port 22/Port $SSH_PORT/" /etc/ssh/sshd_config
sed -i -E "s/^#?PermitRootLogin .*/PermitRootLogin no/" /etc/ssh/sshd_config
sed -i -E "s/^#?LoginGraceTime .*/LoginGraceTime 1m/" /etc/ssh/sshd_config
sed -i -E "s/^#?PermitEmptyPasswords .*/PermitEmptyPasswords no/" /etc/ssh/sshd_config
sed -i -E "s/^#?Protocol .*/Protocol 2/" /etc/ssh/sshd_config
sed -i -E "s/^#?LogLevel .*/LogLevel VERBOSE/" /etc/ssh/sshd_config

# 6.3. Adicionar utilizadores permitidos
sed -i "/^AllowUsers .*/d" /etc/ssh/sshd_config
echo "AllowUsers $ADMIN_USERS" >> /etc/ssh/sshd_config

systemctl restart sshd
echo "Servidor SSH configurado e reiniciado na porta $SSH_PORT."

# 6.4. Configurar Sudoers
echo "Configurando permissões sudo..."
# Descomentar a inclusão do diretório sudoers.d
sed -i 's/^#includedir \/etc\/sudoers.d/includedir \/etc\/sudoers.d/' /etc/sudoers
# Criar ficheiro de permissões para os admins
cat > /etc/sudoers.d/clm-admins << EOF
manuel  ALL=(ALL)       ALL
cleber  ALL=(ALL)       ALL
luis    ALL=(ALL)       ALL
admin   ALL=(ALL)       ALL
EOF
chmod 440 /etc/sudoers.d/clm-admins
echo "Sudoers configurado."


echo "--- [FASE 7/10] CONFIGURANDO FIREWALL (firewalld) & SELINUX ---"
# 7.1. Configurar Firewalld
echo "Configurando Firewalld..."
firewall-cmd --permanent --add-service=ssh
firewall-cmd --permanent --add-service=http
firewall-cmd --permanent --add-service=https
firewall-cmd --permanent --add-service=ftp
firewall-cmd --reload
echo "Firewall configurado."

# 7.2. Configurar SELinux
echo "Aplicando políticas SELinux..."
# Permitir FTP
setsebool -P ftpd_full_access 1
# Permitir que Apache/PHP escreva em /uploads
semanage fcontext -a -t httpd_sys_rw_content_t "/var/www/html/uploads(/.*)?"
restorecon -Rv /var/www/html/uploads
# Permitir que Apache se conecte à Base de Dados (necessário para o PHP)
setsebool -P httpd_can_network_connect_db 1
# Permitir que Apache se conecte à rede (necessário para o proxy FCGI)
setsebool -P httpd_can_network_connect 1
echo "Políticas SELinux aplicadas."


echo "--- [FASE 8/10] CONFIGURANDO SSL E WAF (CERTBOT & MODSECURITY) ---"
echo "Configurando SSL com Certbot..."

# 8.1. Criar VirtualHost temporário para o Certbot
echo "Criando VirtualHost temporário na porta 80 para validação do Certbot..."
cat > /etc/httpd/conf.d/lamp-clm.duckdns.org.conf << EOF
<VirtualHost *:80>
    ServerName $DOMAIN_NAME
    DocumentRoot /var/www/html
    
    # Logs
    ErrorLog /var/log/httpd/lamp-clm-error.log
    CustomLog /var/log/httpd/lamp-clm-access.log combined
</VirtualHost>
EOF

# Reiniciar o Apache para carregar o novo VirtualHost
systemctl restart httpd
echo "VirtualHost da porta 80 criado."

# 8.2. Obter certificado Let's Encrypt (modo não-interativo)
echo "A tentar obter certificado para $DOMAIN_NAME."
certbot --apache -d $DOMAIN_NAME --redirect --agree-tos -m $ADMIN_EMAIL_PARA_SSL --no-eff-email
echo "Certbot configurado."

# 8.3. Configurar ModSecurity (WAF)
echo "A descarregar e configurar o OWASP Core Rule Set (CRS)..."
# Descarregar regras do GitHub
git clone https://github.com/coreruleset/coreruleset.git /etc/httpd/modsecurity-crs
# Mover ficheiro de configuração de exemplo
mv /etc/httpd/modsecurity-crs/crs-setup.conf.example /etc/httpd/modsecurity-crs/crs-setup.conf

# Modificar o ficheiro de configuração do ModSecurity para carregar as regras
# Remove a linha antiga do OWASP3 e insere as novas
sed -i "/IncludeOptional \/etc\/httpd\/modsecurity.d\/rules\/OWASP3\/\*.conf/d" /etc/httpd/conf.d/mod_security.conf
sed -i "/IncludeOptional \/etc\/httpd\/modsecurity.d\/local_rules\/\*.conf/a \    \n    # Carregar configuração e regras do OWASP CRS descarregadas\n    Include /etc/httpd/modsecurity-crs/crs-setup.conf\n    Include /etc/httpd/modsecurity-crs/rules/*.conf\n" /etc/httpd/conf.d/mod_security.conf

systemctl restart httpd
echo "WAF (ModSecurity + OWASP CRS) ativado."

echo "--- [FASE 9/10] CONFIGURAR FAIL2BAN ---"
echo "Configurando Fail2ban..."

# 9.1. jail.local (Default)
cat > /etc/fail2ban/jail.local << 'EOF'
[DEFAULT]
ignoreip = 127.0.0.1/8 ::1
bantime = 1d
findtime = 5m
maxretry = 5
destemail = root@localhost
sender = root@lamp-clm
EOF

# 9.2. 00-firewalld.conf
cat > /etc/fail2ban/jail.d/00-firewalld.conf << 'EOF'
[DEFAULT]
banaction = firewallcmd-rich-rules
banaction_allports = firewallcmd-rich-rules
EOF

# 9.3. sshd.conf
cat > /etc/fail2ban/jail.d/sshd.conf << EOF
[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/secure
maxretry = 5
findtime = 5m
bantime = 1d
action = %(action_mw)s
EOF

# 9.4. Jails do Apache
cat > /etc/fail2ban/jail.d/apache-auth.conf << 'EOF'
[apache-auth]
enabled = true
port = http,https
logpath = /var/log/httpd/error_log
bantime = 600
findtime = 3m
maxretry = 5
action = %(action_mw)s
EOF

cat > /etc/fail2ban/jail.d/apache-badbots.conf << 'EOF'
[apache-badbots]
enabled = true
port = http,https
logpath = /var/log/httpd/access_log
maxretry = 2
bantime = 1d
findtime = 10m
EOF

cat > /etc/fail2ban/jail.d/apache-noscript.conf << 'EOF'
[apache-noscript]
enabled = true
port = http,https
filter = apache-noscript
logpath = /var/log/httpd/error_log
maxretry = 3
findtime = 5m
bantime = 1d
EOF

cat > /etc/fail2ban/jail.d/apache-overflows.conf << 'EOF'
[apache-overflows]
enabled = true
port = http,https
filter = apache-overflows
logpath = /var/log/httpd/error_log
maxretry = 2
findtime = 5m
bantime = 1d
EOF

cat > /etc/fail2ban/jail.d/apache-nohome.conf << 'EOF'
[apache-nohome]
enabled = true
port = http,https
filter = apache-nohome
logpath = /var/log/httpd/error_log
maxretry = 2
findtime = 5m
bantime = 1d
EOF

cat > /etc/fail2ban/jail.d/apache-botsearch.conf << 'EOF'
[apache-botsearch]
enabled = true
port = http,https
filter = apache-botsearch
logpath = /var/log/httpd/access_log
maxretry = 2
findtime = 10m
bantime = 2d
EOF

cat > /etc/fail2ban/jail.d/apache-shellshock.conf << 'EOF'
[apache-shellshock]
enabled = true
port = http,https
filter = apache-shellshock
logpath = /var/log/httpd/access_log
maxretry = 1
findtime = 5m
bantime = 1w
EOF

cat > /etc/fail2ban/jail.d/apache-fakegooglebot.conf << 'EOF'
[apache-fakegooglebot]
enabled = true
port = http,https
filter = apache-fakegooglebot
logpath = /var/log/httpd/access_log
maxretry = 1
findtime = 10m
bantime = 2d
EOF

cat > /etc/fail2ban/jail.d/php-url-fopen.conf << 'EOF'
[php-url-fopen]
enabled = true
port = http,https
filter = php-url-fopen
logpath = /var/log/httpd/access_log
maxretry = 2
findtime = 5m
bantime = 1d
EOF

cat > /etc/fail2ban/jail.d/apache-dos.conf << 'EOF'
[apache-dos]
enabled = true
port = http,https
filter = apache-dos
logpath = /var/log/httpd/access_log
maxretry = 300
findtime = 5m
bantime = 1h
EOF

# 9.5. Iniciar Fail2ban
systemctl enable --now fail2ban
echo "Fail2ban configurado e iniciado."

echo "--- [FASE 10/10] CONFIGURANDO AUTOMATIZAÇÃO (CRON & DUCKDNS) ---"

# 10.1. Configurar DuckDNS
echo "Configurando DuckDNS..."
mkdir -p /root/duckdns
cat > /root/duckdns/duck.sh << 'EOF'
echo url="https://www.duckdns.org/update?domains=lamp-clm&token=209bd416-dd9b-49be-8f83-d93d5d6868ea&ip=" | curl -k -o /root/duckdns/duck.log -K -
EOF
chmod 700 /root/duckdns/duck.sh
/root/duckdns/duck.sh # Executar uma vez para atualizar o IP
echo "DuckDNS configurado."

# 10.2. Configurar Script de Auto-Update
echo "Configurando script de auto-update..."
cat > /usr/local/bin/auto-update.sh << 'EOF'
#!/bin/bash
echo "------- Atualização iniciada em $(date) -------" >> /var/log/auto-update.log
dnf -y update >> /var/log/auto-update.log 2>&1
echo "------- Atualização finalizada em $(date) -------" >> /var/log/auto-update.log
EOF
chmod +x /usr/local/bin/auto-update.sh

# 10.3. Configurar Script de Backup
echo "Configurando script de backup..."
mkdir -p /var/backups/{clm_web,clm_database,logs}
cat > /usr/local/sbin/backup_clm.sh << 'EOF'
#!/bin/bash

# === DEFINIÇÕES ===
BACKUP_WEB_DIR="/var/backups/clm_web"
BACKUP_DB_DIR="/var/backups/clm_database"
LOG_FILE="/var/backups/logs/backup_clm.log"
SOURCE_WEB_DIR="/var/www/html"
DB_NAME="clm-recrutamento"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
RETENTION_DAYS=7

# === FUNÇÃO DE LOG ===
log_msg() {
  echo "$(date +"%Y-%m-%d %H:%M:%S") - $1" | sudo tee -a $LOG_FILE
}

# === INÍCIO DO SCRIPT ===
log_msg "--- [INÍCIO] Backup Diário CLM Solutions ---"

# 1. BACKUP DO WEBSITE (TAR.GZ)
log_msg "A fazer backup dos ficheiros web de $SOURCE_WEB_DIR..."
BACKUP_WEB_FILE="$BACKUP_WEB_DIR/clm_web_$TIMESTAMP.tar.gz"
sudo tar -czpf "$BACKUP_WEB_FILE" -C /var www/html
if [ $? -eq 0 ]; then
  log_msg "Backup Web concluído com SUCESSO: $BACKUP_WEB_FILE"
else
  log_msg "ERRO ao fazer backup dos ficheiros web."
fi

# 2. BACKUP DA BASE DE DADOS (MYSQLDUMP)
log_msg "A fazer backup da base de dados '$DB_NAME'..."
BACKUP_DB_FILE="$BACKUP_DB_DIR/${DB_NAME}_$TIMESTAMP.sql.gz"

# mysqldump usará automaticamente /root/.my.cnf para autenticação
sudo mysqldump --single-transaction $DB_NAME | gzip > "$BACKUP_DB_FILE"
if [ ${PIPESTATUS[0]} -eq 0 ]; then
  log_msg "Backup da Base de Dados concluído com SUCESSO: $BACKUP_DB_FILE"
else
  log_msg "ERRO ao fazer backup da base de dados."
fi

# 3. ROTAÇÃO (APAGAR BACKUPS ANTIGOS)
log_msg "A apagar backups com mais de $RETENTION_DAYS dias..."
sudo find $BACKUP_WEB_DIR -type f -name "*.tar.gz" -mtime +$RETENTION_DAYS -delete
log_msg "Rotação Web concluída."
sudo find $BACKUP_DB_DIR -type f -name "*.sql.gz" -mtime +$RETENTION_DAYS -delete
log_msg "Rotação da Base de Dados concluída."

log_msg "--- [FIM] Backup Diário Concluído ---"
echo "" | sudo tee -a $LOG_FILE
EOF
chmod +x /usr/local/sbin/backup_clm.sh
echo "Scripts de automação criados."

# 10.4. Instalar Cron Jobs
echo "Instalando cron jobs..."
(crontab -l 2>/dev/null; echo "*/5 * * * * /root/duckdns/duck.sh >/dev/null 2>&1") | crontab -
(crontab -l 2>/dev/null; echo "0 3 * * 1,3,5,7 /usr/local/bin/auto-update.sh") | crontab -
(crontab -l 2>/dev/null; echo "0 4 * * * /usr/local/sbin/backup_clm.sh") | crontab -
echo "Cron jobs instalados."

echo ""
echo "======================================================================"
echo "  INSTALAÇÃO CONCLUÍDA"
echo "======================================================================"
echo ""
echo "  Website disponível em: https://$DOMAIN_NAME"
echo "  Acesso SSH: ssh <utilizador>@$DOMAIN_NAME (porta 22)"
echo "  Acesso FTP: ftp://$DOMAIN_NAME (Utilizador: $FTP_USER)"
echo ""
echo "  REINICIAR O SERVIDOR para garantir que todas as alterações funcionam."
echo ""
echo "  Comando para reiniciar: reboot"
echo ""
