package ru.zadachok.request;

import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class RemoveFromLobbyRequest {
    @JsonProperty("lobbyid")  // Входящее поле в JSON будет "lobbyid"
    @NotBlank
    private int lobbyId;
    @JsonProperty("customerid")  // Входящее поле в JSON будет "customerid"
    @NotBlank
    private int customerId;
}
