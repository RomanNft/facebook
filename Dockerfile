# Використовуємо офіційний образ PostgreSQL
FROM postgres:latest

# Встановлюємо змінні середовища для PostgreSQL
ENV POSTGRES_DB=facebook
ENV POSTGRES_USER=postgres
ENV POSTGRES_PASSWORD=123456

# Відкриваємо порт PostgreSQL
EXPOSE 5432

