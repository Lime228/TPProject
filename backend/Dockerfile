FROM eclipse-temurin:17-jre
WORKDIR /app

# Копируем готовый JAR из CI
COPY target/*.jar app.jar

# Копируем конфиги (можно монтировать через volumes)
COPY config/ ./config/

EXPOSE 8090
ENTRYPOINT ["java", "-jar", "app.jar", "--spring.config.location=file:/app/config/"]