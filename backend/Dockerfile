FROM eclipse-temurin:17-jre-jammy

WORKDIR /app

# Установка curl для healthcheck
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# Копируем JAR-файл
COPY backend/target/zadachok-api.jar ./app.jar

# Копируем шаблон конфигурации (без секретов)
COPY backend/config/application.properties.template /app/config/

# Устанавливаем переменные окружения по умолчанию
ENV SPRING_PROFILES_ACTIVE=ci \
    SERVER_PORT=8081 \
    SPRING_CONFIG_LOCATION=file:/app/config/ \
    SPRING_DATASOURCE_URL=jdbc:postgresql://db:5432/zadachok_db \
    SPRING_DATASOURCE_USERNAME=zadachok

# Указываем, что контейнер слушает на порту 8081
EXPOSE 8081

# Команда запуска с подстановкой переменных окружения
ENTRYPOINT ["sh", "-c", "envsubst < /app/config/application.properties.template > /app/config/application.properties && java -jar app.jar --spring.config.location=file:/app/config/"]