# Используем многостадийную сборку
FROM eclipse-temurin:17-jdk-jammy as builder
WORKDIR /app
COPY backend/api/pom.xml .
COPY backend/api/src ./src
RUN ./mvnw clean package -DskipTests

# Финальный образ
FROM eclipse-temurin:17-jre-jammy
WORKDIR /app

# Установка curl и envsubst
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl gettext-base && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean

# Копируем собранный JAR из builder-стадии
COPY --from=builder /app/target/zadachok-api.jar ./app.jar

# Копируем шаблон конфигурации
COPY backend/config/application.properties.template /app/config/

# Безопасные переменные по умолчанию
ENV SPRING_PROFILES_ACTIVE=default \
    SERVER_PORT=8081 \
    SERVER_ADDRESS=0.0.0.0 \
    SPRING_CONFIG_LOCATION=file:/app/config/ \
    SPRING_DATASOURCE_URL=jdbc:postgresql://db:5432/zadachok_db \
    SPRING_DATASOURCE_USERNAME=zadachok \
    SPRING_LIQUIBASE_ENABLED=false

EXPOSE 8081

# Healthcheck для Docker
HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
    CMD curl -f http://localhost:8081/actuator/health || exit 1

# Запуск с обработкой переменных окружения
ENTRYPOINT ["sh", "-c", "mkdir -p /app/config && envsubst < /app/config/application.properties.template > /app/config/application.properties && exec java -jar app.jar"]