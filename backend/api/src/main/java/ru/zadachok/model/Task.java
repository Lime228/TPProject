package ru.zadachok.model;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;
import java.sql.Timestamp;

@Entity
@Table(name = "\"Task\"", schema = "\"tp\"")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "Модель задачи")
public class Task {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "\"task_id\"")
    @Schema(description = "Уникальный идентификатор задачи", example = "1", accessMode = Schema.AccessMode.READ_ONLY)
    private Integer id;

    @Column(name = "\"task_name\"", length = 50)
    @Schema(description = "Название задачи", example = "Рефакторинг кода", maxLength = 50)
    private String name;

    @Column(name = "\"reward\"")
    @Schema(description = "Награда за выполнение", example = "500")
    private Integer reward;

    @Column(name = "\"description\"", length = 254)
    @Schema(description = "Описание задачи", example = "Необходимо отрефакторить модуль оплаты", maxLength = 254)
    private String description;

    @Column(name = "\"start_point\"")
    @Schema(description = "Дата и время начала задачи", example = "2023-06-01T10:00:00", format = "date-time")
    private Timestamp startDate;

    @Column(name = "\"end_point\"")
    @Schema(description = "Дата и время завершения задачи", example = "2023-06-15T18:00:00", format = "date-time")
    private Timestamp endDate;

    @Column(name = "\"task_state\"", nullable = false)
    @Schema(description = "Статус задачи (0 - неактивна, 1 - активна, 2 - выполнена)",
            example = "0",
            defaultValue = "0")
    private Integer isActive;

    @Column(name = "\"customer_id\"", nullable = false)
    @Schema(description = "ID владельца задачи", example = "5", requiredMode = Schema.RequiredMode.REQUIRED)
    private Integer customerId;
}
