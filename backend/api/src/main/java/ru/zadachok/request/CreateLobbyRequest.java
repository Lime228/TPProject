// dto/request/CreateLobbyRequest.java
package ru.zadachok.request;

import com.fasterxml.jackson.annotation.JsonProperty;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import lombok.*;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "Запрос на создание нового лобби")
public class CreateLobbyRequest {
    @JsonProperty("creatorID")
    @NotBlank
    @Schema(description = "ID создателя лобби",
            example = "7",
            requiredMode = Schema.RequiredMode.REQUIRED)
    private Integer creatorId;
}
