# ----------------------------
# Build Stage
# ----------------------------
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy solution and project
COPY dotnet-hello-world.sln ./
COPY hello-world-api/hello-world-api.csproj ./hello-world-api/

# Restore dependencies
RUN dotnet restore

# Copy all source files
COPY . .

# Build and publish release version
RUN dotnet publish hello-world-api/hello-world-api.csproj -c Release -o /app/publish

# ----------------------------
# Runtime Stage
# ----------------------------
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime
WORKDIR /app

# Ensure ASP.NET listens on all network interfaces
ENV ASPNETCORE_URLS=http://0.0.0.0:80

# Copy the published files from the build stage
COPY --from=build /app/publish .

# Expose port 80 in container
EXPOSE 80

# Run the application
ENTRYPOINT ["dotnet", "hello-world-api.dll"]
