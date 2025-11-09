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
