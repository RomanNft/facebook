# Вивчення створення образів контейнерів .NET
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /source

# Копіюємо csproj і відновлюємо як окремі шари
COPY ["Facebook_Domain/Facebook_Domain.csproj", "Facebook_Domain/"]
COPY ["Facebook_Contracts/Facebook_Contracts.csproj", "Facebook_Contracts/"]
COPY ["Facebook_Infrastructure/Facebook_Infrastructure.csproj", "Facebook_Infrastructure/"]
COPY ["Facebook_Application/Facebook_Application.csproj", "Facebook_Application/"]
COPY ["Facebook_Api/Facebook_Api.csproj", "Facebook_Api/"]
RUN dotnet restore "Facebook_Api/Facebook_Api.csproj"

# Копіюємо все інше і будуємо додаток
COPY . .
WORKDIR /source/Facebook_Api
RUN dotnet publish -o /app

# Копіюємо скрипт wait-for-postgres.sh
COPY wait-for-postgres.sh /app/wait-for-postgres.sh
RUN chmod +x /app/wait-for-postgres.sh

# Остання стадія/образ
FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /app
COPY --from=build /app .
ENTRYPOINT ["dotnet", "Facebook_Api.dll"]
# Відкриваємо порт 
EXPOSE 5181
