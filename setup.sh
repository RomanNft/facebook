#!/bin/bash

# Оновлення та встановлення необхідних пакетів
sudo apt-get update
sudo apt-get upgrade -y

# Перевірка наявності Docker та Docker Compose
if ! command -v docker &> /dev/null; then
    echo "Встановлення Docker..."
    sudo apt-get remove -y docker docker-engine docker.io containerd runc
    sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common

    # Додавання GPG ключа та Docker репозиторію
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    # Оновлення та встановлення Docker
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io
fi

if ! command -v docker-compose &> /dev/null; then
    echo "Встановлення Docker Compose..."
    # Встановлення останньої версії Docker Compose
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
fi

# Запуск та автозапуск Docker
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER

# Повідомлення про перезайняття
echo "Для застосування змін вам потрібно вийти та знову зайти або перезавантажити сесію."

# Встановлення .NET SDK
if ! command -v dotnet &> /dev/null; then
    echo "Встановлення .NET SDK..."
    sudo apt-get install -y apt-transport-https
    sudo apt-get update
    sudo apt-get install -y dotnet-sdk-8.0
fi

# Встановлення PostgreSQL клієнта
if ! command -v psql &> /dev/null; then
    echo "Встановлення PostgreSQL клієнта..."
    sudo apt-get install -y postgresql-client
fi

# Встановлення dotnet-ef
if ! command -v dotnet-ef &> /dev/null; then
    echo "Встановлення dotnet-ef..."
    dotnet tool install --global dotnet-ef
    echo 'export PATH="$PATH:$HOME/.dotnet/tools"' >> ~/.bashrc
    source ~/.bashrc
fi

# Виведення шляху для перевірки
echo "Поточний PATH: $PATH"

# Налаштування та запуск сервісів через Docker Compose
cd facebook-server/

# Надання прав для виконання скрипта wait-for-postgres.sh
if [ -f wait-for-postgres.sh ]; then
    chmod +x wait-for-postgres.sh
fi

# Повернення на рівень вище після виконання chmod
cd ..

# Запуск Docker Compose з побудовою сервісів
if [ -f ./docker-compose.yaml ]; then
    docker-compose up --build
else
    echo "Файл docker-compose.yaml не знайдено"
fi
