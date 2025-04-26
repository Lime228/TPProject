# Builder stage
FROM eclipse-temurin:17-jdk-jammy as builder

WORKDIR /app

# Копируем только необходимые файлы для сборки
COPY backend/api/pom.xml .
COPY backend/api/src ./src

# Собираем приложение (Maven будет автоматически скачан)
RUN apt-get update && \
    apt-get install -y maven && \
    mvn clean package -DskipTests

# Final stage
FROM eclipse-temurin:17-jre-jammy
WORKDIR /app

# Копируем только собранный JAR
COPY --from=builder /app/target/*.jar app.jar

EXPOSE 8081

# Простой запуск (конфигурация через переменные окружения)
ENTRYPOINT ["java", "-jar", "app.jar"]