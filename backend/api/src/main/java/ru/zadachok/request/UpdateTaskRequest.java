package ru.zadachok.request;

import com.fasterxml.jackson.annotation.JsonProperty;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.time.LocalDate;

@Data
@Schema(description = "Запрос на обновление задачи")
public class UpdateTaskRequest {

    @JsonProperty("taskId")
    @Schema(description = "ID задачи", example = "5", requiredMode = Schema.RequiredMode.REQUIRED)
    private Integer taskId;

    @JsonProperty("name")
    @Schema(description = "Новое имя задачи", example = "Почистить комнату")
    private String name;

    @JsonProperty("description")
    @Schema(description = "Новое описание задачи", example = "Убраться перед приходом гостей")
    private String description;

    @JsonProperty("reward")
    @Schema(description = "Новое вознаграждение", example = "500")
    private Integer reward;

    @JsonProperty("startDate")
    @Schema(description = "Новая дата начала", example = "2025-05-15")
    private LocalDate startDate;

    @JsonProperty("endDate")
    @Schema(description = "Новая дата окончания", example = "2025-05-20")
    private LocalDate endDate;
}
