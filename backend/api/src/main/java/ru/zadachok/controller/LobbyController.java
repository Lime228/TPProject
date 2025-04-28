// controller/LobbyController.java
package ru.zadachok.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import ru.zadachok.request.CreateLobbyRequest;
import ru.zadachok.model.Lobby;
import ru.zadachok.service.LobbyService;

@RestController
@RequestMapping("/api/lobby")
@RequiredArgsConstructor
public class LobbyController {

    private final LobbyService lobbyService;

    @PostMapping("/create")
    public ResponseEntity<Lobby> createLobby(@RequestBody CreateLobbyRequest request) {
        Lobby createdLobby = lobbyService.createLobby(request);
        return ResponseEntity.ok(createdLobby);
    }
}