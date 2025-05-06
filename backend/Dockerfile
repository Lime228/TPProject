# Многостадийная сборка
FROM eclipse-temurin:17-jdk as builder
WORKDIR /app
COPY . .
RUN ./mvnw package -DskipTests

FROM eclipse-temurin:17-jre
WORKDIR /app
COPY --from=builder /app/target/*.jar ./app.jar
COPY ./backend/config/ ./config/ 
EXPOSE 8090
ENTRYPOINT ["java", "-jar", "app.jar"]