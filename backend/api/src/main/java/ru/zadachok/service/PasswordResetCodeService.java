package ru.zadachok.service;

import org.springframework.stereotype.Service;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.TimeUnit;

@Service
public class PasswordResetCodeService {
    private final Map<String, ResetCode> resetCodes = new ConcurrentHashMap<>();

    // Генерация и сохранение кода
    public String generateAndStoreCode(String login) {
        String code = generateRandomCode();
        resetCodes.put(login, new ResetCode(code, System.currentTimeMillis()));
        return code;
    }

    // Проверка кода
    public boolean isValidCode(String login, String code) {
        ResetCode storedCode = resetCodes.get(login);
        if (storedCode == null) {
            return false;
        }

        // Проверяем срок действия (1 час)
        long currentTime = System.currentTimeMillis();
        long codeAge = currentTime - storedCode.getCreationTime();
        if (codeAge > TimeUnit.HOURS.toMillis(1)) {
            resetCodes.remove(login); // Удаляем просроченный код
            return false;
        }

        return storedCode.getCode().equals(code);
    }

    // Удаление кода после использования
    public void removeCode(String login) {
        resetCodes.remove(login);
    }

    // Генерация случайного 6-значного кода
    private String generateRandomCode() {
        return String.format("%06d", (int) (Math.random() * 1000000));
    }

    // Внутренний класс для хранения кода и времени создания
    private static class ResetCode {
        private final String code;
        private final long creationTime;

        public ResetCode(String code, long creationTime) {
            this.code = code;
            this.creationTime = creationTime;
        }

        public String getCode() {
            return code;
        }

        public long getCreationTime() {
            return creationTime;
        }
    }
}