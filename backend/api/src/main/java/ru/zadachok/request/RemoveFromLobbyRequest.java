package ru.zadachok.request;

import com.fasterxml.jackson.annotation.JsonProperty;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
@Schema(description = "Запрос на удаление участника из лобби")
public class RemoveFromLobbyRequest {
    @JsonProperty("lobbyid")
    @NotBlank
    @Schema(description = "ID лобби", example = "5", requiredMode = Schema.RequiredMode.REQUIRED)
    private int lobbyId;

    @JsonProperty("customerid")
    @NotBlank
    @Schema(description = "ID удаляемого участника", example = "10", requiredMode = Schema.RequiredMode.REQUIRED)
    private int customerId;
}
