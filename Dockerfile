# Estágio 1: Build da aplicação
FROM mcr.microsoft.com/dotnet/sdk:9.0-alpine AS build
WORKDIR /app

# Copia os arquivos de projeto e restaura as dependências
COPY ["src/FCG.Users.API/FCG.Users.API.csproj", "src/FCG.Users.API/"]
COPY ["src/FCG.Users.Domain/FCG.Users.Domain.csproj", "src/FCG.Users.Domain/"]
COPY ["src/FCG.Users.Application/FCG.Users.Application.csproj", "src/FCG.Users.Application/"]
COPY ["src/FCG.Users.Infrastructure/FCG.Users.Infrastructure.csproj", "src/FCG.Users.Infrastructure/"]

RUN dotnet restore "src/FCG.Users.API/FCG.Users.API.csproj"

# Copia o restante do código e compila
COPY . .
WORKDIR "/app/src/FCG.Users.API"
RUN dotnet build "FCG.Users.API.csproj" -c Release -o /app/build

# Estágio 2: Publicação
FROM build AS publish
RUN dotnet publish "FCG.Users.API.csproj" -c Release -o /app/publish /p:UseAppHost=false

# Estágio 3: Runtime (Imagem final leve)
FROM mcr.microsoft.com/dotnet/aspnet:9.0-alpine
WORKDIR /app
COPY --from=publish /app/publish .

# Exposição das portas
EXPOSE 80
EXPOSE 443

ENTRYPOINT ["dotnet", "FCG.Users.API.dll"]