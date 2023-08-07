FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS build-env
WORKDIR /app
 

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src
COPY . .
RUN dotnet restore "MiniProje.csproj"
COPY . .
RUN dotnet build "MiniProje.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "MiniProje.csproj" -c Release -o /app/publish /p:UseAppHost=false


FROM build-env AS final
WORKDIR /app
COPY --from=publish /app/publish .
EXPOSE 11130
ENV ASPNETCORE_URLS=http://*:11130
ENV ASPNETCORE_ENVIRONMENT=Development
#ENV APP_DATA_SIRKET="Ziraat Teknoloji"
#ENV APP_DATA_CALISAN="Zehra Çakır"
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y net-tools curl && rm -rf /var/lib/apt/lists/*


ENTRYPOINT ["dotnet", "MiniProje.dll"]	