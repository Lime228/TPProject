package ru.zadachok.request;

import com.fasterxml.jackson.annotation.JsonProperty;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.*;

import java.time.LocalDate;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
@Schema(description = "Запрос на создание новой задачи")
public class CreateTaskRequest {
    @JsonProperty("name")
    @NotBlank
    @Schema(description = "Название задачи", example = "Помыть кота", requiredMode = Schema.RequiredMode.REQUIRED)
    private String name;

    @JsonProperty("reward")
    @NotNull
    @Schema(description = "Вознаграждение за выполнение", example = "500", requiredMode = Schema.RequiredMode.REQUIRED)
    private Integer reward;

    @JsonProperty("description")
    @Schema(description = "Подробное описание задачи", example = "Тщательно его помыть, с шампунем")
    private String description;

    @JsonProperty("startdate")
    @Schema(description = "Дата начала выполнения (YYYY-MM-DD)", example = "2023-06-01", format = "date")
    private LocalDate startDate;

    @JsonProperty("enddate")
    @Schema(description = "Выполнить до (YYYY-MM-DD)", example = "2023-06-15", format = "date")
    private LocalDate endDate;

    @JsonProperty("lobbyid")
    @NotNull
    @Schema(description = "ID связанного лобби", example = "3", requiredMode = Schema.RequiredMode.REQUIRED)
    private Integer lobbyId;

    @JsonProperty("customerid")
    @Schema(description = "ID исполнителя задачи (может быть null)", example = "5")
    private Integer customerId;
}
