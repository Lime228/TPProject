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
        long codeAge = currentTime - storedCode.creationTime();
        if (codeAge > TimeUnit.HOURS.toMillis(1)) {
            resetCodes.remove(login); // Удаляем просроченный код
            return false;
        }

        return storedCode.code().equals(code);
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

    private record ResetCode(String code, long creationTime) {

    }
}