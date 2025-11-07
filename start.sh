#!/usr/bin/env bash
set -euo pipefail

echo "[start] Démarrage du backend Spring Boot..."
java -jar /app/backend.jar &
BACKEND_PID=$!

# Attendre que le backend écoute sur le port 8080 (simple backoff)
for i in {1..30}; do
  if nc -z 127.0.0.1 8080 2>/dev/null; then
    echo "[start] Backend prêt."
    break
  fi
  echo "[start] En attente du backend... ($i)"
  sleep 1
done

echo "[start] Lancement de Nginx au premier plan..."
nginx -g "daemon off;"
