package ru.zadachok.model;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "\"wallet\"", schema = "\"tp\"")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "Модель кошелька пользователя")
public class Wallet {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "\"wallet_id\"")
    @Schema(description = "Уникальный идентификатор кошелька", example = "1", accessMode = Schema.AccessMode.READ_ONLY)
    private Integer id;

    @Column(name = "\"customer_id\"", nullable = false)
    @Schema(description = "ID владельца кошелька", example = "123")
    private Integer customerId;

    @Column(name = "\"lobby_id\"", nullable = false)
    @Schema(description = "ID лобби, к которому привязан кошелек", example = "456")
    private Integer lobbyId;

    @Column(name = "\"balance\"", nullable = false)
    @Schema(description = "Текущий баланс", example = "1000", defaultValue = "0")
    private Integer balance;
}
