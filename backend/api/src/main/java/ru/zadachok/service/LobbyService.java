// service/LobbyService.java
package ru.zadachok.service;

import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import ru.zadachok.model.*;
import ru.zadachok.request.AddInLobbyRequest;
import ru.zadachok.request.CreateLobbyRequest;

import ru.zadachok.request.DeleteLobbyRequest;
import ru.zadachok.request.RemoveFromLobbyRequest;
import ru.zadachok.repository.*;

import java.util.*;

@Service
@RequiredArgsConstructor
public class LobbyService {

    private final LobbyRepository lobbyRepository;
    private final ShopRepository shopRepository;
    private final TaskRepository taskRepository;
    private final ProductRepository productRepository;
    private final WalletRepository walletRepository;
    private final CustomerRepository customerRepository;

    public Lobby createLobby(CreateLobbyRequest request) {
        Shop newShop = Shop.builder()
                .productId(new Integer[0])  // Пустой массив
                .build();
        Shop savedShop = shopRepository.save(newShop);

        Customer creator = customerRepository.findById(request.getCreatorId())
                .orElseThrow(() -> new IllegalArgumentException("Пользователь не найден"));

        creator.setAdmin(true);
        customerRepository.save(creator);

        String lobbyCode = generateUniqueCode();

        Lobby newLobby = Lobby.builder()
                .shopId(savedShop.getShopId())
                .customerId(new Integer[]{request.getCreatorId()})
                .taskId(new Integer[0])  // если изначально нет задач
                .code(lobbyCode)
                .build();

        return lobbyRepository.save(newLobby);
    }

    public Lobby getLobbyById(int id) {
        return lobbyRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Лобби с ID " + id + " не найдено"));
    }

    public Lobby getLobbyByCustomerId(int customerId) {
        List<Lobby> lobbies = lobbyRepository.findAll();
        return lobbies.stream()
                .filter(lobby -> lobby.getCustomerId() != null &&
                        Arrays.asList(lobby.getCustomerId()).contains(customerId))
                .min(Comparator.comparing(Lobby::getLobbyId))
                .orElseThrow(() -> new RuntimeException("Лобби для пользователя с ID " + customerId + " не найдено"));
    }

    public Lobby addCustomerToLobby(AddInLobbyRequest request) {
        if (!customerRepository.existsById(request.getCustomerId())) {
            throw new RuntimeException("Пользователь не найден");
        }

        Lobby lobby = lobbyRepository.findByCode(request.getCode())
                .orElseThrow(() -> new RuntimeException("Лобби с таким кодом не найдено"));

        Integer[] currentCustomers = lobby.getCustomerId();

        for (Integer id : currentCustomers) {
            if (id.equals(request.getCustomerId())) {
                throw new RuntimeException("Пользователь уже в лобби");
            }
        }

        Integer[] updatedCustomers = new Integer[currentCustomers.length + 1];
        System.arraycopy(currentCustomers, 0, updatedCustomers, 0, currentCustomers.length);
        updatedCustomers[currentCustomers.length] = request.getCustomerId();

        lobby.setCustomerId(updatedCustomers);
        Lobby savedLobby = lobbyRepository.save(lobby);

        // 💰 Создаём кошелёк для нового участника
        Wallet wallet = Wallet.builder()
                .customerId(request.getCustomerId())
                .lobbyId(lobby.getLobbyId())
                .balance(0)
                .build();
        walletRepository.save(wallet);

        return savedLobby;
    }

    @Transactional
    public Lobby removeCustomerFromLobby(RemoveFromLobbyRequest request) {
        Lobby lobby = lobbyRepository.findById(request.getLobbyId())
                .orElseThrow(() -> new IllegalArgumentException("Lobby not found"));

        Integer[] oldCustomerIds = lobby.getCustomerId();
        List<Integer> updatedList = new ArrayList<>(Arrays.asList(oldCustomerIds));

        boolean removed = updatedList.removeIf(id -> id.equals(request.getCustomerId()));
        if (!removed) {
            throw new IllegalArgumentException("Customer not in lobby");
        }

        lobby.setCustomerId(updatedList.toArray(new Integer[0]));
        walletRepository.deleteByCustomerIdAndLobbyId(request.getCustomerId(), request.getLobbyId());

        return lobbyRepository.save(lobby);
    }


    @Transactional
    public void deleteLobby(DeleteLobbyRequest request) {
        Lobby lobby = lobbyRepository.findById(request.getLobbyId())
                .orElseThrow(() -> new RuntimeException("Лобби не найдено"));

        // Сброс статуса admin для всех участников
        Integer[] customerIds = lobby.getCustomerId();
        if (customerIds != null) {
            for (Integer id : customerIds) {
                customerRepository.findById(id).ifPresent(customer -> {
                    customer.setAdmin(false);
                    customerRepository.save(customer);
                });
            }
        }

        // Удаление всех кошельков, привязанных к лобби
        walletRepository.deleteAllByLobbyId(request.getLobbyId());

        // Удаление всех задач
        Integer[] taskIds = lobby.getTaskId();
        if (taskIds != null) {
            for (Integer id : taskIds) {
                taskRepository.deleteById(id);
            }
        }

        // ВАЖНО: сначала удаляем lobby, чтобы освободить внешний ключ shop
        lobbyRepository.delete(lobby);

        // Теперь можно безопасно удалить магазин и его продукты
        Shop shop = shopRepository.findById(lobby.getShopId())
                .orElseThrow(() -> new RuntimeException("Магазин не найден"));

        Integer[] productIds = shop.getProductId();
        if (productIds != null) {
            for (Integer id : productIds) {
                productRepository.deleteById(id);
            }
        }

        shopRepository.delete(shop);
    }

    private String generateUniqueCode() {
        String characters = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
        Random random = new Random();
        String code;
        int attempts = 0;
        final int MAX_ATTEMPTS = 10;

        do {
            if (attempts++ >= MAX_ATTEMPTS) {
                throw new IllegalStateException("Не удалось сгенерировать уникальный код после " + MAX_ATTEMPTS + " попыток");
            }

            code = random.ints(6, 0, characters.length())
                    .mapToObj(characters::charAt)
                    .collect(StringBuilder::new, StringBuilder::append, StringBuilder::append)
                    .toString();
        } while (lobbyRepository.existsByCode(code));

        return code;
    }

}

