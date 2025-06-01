package ru.zadachok.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import ru.zadachok.dto.AI.NotificationStatusResponse;
import ru.zadachok.service.NotificationAsyncService;

@RestController
@RequestMapping("/api/notification")
@RequiredArgsConstructor
public class NotificationController {
    private final NotificationAsyncService notificationAsyncService;

    @PostMapping("/generate/{taskId}")
    public ResponseEntity<NotificationStatusResponse> generateNotificationAsync(
            @PathVariable int taskId) {

        String notificationId = notificationAsyncService.startGeneration(taskId);

        return ResponseEntity.accepted().body(
                new NotificationStatusResponse(
                        "PENDING",
                        notificationId,
                        "2023-06-15T15:00:00", // пример расчетного времени
                        "null"
                )
        );
    }

    @GetMapping("/status/{notificationId}")
    public ResponseEntity<NotificationStatusResponse> checkStatus(
            @PathVariable String notificationId) {

        NotificationStatusResponse status =
                notificationAsyncService.getStatus(notificationId);

        return ResponseEntity.ok(status);
    }

    @GetMapping("/status/healthcheck")
    public ResponseEntity<?> checkAI() {
        return ResponseEntity.ok(notificationAsyncService.AIHealthCheck());
    }
}