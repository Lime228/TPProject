FROM eclipse-temurin:17-jre
WORKDIR /app

# Копируем только JAR без конфигов
COPY ./target/zadachok-api.jar ./app.jar

# Точка монтирования для конфигов будет создана через docker-compose
EXPOSE 8090

ENTRYPOINT ["java", "-jar", "app.jar", "--spring.config.location=file:/app/config/"]