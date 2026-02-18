FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /app

# 1. Declara o argumento que receberá o token
ARG GH_TOKEN

# 2. Copia o nuget.config
COPY ["nuget.config", "./"]

# 3. Substitui o placeholder no nuget.config pelo token real antes do restore
# Isso garante que o dotnet restore tenha a senha correta
RUN sed -i "s/%GH_TOKEN%/$GH_TOKEN/g" nuget.config

# 4. Copia os arquivos de projeto
COPY ["src/FCG.Users.API/FCG.Users.API.csproj", "src/FCG.Users.API/"]
COPY ["src/FCG.Users.Domain/FCG.Users.Domain.csproj", "src/FCG.Users.Domain/"]
COPY ["src/FCG.Users.Application/FCG.Users.Application.csproj", "src/FCG.Users.Application/"]
COPY ["src/FCG.Users.Infrastructure/FCG.Users.Infrastructure.csproj", "src/FCG.Users.Infrastructure/"]

# 5. Agora o restore terá permissão para baixar a FCG.Shared
RUN dotnet restore "src/FCG.Users.API/FCG.Users.API.csproj"

# 6. Copiar o restante do código fonte e compilar
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