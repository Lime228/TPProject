// request/AddInLobbyRequest.java
package ru.zadachok.request;

import com.fasterxml.jackson.annotation.JsonProperty;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
@Schema(description = "Запрос на добавление участника в лобби")
public class AddInLobbyRequest {
    @JsonProperty("code")
    @NotNull
    @Schema(description = "Код лобби", example = "ABC123", requiredMode = Schema.RequiredMode.REQUIRED)
    private String code;

    @JsonProperty("customerid")
    @NotNull
    @Schema(description = "ID добавляемого участника", example = "10", requiredMode = Schema.RequiredMode.REQUIRED)
    private Integer customerId;
}
