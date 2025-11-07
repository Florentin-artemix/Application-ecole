FROM postgres:16-alpine
ENV POSTGRES_USER=postgres \
    POSTGRES_PASSWORD=2025 \
    POSTGRES_DB=Ecole

# Scripts d'initialisation optionnels (SQL/SH) à placer dans ce dossier
COPY ./initdb/ /docker-entrypoint-initdb.d/

EXPOSE 5432
