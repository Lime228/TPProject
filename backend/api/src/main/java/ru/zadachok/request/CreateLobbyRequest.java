// dto/request/CreateLobbyRequest.java
package ru.zadachok.request;

import lombok.*;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CreateLobbyRequest {
    private Integer creatorId;  // ID пользователя, инициирующего создание
}
