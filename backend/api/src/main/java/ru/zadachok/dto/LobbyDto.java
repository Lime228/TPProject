// dto/LobbyDto.java
package ru.zadachok.dto;

import lombok.*;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class LobbyDto {
    private Long lobbyId;
    private Integer shopId;
    private Integer[] taskId;
    private Integer[] customerId;
}
