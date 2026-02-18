FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src

# O segredo: Copiamos TUDO da FASE_3 para dentro do container de build
# Assim as referências relativas (../../FCG.Shared) funcionam igual no seu PC
COPY . .

# Fazemos o restore e build apontando o caminho completo a partir da raiz /src
RUN dotnet restore "FCG-Users-Service/src/FCG.Users.API/FCG.Users.API.csproj"
RUN dotnet build "FCG-Users-Service/src/FCG.Users.API/FCG.Users.API.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "FCG-Users-Service/src/FCG.Users.API/FCG.Users.API.csproj" -c Release -o /app/publish

FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "FCG.Users.API.dll"]