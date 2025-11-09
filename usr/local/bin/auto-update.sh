#!/bin/bash
echo "------- Atualização iniciada em $(date) -------" >> /var/log/auto-update.log
dnf -y update >> /var/log/auto-update.log 2>&1
echo "------- Atualização finalizada em $(date) -------" >> /var/log/auto-update.log
