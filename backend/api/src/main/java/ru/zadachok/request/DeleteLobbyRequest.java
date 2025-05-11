// request/DeleteLobbyRequest.java
package ru.zadachok.request;

import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.validation.constraints.NotNull;
import lombok.*;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DeleteLobbyRequest {
    @JsonProperty("lobbyid")
    @NotNull
    private Integer lobbyId;
}
