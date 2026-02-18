FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src

# Copia as pastas inteiras para manter a estrutura de subpastas
# (Certifique-se de que os nomes batem com as pastas reais)
COPY FCG.Shared/ FCG.Shared/
COPY FCG-Users-Service/ FCG-Users-Service/

# Agora o restore e o build vão encontrar os caminhos ../../FCG.Shared
RUN dotnet restore "FCG-Users-Service/src/FCG.Users.API/FCG.Users.API.csproj"
RUN dotnet build "FCG-Users-Service/src/FCG.Users.API/FCG.Users.API.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "FCG-Users-Service/src/FCG.Users.API/FCG.Users.API.csproj" -c Release -o /app/publish

FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "FCG.Users.API.dll"]