<?php
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