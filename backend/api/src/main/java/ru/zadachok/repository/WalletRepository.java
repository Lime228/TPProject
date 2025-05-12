package ru.zadachok.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import ru.zadachok.model.Wallet;

public interface WalletRepository extends JpaRepository<Wallet, Integer> {

    void deleteByCustomerIdAndLobbyId(Integer customerId, Integer lobbyId);

    void deleteAllByLobbyId(Integer lobbyId);

}
