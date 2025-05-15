package ru.zadachok.request;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

@Data
@Schema(description = "Запрос на удаление задачи")
public class DeleteTaskRequest {

    @Schema(description = "ID задачи для удаления", example = "42", requiredMode = Schema.RequiredMode.REQUIRED)
    private Integer taskId;
}
