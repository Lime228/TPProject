FROM eclipse-temurin:17-jre
WORKDIR /app
COPY backend/target/zadachok-api.jar ./app.jar
EXPOSE 8081
ENTRYPOINT ["java", "-jar", "app.jar", "--spring.config.location=file:/app/config/"]