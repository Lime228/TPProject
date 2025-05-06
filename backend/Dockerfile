FROM eclipse-temurin:17-jre
WORKDIR /app
COPY target/*.jar app.jar
COPY config/ ./config/  
EXPOSE 8090
ENTRYPOINT ["java", "-jar", "app.jar", "--spring.config.location=file:/app/config/"]