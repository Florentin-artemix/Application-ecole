# Dockerfile racine: construit Backend (Spring Boot) + Frontend (Vite) et exécute les deux avec Nginx comme reverse-proxy

# ====== STAGE 1: Build Backend ======
FROM maven:3.9.9-eclipse-temurin-21 AS backend-builder
WORKDIR /build/backend
COPY Ecole-Backend/pom.xml ./
# Pré-chargement des dépendances pour tirer parti du cache Docker
RUN mvn -q -DskipTests dependency:go-offline
COPY Ecole-Backend/src ./src
RUN mvn -q clean package -DskipTests

# ====== STAGE 2: Build Frontend ======
FROM node:20-alpine AS frontend-builder
WORKDIR /build/frontend
COPY Ecole-front/package*.json ./
RUN npm ci --legacy-peer-deps
COPY Ecole-front/ .
# Paramétrer l'URL API pour le build de prod
ARG VITE_API_URL=/api
ENV VITE_API_URL=${VITE_API_URL}
RUN npm run build

# ====== STAGE 3: Runtime (JRE + Nginx) ======
FROM eclipse-temurin:21-jre-jammy

RUN apt-get update \
  && apt-get install -y --no-install-recommends nginx netcat-openbsd \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copie du jar backend
COPY --from=backend-builder /build/backend/target/*.jar /app/backend.jar

# Copie du build frontend dans le répertoire servi par Nginx
COPY --from=frontend-builder /build/frontend/dist /usr/share/nginx/html

# Nginx config et script de démarrage
# Sur l'image Ubuntu (apt), nginx charge /etc/nginx/sites-enabled/* par défaut
COPY nginx/app.conf /etc/nginx/sites-enabled/default
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Variables d'environnement par défaut (peuvent être surchargées au runtime)
ENV SPRING_DATASOURCE_URL=jdbc:postgresql://localhost:5432/Ecole \
    SPRING_DATASOURCE_USERNAME=postgres \
    SPRING_DATASOURCE_PASSWORD=2025 \
    SERVER_PORT=8080

EXPOSE 80 8080

CMD ["/start.sh"]
