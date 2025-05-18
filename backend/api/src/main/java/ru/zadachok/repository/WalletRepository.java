package ru.zadachok.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import ru.zadachok.model.Wallet;

import java.util.Optional;

public interface WalletRepository extends JpaRepository<Wallet, Integer> {

    void deleteByCustomerIdAndLobbyId(Integer customerId, Integer lobbyId);

    void deleteAllByLobbyId(Integer lobbyId);

    void deleteAllByCustomerId(Integer customerId);

    Optional<Wallet> findByCustomerId(Integer customerId);
}
