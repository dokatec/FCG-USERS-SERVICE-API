# Estágio de Build
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src

# 1. Copiar a Shared primeiro (Crucial para o compilador achar a referência)
# Mantemos a Shared na raiz para bater com o caminho relativo ../
COPY ["FCG.Shared/FCG.Shared.csproj", "FCG.Shared/"]

# 2. Copiar os projetos do Users-Service
COPY ["FCG-Users-Service/src/FCG.Users.API/FCG.Users.API.csproj", "FCG-Users-Service/src/FCG.Users.API/"]
COPY ["FCG-Users-Service/src/FCG.Users.Application/FCG.Users.Application.csproj", "FCG-Users-Service/src/FCG.Users.Application/"]
COPY ["FCG-Users-Service/src/FCG.Users.Domain/FCG.Users.Domain.csproj", "FCG-Users-Service/src/FCG.Users.Domain/"]
COPY ["FCG-Users-Service/src/FCG.Users.Infrastructure/FCG.Users.Infrastructure.csproj", "FCG-Users-Service/src/FCG.Users.Infrastructure/"]

# Restore usando o caminho da API
RUN dotnet restore "FCG-Users-Service/src/FCG.Users.API/FCG.Users.API.csproj"

# 3. Copiar o RESTANTE do código mantendo a estrutura de pastas
COPY . .

# Mudar para a pasta da API para o Build
WORKDIR "/FCG-Users-Service/src/FCG.Users.API"
RUN dotnet build "FCG-Users-Service/src/FCG.Users.API/FCG.Users.API.csproj" -c Release -o /app/build

# Publicação
FROM build AS publish
RUN dotnet publish "FCG.Users.API.csproj" -c Release -o /app/publish /p:UseAppHost=false

# Imagem Final
FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "FCG.Users.API.dll"]