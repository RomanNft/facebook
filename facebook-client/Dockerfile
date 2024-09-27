# Використовуємо Node.js як базовий образ
FROM node:16 AS build

# Встановлюємо робочий каталог
WORKDIR /app

# Копіюємо файли package.json та package-lock.json
COPY package*.json ./

# Встановлюємо залежності
RUN npm install
# Копіюємо всі інші файли
COPY . .

# Виконуємо збірку
RUN npm run build

# Використовуємо Nginx для запуску статичних файлів
FROM nginx:alpine

# Копіюємо файли з папки збірки у Nginx
COPY --from=build /app/dist /usr/share/nginx/html

# Копіюємо конфігураційний файл Nginx
#COPY nginx.conf /etc/nginx/conf.d/default.conf

# Відкриваємо порт 80
EXPOSE 80
