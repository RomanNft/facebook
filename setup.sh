#!/bin/bash

# Оновлення та встановлення необхідних пакетів
sudo apt-get update
sudo apt-get upgrade -y

# Встановлення Docker
sudo apt-get remove -y docker docker-engine docker.io containerd runc
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common

# Додавання GPG ключа та Docker репозиторію
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Оновлення та встановлення Docker
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# Встановлення Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Запуск та автозапуск Docker
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER

# Повідомлення про перезайняття
echo "Для застосування змін вам потрібно вийти та знову зайти."

# Встановлення .NET SDK
sudo apt-get install -y apt-transport-https
sudo apt-get update
sudo apt-get install -y dotnet-sdk-8.0

# Встановлення PostgreSQL клієнта
sudo apt-get install -y postgresql-client

# Встановлення dotnet-ef
dotnet tool install --global dotnet-ef
export PATH="$PATH:/root/.dotnet/tools"

# Виведення шляху для перевірки
echo "Поточний PATH: $PATH"

# Налаштування та запуск сервісів через Docker Compose
cd facebook-server/
chmod +x wait-for-postgres.sh
cd ..

# Запуск Docker Compose з побудовою сервісів
docker-compose up --build
