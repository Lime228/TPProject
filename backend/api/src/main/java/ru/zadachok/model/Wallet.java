// model/Wallet.java
package ru.zadachok.model;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "\"Wallet\"", schema = "\"TP\"")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "Модель кошелька пользователя")
public class Wallet {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "\"Wallet_ID\"")
    @Schema(description = "Уникальный идентификатор кошелька", example = "1", accessMode = Schema.AccessMode.READ_ONLY)
    private Integer id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "\"Customer_ID\"", nullable = false)
    @Schema(description = "Владелец кошелька")
    private Customer customer;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "\"Lobby_ID\"", nullable = false)
    @Schema(description = "Лобби, к которому привязан кошелек")
    private Lobby lobby;

    @Column(name = "\"Balance\"")
    @Schema(description = "Текущий баланс", example = "1000", defaultValue = "0")
    private Integer balance;

    @Schema(hidden = true)
    public void deposit(int amount) {
        if (amount <= 0) {
            throw new IllegalArgumentException("Deposit amount must be positive");
        }
        this.balance += amount;
    }

    @Schema(hidden = true)
    public void withdraw(int amount) {
        if (amount <= 0) {
            throw new IllegalArgumentException("Withdrawal amount must be positive");
        }
        if (this.balance < amount) {
            throw new IllegalStateException("Insufficient funds");
        }
        this.balance -= amount;
    }

    @Schema(hidden = true)
    public boolean hasSufficientFunds(int amount) {
        return this.balance >= amount;
    }
}