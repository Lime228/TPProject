package ru.zadachok.service;

import lombok.RequiredArgsConstructor;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import ru.zadachok.model.Customer;
import ru.zadachok.model.Lobby;
import ru.zadachok.model.Wallet;
import ru.zadachok.repository.CustomerRepository;
import ru.zadachok.repository.LobbyRepository;
import ru.zadachok.repository.WalletRepository;

@Service
@RequiredArgsConstructor
public class WalletService {

    private final WalletRepository walletRepository;
    private final CustomerRepository customerRepository;
    private final LobbyRepository lobbyRepository;

    @Async
    public void createWalletIfAbsentAsync(Integer customerId, Integer lobbyId) {
        try {
            boolean exists = walletRepository.existsByCustomerIdAndLobbyId(customerId, lobbyId);
            if (exists) return;

            Customer customer = customerRepository.findById(customerId)
                    .orElseThrow(); // можно логировать ошибку

            Lobby lobby = lobbyRepository.findById(lobbyId)
                    .orElseThrow(); // можно логировать ошибку

            Wallet wallet = Wallet.builder()
                    .customer(customer)
                    .lobby(lobby)
                    .balance(0)
                    .build();

            walletRepository.save(wallet);

        } catch (Exception e) {
            // Не роняем приложение, просто логируем
            System.err.println("Ошибка при создании кошелька: " + e.getMessage());
        }
    }
}
