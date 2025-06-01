package ru.zadachok.service;

import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import ru.zadachok.dto.AI.GenerationResponse;
import ru.zadachok.dto.AI.NotificationRequest;
import ru.zadachok.dto.AI.NotificationStatusResponse;
import ru.zadachok.model.Task;
import ru.zadachok.repository.TaskRepository;

import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

@Service
@RequiredArgsConstructor
public class NotificationAsyncService {
    private final TaskRepository taskRepository;
    private final RestTemplate restTemplate;
    private final Map<String, NotificationStatusResponse> statusStore = new ConcurrentHashMap<>();
    private final ExecutorService executor = Executors.newCachedThreadPool();

    @Value("${ai.service.url}")
    private String aiServiceUrl;

    public String startGeneration(int taskId) {
        String notificationId = "notif-" + UUID.randomUUID();

        statusStore.put(notificationId,
                new NotificationStatusResponse(
                        "PENDING",
                        notificationId,
                        Instant.now().plus(30, ChronoUnit.MINUTES).toString(),
                        "null"
                )
        );

        executor.submit(() -> {
            try {
                Task task = taskRepository.findById(taskId)
                        .orElseThrow(() -> new RuntimeException("Task not found"));

                GenerationResponse aiResponse = generateWithAI(task);

                statusStore.put(notificationId,
                        new NotificationStatusResponse(
                                "COMPLETED",
                                notificationId,
                                null,
                                aiResponse.getGeneratedText()
                        )
                );
            } catch (Exception e) {
                statusStore.put(notificationId,
                        new NotificationStatusResponse(
                                "FAILED",
                                notificationId,
                                null,
                                "Error: " + e.getMessage()
                        )
                );
            }
        });

        return notificationId;
    }

    private GenerationResponse generateWithAI(Task task) {
        try {
            // Тут надо подумать еще и в любом случае менять когда ИИ поднимем финально
            String url = aiServiceUrl + "/generate-notification";

            //Расчет оставшегося времени
            long hoursRemaining = task.getEndDate() != null
                    ? ChronoUnit.HOURS.between(
                    Instant.now(),
                    task.getEndDate().toInstant()
            )
                    : 0;

            //Формирование запроса
            NotificationRequest aiRequest = new NotificationRequest(
                    task.getDescription(),
                    task.getName(),
                    (int) hoursRemaining
            );

            //Настройка HTTP запроса
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            HttpEntity<NotificationRequest> requestEntity = new HttpEntity<>(aiRequest, headers);

            //Вызов AI-сервиса
            ResponseEntity<GenerationResponse> response = restTemplate.exchange(
                    url,
                    HttpMethod.POST,
                    requestEntity,
                    GenerationResponse.class
            );
            //Что-то такое мы должны получить в ответ
            //{
            //"generated_text": "Уведомление которое сгенерится",
            //      "status": "success"
            //}

            if (response.getStatusCode().is2xxSuccessful() && response.getBody() != null) {
                return response.getBody();
            } else {
                throw new RuntimeException("AI service error: " + response.getStatusCode());
            }

        } catch (Exception e) {
            throw new RuntimeException(
                    ("Не удалось сгенерировать уведомление для задачи '" + task.getName() +
                            "'. Ошибка: " + e.getMessage())
            );
        }
    }

    public NotificationStatusResponse getStatus(String notificationId) {
        return statusStore.getOrDefault(notificationId,
                new NotificationStatusResponse(
                        "NOT_FOUND",
                        notificationId,
                        null,
                        "null"
                )
        );
    }

    public Map<String, String> AIHealthCheck() {
        try {
            String url = aiServiceUrl + "/health";

            ResponseEntity<Map<String, String>> response = restTemplate.exchange(
                    url,
                    HttpMethod.GET,
                    null,
                    new ParameterizedTypeReference<Map<String, String>>() {}
            );

            if (response.getStatusCode().is2xxSuccessful() && response.getBody() != null) {
                return response.getBody(); // Возвращаем ответ как есть
            } else {
                return Map.of(
                        "status", "error",
                        "message", "AI service returned status: " + response.getStatusCode()
                );
            }
        } catch (Exception e) {
            return Map.of(
                    "status", "error",
                    "message", "Failed to connect to AI service: " + e.getMessage()
            );
        }
    }
}