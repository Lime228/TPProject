// service/LobbyService.java
package ru.zadachok.service;

import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import ru.zadachok.model.Task;
import ru.zadachok.request.AddInLobbyRequest;
import ru.zadachok.request.CreateLobbyRequest;
import ru.zadachok.model.Lobby;
import ru.zadachok.model.Shop;

import ru.zadachok.request.DeleteLobbyRequest;
import ru.zadachok.request.RemoveFromLobbyRequest;
import ru.zadachok.repository.*;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

@Service
@RequiredArgsConstructor
public class LobbyService {

    private final LobbyRepository lobbyRepository;
    private final ShopRepository shopRepository;
    private final TaskRepository taskRepository;
    private final ProductRepository productRepository;

    public Lobby createLobby(CreateLobbyRequest request) {
        // 1. Создание пустого магазина
        Shop newShop = Shop.builder()
                .productId(new Integer[0])  // Пустой массив
                .build();
        Shop savedShop = shopRepository.save(newShop);

        // 2. Создание лобби с привязкой к новому магазину
        Lobby newLobby = Lobby.builder()
                .shopId(savedShop.getShopId())
                .customerId(new Integer[]{request.getCreatorId()})
                .taskId(new Integer[0])  // если изначально нет задач
                .build();

        return lobbyRepository.save(newLobby);
    }

    public Lobby addCustomerToLobby(AddInLobbyRequest request) {
        Lobby lobby = lobbyRepository.findById(request.getLobbyId())
                .orElseThrow(() -> new RuntimeException("Лобби не найдено"));

        Integer[] currentCustomers = lobby.getCustomerId();

        // Проверка на дубликат
        for (Integer id : currentCustomers) {
            if (id.equals(request.getCustomerId())) {
                throw new RuntimeException("Пользователь уже в лобби");
            }
        }

        // Добавление нового ID
        Integer[] updatedCustomers = new Integer[currentCustomers.length + 1];
        System.arraycopy(currentCustomers, 0, updatedCustomers, 0, currentCustomers.length);
        updatedCustomers[currentCustomers.length] = request.getCustomerId();

        lobby.setCustomerId(updatedCustomers);
        return lobbyRepository.save(lobby);
    }

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
        return lobbyRepository.save(lobby);
    }

    @Transactional
    public void deleteLobby(DeleteLobbyRequest request) {
        Lobby lobby = lobbyRepository.findById(request.getLobbyId())
                .orElseThrow(() -> new RuntimeException("Лобби не найдено"));

        Integer[] taskIds = lobby.getTaskId();
        if (taskIds != null && taskIds.length > 0) {
            for (Integer id : taskIds) {
                taskRepository.deleteById(id);
            }
        }

        Shop shop = shopRepository.findById(lobby.getShopId())
                .orElseThrow(() -> new RuntimeException("Магазин не найден"));

        Integer[] productIds = shop.getProductId();
        if (productIds != null && productIds.length > 0) {
            for (Integer id : productIds) {
                productRepository.deleteById(id);
            }
        }

        shopRepository.delete(shop);
        lobbyRepository.delete(lobby);
    }
}

