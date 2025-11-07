# Démarrage conteneurisé: Application-ecole

Ce guide explique comment construire et démarrer l'application complète (Backend Spring Boot + Frontend Vite + PostgreSQL) avec Docker.

## Architecture
- PostgreSQL (user: `postgres`, password: `2025`, db: `Ecole`)
- Backend Spring Boot (port interne 8080)
- Frontend statique servi par Nginx (port 80)
- Nginx reverse-proxy `/api` -> backend

Deux approches disponibles:
1) Image unique (Dockerfile racine) + `docker-compose.yml` (recommandé ici)
2) Services séparés (Dockerfile dans `Ecole-Backend/` et `Ecole-front/`) + un compose alternatif (optionnel)

## Prérequis
- Docker et Docker Compose installés

## Démarrer avec docker-compose (recommandé)

Depuis la racine du repo:

```bash
# 1) Construire les images (app + postgres personnalisé)
docker compose build

# 2) Lancer l'ensemble (db + app)
docker compose up -d

# 3) Vérifier les logs
docker compose logs -f app
```

Accès:
- Frontend: http://localhost/
- API via Nginx: http://localhost/api/...
- API directe (exposée): http://localhost:8080/api/...

La base PostgreSQL écoute sur `localhost:5432` (si vous avez déjà un Postgres local, changez le mapping de port dans `docker-compose.yml`).

## Variables d'environnement importantes
- `SPRING_DATASOURCE_URL` (par défaut: `jdbc:postgresql://db:5432/Ecole` en compose)
- `SPRING_DATASOURCE_USERNAME` (défaut: `postgres`)
- `SPRING_DATASOURCE_PASSWORD` (défaut: `2025`)
- `SERVER_PORT` (défaut: `8080`)
- Frontend: `VITE_API_URL` (en prod fixé à `/api`) pour router via Nginx.

## Développement local (sans Docker)
- Backend: démarrer Spring Boot localement; la config pointe par défaut sur `jdbc:postgresql://localhost:5432/Ecole` (user `postgres`, pass `2025`).
- Frontend: `npm run dev` et définir `VITE_API_URL=http://localhost:8080/api` (ou modifier `Ecole-front/.env.local`).

## Services séparés (optionnel)
- `Ecole-Backend/Dockerfile` construit et exécute le backend seul (port 8080). 
- `Ecole-front/Dockerfile` construit le frontend et le sert via Nginx (port 80). 

Vous pouvez créer un `docker-compose` alternatif si vous souhaitez séparer les services; je peux le fournir sur demande.

## Dépannage
- Backend ne démarre pas: vérifier les logs `docker compose logs -f app` et que `db` est `healthy`.
- Erreur CORS: utilisez l'URL `/api` côté frontend (Nginx proxy) ou autorisez l'origine si vous accédez directement au backend.
- Nom du jar: le Dockerfile copie `target/*.jar` en `backend.jar`; assurez-vous que le build Maven produit bien un jar.

## Arrêt
```bash
docker compose down
```

## Nettoyage complet (supprimer volume DB)
```bash
docker compose down -v
```

***

Ce dépôt inclut: 
- `Dockerfile` (racine)
- `docker-compose.yml`
- `start.sh`
- `nginx/app.conf`
- `Ecole-Backend/Dockerfile`
- `Ecole-front/Dockerfile`, `Ecole-front/nginx.conf`, `Ecole-front/.env.docker`
