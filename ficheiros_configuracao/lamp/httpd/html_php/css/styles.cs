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

/* --- Animações --- */
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