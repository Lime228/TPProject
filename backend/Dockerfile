# Стадия сборки
FROM maven:3.9.4-eclipse-temurin-17 AS builder
WORKDIR /app

# Копируем pom.xml и исходники
COPY ./api/pom.xml ./pom.xml
COPY ./api/src ./src

# Собираем без тестов
RUN mvn package -DskipTests

# Финальный рантайм-образ
FROM eclipse-temurin:17-jre
WORKDIR /app

# Копируем собранный JAR
COPY --from=builder /app/target/*.jar ./app.jar

EXPOSE 8090
ENTRYPOINT ["java", "-jar", "app.jar"]