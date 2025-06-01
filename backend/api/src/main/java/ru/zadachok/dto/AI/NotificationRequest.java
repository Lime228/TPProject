package ru.zadachok.dto.AI;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class NotificationRequest {
    @JsonProperty("task_description")
    private String taskDescription;
    @JsonProperty("task_name")
    private String taskName;
    @JsonProperty("hours_remaining")
    private int hoursRemaining;
}