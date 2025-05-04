package ru.zadachok.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.*;
import java.time.LocalDate;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "DTO для представления задачи",
        example = """
        {
            "id": 1,
            "name": "Помыть посуду",
            "reward": 5000,
            "description": "Вымыть вообще все в раковине (даже сковородку)",
            "startDate": "2023-06-01",
            "endDate": "2023-06-15",
            "isActive": true,
            "customerId": 42
        }""")
public class TaskDto {
    @Schema(description = "Уникальный ID задачи",
            example = "1",
            minimum = "1",
            requiredMode = Schema.RequiredMode.REQUIRED)
    private Integer id;

    @Schema(description = "Название задачи",
            example = "Помыть посуду",
            minLength = 3,
            maxLength = 100,
            requiredMode = Schema.RequiredMode.REQUIRED)
    private String name;

    @Schema(description = "Вознаграждение за выполнение в звёздочках",
            example = "5000",
            minimum = "0",
            requiredMode = Schema.RequiredMode.REQUIRED)
    private Integer reward;

    @Schema(description = "Подробное описание задачи",
            example = "Вымыть вообще все в раковине (даже сковородку)",
            maxLength = 1000,
            requiredMode = Schema.RequiredMode.NOT_REQUIRED)
    private String description;

    @Schema(description = "Дата начала выполнения задачи (в формате YYYY-MM-DD)",
            example = "2023-06-01",
            requiredMode = Schema.RequiredMode.REQUIRED)
    private LocalDate startDate;

    @Schema(description = "Планируемая дата до которой нужно завершить задачу (в формате YYYY-MM-DD)",
            example = "2023-06-15",
            requiredMode = Schema.RequiredMode.NOT_REQUIRED)
    private LocalDate endDate;

    @Schema(description = "Флаг выполнения задачи (true - выполнена false - в процессе)",
            example = "true",
            requiredMode = Schema.RequiredMode.REQUIRED)
    private Boolean isActive;

    @Schema(description = "ID исполнителя",
            example = "42",
            minimum = "1",
            requiredMode = Schema.RequiredMode.REQUIRED)
    private Integer customerId;
}