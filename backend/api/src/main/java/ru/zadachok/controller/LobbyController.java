// controller/LobbyController.java
package ru.zadachok.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import ru.zadachok.request.AddInLobbyRequest;
import ru.zadachok.request.CreateLobbyRequest;
import ru.zadachok.model.Lobby;
import ru.zadachok.request.DeleteLobbyRequest;
import ru.zadachok.request.RemoveFromLobbyRequest;
import ru.zadachok.service.LobbyService;

@RestController
@RequestMapping("/api/lobby")
@RequiredArgsConstructor
@Tag(name = "Lobby Management", description = "Управление лобби с пользователями")
public class LobbyController {

    private final LobbyService lobbyService;


    @Operation(
            summary = "Создать новое лобби",
            description = "Создает новое лобби с указанными параметрами"
    )
    @ApiResponses(value = {
            @ApiResponse(
                    responseCode = "200",
                    description = "Лобби успешно создано",
                    content = @Content(
                            mediaType = "application/json",
                            schema = @Schema(implementation = Lobby.class)
                    )
            ),
            @ApiResponse(
                    responseCode = "400",
                    description = "Неверные параметры запроса",
                    content = @Content
            )
    })
    @PostMapping("/create") // POST, потому что СОЗДАЁМ новую сущность
    public ResponseEntity<Lobby> createLobby(@RequestBody CreateLobbyRequest request) {
        Lobby createdLobby = lobbyService.createLobby(request);
        return ResponseEntity.ok(createdLobby);
    }

    @Operation(
            summary = "Добавить участника в лобби",
            description = "Добавляет указанного пользователя в существующее лобби"
    )
    @ApiResponses(value = {
            @ApiResponse(
                    responseCode = "200",
                    description = "Участник успешно добавлен",
                    content = @Content(
                            mediaType = "application/json",
                            schema = @Schema(implementation = Lobby.class)
                    )
            ),
            @ApiResponse(
                    responseCode = "400",
                    description = "Неверные параметры запроса",
                    content = @Content
            ),
            @ApiResponse(
                    responseCode = "404",
                    description = "Лобби или пользователь не найдены",
                    content = @Content
            )
    })
    @PatchMapping("/add") // PATCH, потому что МЕНЯЕМ СОСТАВ (не всё лобби, а частично)
    public ResponseEntity<Lobby> addCustomerToLobby(@RequestBody AddInLobbyRequest request) {
        Lobby updatedLobby = lobbyService.addCustomerToLobby(request);
        return ResponseEntity.ok(updatedLobby);
    }

    @Operation(
            summary = "Удалить участника из лобби",
            description = "Удаляет указанного пользователя из существующего лобби"
    )
    @ApiResponses(value = {
            @ApiResponse(
                    responseCode = "200",
                    description = "Участник успешно удален",
                    content = @Content(
                            mediaType = "application/json",
                            schema = @Schema(implementation = Lobby.class)
                    )
            ),
            @ApiResponse(
                    responseCode = "400",
                    description = "Неверные параметры запроса",
                    content = @Content
            ),
            @ApiResponse(
                    responseCode = "404",
                    description = "Лобби или пользователь не найдены",
                    content = @Content
            )
    })

    @PatchMapping("/remove")     // PATCH, потому что тоже МЕНЯЕМ состав (частично)
    public ResponseEntity<Lobby> removeCustomerFromLobby(@RequestBody RemoveFromLobbyRequest request) {
        Lobby updatedLobby = lobbyService.removeCustomerFromLobby(request);
        return ResponseEntity.ok(updatedLobby);
    }

    @Operation(
            summary = "Удалить лобби и связанные сущности",
            description = "Удаляет лобби, все его задачи и товары в магазине"
    )
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Лобби удалено успешно"),
            @ApiResponse(responseCode = "404", description = "Лобби не найдено", content = @Content)
    })

    @DeleteMapping("/delete")
    public ResponseEntity<String> deleteLobby(@RequestBody DeleteLobbyRequest request) {
        lobbyService.deleteLobby(request);
        return ResponseEntity.ok("Лобби успешно удалено");
    }

    @Operation(
            summary = "Получение лобби по ID"
    )
    @GetMapping("/{id}")
    public ResponseEntity<Lobby> getLobby(@PathVariable int id) {
        Lobby gettedLobby = lobbyService.getLobbyById(id);
        return ResponseEntity.ok(gettedLobby);
    }
}