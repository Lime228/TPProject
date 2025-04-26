# Builder stage
FROM eclipse-temurin:17-jdk-jammy as builder
WORKDIR /app

# Копируем Maven Wrapper и pom.xml
COPY ./api/mvnw .
COPY ./api/.mvn ./.mvn
COPY ./api/pom.xml .

# Скачиваем зависимости
RUN chmod +x mvnw && ./mvnw dependency:go-offline

# Копируем исходный код
COPY ./api/src ./src

# Собираем приложение
RUN ./mvnw clean package -DskipTests

# Final stage
FROM eclipse-temurin:17-jre-jammy
WORKDIR /app

# Установка утилит
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl gettext-base && \
    rm -rf /var/lib/apt/lists/*

# Копируем собранный JAR
COPY --from=builder /app/target/*.jar app.jar

# Копируем конфигурацию
COPY ./config/application.properties.template /app/config/

# Настройки по умолчанию
ENV SPRING_PROFILES_ACTIVE=default \
    SERVER_PORT=8081 \
    SERVER_ADDRESS=0.0.0.0

EXPOSE 8081

# Healthcheck
HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
    CMD curl -f http://localhost:8081/actuator/health || exit 1

# Запуск
ENTRYPOINT ["sh", "-c", "envsubst < /app/config/application.properties.template > /app/config/application.properties && exec java -jar app.jar"]