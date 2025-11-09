#!/bin/bash

# === DEFINIÇÕES ===

# Diretórios de Backup (onde tudo será guardado)
BACKUP_WEB_DIR="/var/backups/clm_web"
BACKUP_DB_DIR="/var/backups/clm_database"
LOG_FILE="/var/backups/logs/backup_clm.log"

# Diretório Web a ser "backupeado"
SOURCE_WEB_DIR="/var/www/html"

# Base de Dados a ser "backupeada"
DB_NAME="clm-recrutamento"

# Timestamp (formato para o nome do ficheiro)
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Definições de Rotação (guardar backups por 7 dias)
RETENTION_DAYS=7

# === FUNÇÃO DE LOG ===
# Esta função escreve no ficheiro de log
log_msg() {
  echo "$(date +"%Y-%m-%d %H:%M:%S") - $1" | sudo tee -a $LOG_FILE
}

# === INÍCIO DO SCRIPT ===
log_msg "--- [INÍCIO] Backup Diário CLM Solutions ---"

# 1. BACKUP DO WEBSITE (TAR.GZ)
log_msg "A fazer backup dos ficheiros web de $SOURCE_WEB_DIR..."
BACKUP_WEB_FILE="$BACKUP_WEB_DIR/clm_web_$TIMESTAMP.tar.gz"

# Criar o arquivo .tar.gz
# 'c' = criar, 'z' = gzip, 'f' = ficheiro, 'p' = preservar permissões
sudo tar -czpf "$BACKUP_WEB_FILE" -C /var www/html

if [ $? -eq 0 ]; then
  log_msg "Backup Web concluído com SUCESSO: $BACKUP_WEB_FILE"
else
  log_msg "ERRO ao fazer backup dos ficheiros web."
fi


# 2. BACKUP DA BASE DE DADOS (MYSQLDUMP)
log_msg "A fazer backup da base de dados '$DB_NAME'..."
BACKUP_DB_FILE="$BACKUP_DB_DIR/${DB_NAME}_$TIMESTAMP.sql.gz"

# Como o cron corre como 'root', ele usará a autenticação 'unix_socket' 
# para aceder ao MariaDB sem password.
# --single-transaction é vital para não bloquear tabelas InnoDB.
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
