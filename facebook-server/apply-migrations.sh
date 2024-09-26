#!/bin/bash

# Застосування міграцій
dotnet ef database update --configuration Release

# Виведення повідомлення про успішне завершення
echo "Migrations completed successfully!"
