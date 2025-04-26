# Builder stage
FROM eclipse-temurin:17-jdk-jammy as builder
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN ./mvnw clean package -DskipTests

# Final stage
FROM eclipse-temurin:17-jre-jammy
WORKDIR /app

# Установка необходимых утилит
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl gettext-base && \
    rm -rf /var/lib/apt/lists/*

# Копируем собранный JAR
COPY --from=builder /app/target/*.jar app.jar

# Создаем директорию config и копируем шаблон
RUN mkdir -p /app/config
COPY config/application.properties.template /app/config/

# Настройки по умолчанию
ENV SPRING_PROFILES_ACTIVE=default \
    SERVER_PORT=8081 \
    SERVER_ADDRESS=0.0.0.0

EXPOSE 8081

# Команда запуска
ENTRYPOINT ["sh", "-c", "envsubst < /app/config/application.properties.template > /app/config/application.properties && exec java -jar app.jar"]