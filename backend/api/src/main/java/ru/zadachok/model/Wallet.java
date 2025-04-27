// model/Wallet.java
package ru.zadachok.model;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "\"Wallet\"", schema = "\"TP\"")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Wallet {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "\"Wallet_ID\"")
    private Integer id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "\"Customer_ID\"", nullable = false)
    private Customer customer;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "\"Lobby_ID\"", nullable = false)
    private Lobby lobby;

    @Column(name = "\"Balance\"")
    private Integer balance;

    // Бизнес-методы
    public void deposit(int amount) {
        if (amount <= 0) {
            throw new IllegalArgumentException("Deposit amount must be positive");
        }
        this.balance += amount;
    }

    public void withdraw(int amount) {
        if (amount <= 0) {
            throw new IllegalArgumentException("Withdrawal amount must be positive");
        }
        if (this.balance < amount) {
            throw new IllegalStateException("Insufficient funds");
        }
        this.balance -= amount;
    }

    public boolean hasSufficientFunds(int amount) {
        return this.balance >= amount;
    }
}