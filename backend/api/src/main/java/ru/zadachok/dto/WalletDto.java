package ru.zadachok.dto;

import lombok.*;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class WalletDto {
    private Integer id;
    private Integer customerId;
    private Integer lobbyId;
    private Integer balance;
}