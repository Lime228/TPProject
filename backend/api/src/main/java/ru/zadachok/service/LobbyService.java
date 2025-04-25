// service/LobbyService.java
package ru.zadachok.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import ru.zadachok.request.CreateLobbyRequest;
import ru.zadachok.model.Lobby;
import ru.zadachok.model.Shop;
import ru.zadachok.repository.LobbyRepository;
import ru.zadachok.repository.ShopRepository;

@Service
@RequiredArgsConstructor
public class LobbyService {

    private final LobbyRepository lobbyRepository;
    private final ShopRepository shopRepository;

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
}
