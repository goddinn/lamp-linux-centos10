Projeto LAMP Stack (CLM Solutions) - GRSI0325
Este repositório contém o código-fonte e os ficheiros de configuração de servidor para um website corporativo full-stack. O projeto foi desenvolvido como parte do curso de Gestão de Redes e Sistemas Informáticos e serve como uma demonstração prática de implementação, otimização e hardening (reforço de segurança) de um servidor LAMP (Linux, Apache, MariaDB, PHP) em ambiente CentOS.
O website simula a presença online de uma consultora de cibersegurança, "CLM Solutions", e inclui um portal de recrutamento funcional com upload seguro de CVs e acesso FTP restrito para gestão.
________________________________________
👨‍💻 Autoria e Contexto Académico
Este projeto foi realizado por:
•	Autores: Manuel Godinho, Luís Vera e Cleber Monteiro
•	Turma: GRSI0325
•	Curso: Gestão de Redes e Sistemas Informáticos
•	Instituição: ATEC Palmela
•	Formador: Dário Quental
________________________________________
✨ Funcionalidades Principais
•	Frontend Profissional: Website estático (HTML5, CSS3, JS) com design moderno, responsivo e animado, focado na identidade corporativa.
•	Backend de Recrutamento: Um formulário de candidatura em PHP que valida dados, processa uploads de ficheiros (CVs) e os armazena de forma segura.
•	Gestão de Base de Dados: Armazenamento de todas as candidaturas numa base de dados MariaDB, utilizando prepared statements para prevenir SQL Injection.
•	Acesso de Gestão: Um servidor FTP (vsftpd) configurado com um utilizador "chroot-jailed" (restrito ao seu diretório) para permitir a recolha segura de CVs.
________________________________________
🚀 Arquitetura e Tecnologias
Este projeto não é apenas um website; é uma infraestrutura de servidor completa.
Componente	                Tecnologia	                Propósito
Sistema Operativo	CentOS    (RHEL-like)	                O SO base do servidor.
Servidor Web	              Apache (httpd)	            Servir o conteúdo do website e executar PHP-FPM.
Base de Dados	              MariaDB	                    Armazenamento persistente das candidaturas.
Backend	                    PHP-FPM	                    Processamento server-side do formulário.
Frontend	                  HTML5, CSS3, JavaScript	    A interface de utilizador e experiência do cliente.
Certificado SSL	            Let's Encrypt	              Garantia de tráfego seguro (HTTPS).
________________________________________
🛡️ Camada de Segurança (Hardening)
Um foco principal deste projeto foi a segurança. Implementámos múltiplas camadas de defesa para proteger o servidor e os dados dos utilizadores, simulando um ambiente de produção real.
1. Firewall de Aplicação (WAF)
•	ModSecurity (mod_security): Integrado diretamente no Apache para inspecionar todo o tráfego HTTP.
•	OWASP Core Rule Set (CRS): Utilização do conjunto de regras padrão da indústria para bloquear ativamente ameaças comuns como SQL Injection (SQLi), Cross-Site Scripting (XSS), e outras vulnerabilidades web.
2. Defesa contra Intrusão (IDS/IPS)
•	Fail2ban: Monitoriza ativamente os logs do SSH e do Apache.
•	Bloqueio Automático: Bane automaticamente endereços IP que falham tentativas de login (ex: 3 tentativas falhadas), mitigando ataques de força bruta.
3. Segurança a Nível de Servidor e Ficheiros
•	SELinux: Configurado em modo Enforcing, utilizando contextos de segurança corretos (httpd_sys_rw_content_t, httpd_can_network_connect_db) para garantir que mesmo um serviço comprometido (como o Apache) tenha acesso limitado ao sistema.
•	Propriedade e Permissões: Separação estrita de permissões entre o utilizador apache, o utilizador FTP recrutador_clm e o root.
•	Diretório de Uploads Seguro: O diretório uploads/curriculos é protegido por .htaccess para negar qualquer acesso web direto aos CVs submetidos, que só podem ser acedidos via FTP ou pelo sistema de ficheiros.
________________________________________
⚡ Otimização e Desempenho (Tuning)
Para garantir que o servidor responde rapidamente e utiliza os recursos de forma eficiente, foram aplicados os seguintes ajustes:
•	Apache:
o	KeepAlive On: Reduz a latência ao permitir que um cliente reutilize a mesma ligação TCP para múltiplos pedidos.
o	mod_deflate: Comprime o conteúdo (HTML, CSS, JS) antes de o enviar, reduzindo o tamanho da transferência.
o	MPM Tuning (MaxRequestWorkers): Ajustado para prevenir a exaustão de memória do servidor sob carga.
•	MariaDB:
o	innodb_buffer_pool_size: Otimizado para 60% da RAM do sistema, permitindo que a maioria das consultas seja servida diretamente da memória.
o	query_cache_size: Desativado (definido para 0), conforme as melhores práticas modernas, para evitar problemas de contenção.
•	PHP:
o	Valores de memory_limit, upload_max_filesize e post_max_size ajustados para suportar as necessidades da aplicação sem desperdiçar recursos.
________________________________________
🗃️ Automatização e Gestão
•	Backups Diários: Um script bash personalizado, agendado via cron, que corre diariamente às 3:00 da manhã.
o	Faz o dump completo da base de dados clm-recrutamento.
o	Cria um arquivo .tar.gz de todo o diretório /var/www/html.
o	Rotação Automática: Apaga automaticamente backups com mais de 7 dias para gerir o espaço em disco.
•	FTP Seguro: O vsftpd está configurado para prender (chroot) o utilizador de recrutamento apenas ao seu diretório, sem acesso shell (/sbin/nologin).
________________________________________
📂 Documentação do Servidor
Todos os ficheiros de configuração personalizados usados para construir este servidor (Apache, PHP, MariaDB, Fail2ban, ModSecurity, etc.) estão disponíveis no repositório para referência e replicação.
