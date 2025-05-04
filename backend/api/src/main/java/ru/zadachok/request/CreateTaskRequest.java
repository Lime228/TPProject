package ru.zadachok.request;

import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.*;

import java.time.LocalDate;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class CreateTaskRequest {
    @JsonProperty("name") // Название задачи
    @NotBlank
    private String name;
    @JsonProperty("reward") // Вознаграждение
    @NotNull
    private Integer reward;
    @JsonProperty("description") // Описание задачи
    private String description;
    @JsonProperty("startdate") // Дата начала
    private LocalDate startDate;
    @JsonProperty("enddate") // Дата окончания
    private LocalDate endDate;
    @JsonProperty("lobbyid") // ID лобби, к которому привязывается задача
    @NotNull
    private Integer lobbyId;
    @JsonProperty("customerid") // ID исполнителя задачи (будет null при создании)
    private Integer customerId;
}
