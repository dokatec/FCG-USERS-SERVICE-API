# Estágio 1: Build da aplicação
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /app

# 1. Copiar o nuget.config para autenticar no GitHub Packages
# Certifique-se de que este arquivo está na raiz do seu repositório
COPY ["nuget.config", "./"]

# 2. Copiar os arquivos de projeto (CSProj) individualmente para aproveitar o Cache do Docker
COPY ["src/FCG.Users.API/FCG.Users.API.csproj", "src/FCG.Users.API/"]
COPY ["src/FCG.Users.Domain/FCG.Users.Domain.csproj", "src/FCG.Users.Domain/"]
COPY ["src/FCG.Users.Application/FCG.Users.Application.csproj", "src/FCG.Users.Application/"]
COPY ["src/FCG.Users.Infrastructure/FCG.Users.Infrastructure.csproj", "src/FCG.Users.Infrastructure/"]

# 3. Restore: O .NET agora vai baixar a FCG.Shared do seu GitHub Packages automaticamente
RUN dotnet restore "src/FCG.Users.API/FCG.Users.API.csproj"

# 4. Copiar o restante do código fonte e compilar
COPY . .
WORKDIR "/app/src/FCG.Users.API"
RUN dotnet build "FCG.Users.API.csproj" -c Release -o /app/build

# Estágio 2: Publicação
FROM build AS publish
RUN dotnet publish "FCG.Users.API.csproj" -c Release -o /app/publish /p:UseAppHost=false

# Estágio 3: Runtime (Imagem final leve)
FROM mcr.microsoft.com/dotnet/aspnet:9.0
WORKDIR /app
COPY --from=publish /app/publish .

EXPOSE 80
EXPOSE 443

ENTRYPOINT ["dotnet", "FCG.Users.API.dll"]