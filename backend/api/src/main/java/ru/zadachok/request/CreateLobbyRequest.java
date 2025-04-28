// dto/request/CreateLobbyRequest.java
package ru.zadachok.request;

import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.validation.constraints.NotBlank;
import lombok.*;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CreateLobbyRequest {
    @JsonProperty("creatorID")  // Входящее поле в JSON будет "creatorID"
    @NotBlank
    private Integer creatorId;  // ID пользователя, инициирующего создание
}
