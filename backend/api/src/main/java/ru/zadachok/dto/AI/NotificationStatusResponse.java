package ru.zadachok.dto.AI;

import lombok.Data;

// NotificationStatusResponse.java
@Data
public class NotificationStatusResponse {
    private String status; // "PENDING", "COMPLETED", "FAILED"
    private String notificationId;
    private String estimatedReadyTime; // опционально
    private String generatedText; // только при status=COMPLETED

    public NotificationStatusResponse(String pending, String notificationId, String s, Object o) {
        this.status = pending;
        this.notificationId = notificationId;
        this.generatedText = o.toString();
        this.estimatedReadyTime = s;
    }
}