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
import ru.zadachok.model.Shop;
import ru.zadachok.model.Task;
import ru.zadachok.request.CreateTaskRequest;
import ru.zadachok.request.DeleteTaskRequest;
import ru.zadachok.request.UpdateTaskRequest;
import ru.zadachok.service.TaskService;

@RestController
@RequestMapping("/api/task")
@RequiredArgsConstructor
@Tag(name = "Task Management", description = "Управление задачами")
public class TaskController {

    private final TaskService taskService;

    @Operation(
            summary = "Создать новую задачу",
            description = "Создает новую задачу с указанными параметрами"
    )
    @ApiResponses(value = {
            @ApiResponse(
                    responseCode = "200",
                    description = "Задача успешно создана",
                    content = @Content(
                            mediaType = "application/json",
                            schema = @Schema(implementation = Task.class)
                    )
            ),
            @ApiResponse(
                    responseCode = "400",
                    description = "Неверные параметры запроса",
                    content = @Content
            ),
            @ApiResponse(
                    responseCode = "401",
                    description = "Пользователь не авторизован",
                    content = @Content
            ),
            @ApiResponse(
                    responseCode = "403",
                    description = "Доступ запрещен",
                    content = @Content
            )
    })
    @PostMapping("/create") // POST — создание новой задачи
    public ResponseEntity<Task> create(@RequestBody CreateTaskRequest request) {
        Task task = taskService.createTask(request);
        return ResponseEntity.ok(task);
    }

    @Operation(
            summary = "Удалить задачу",
            description = "Удаляет задачу по её ID и убирает её из привязанного лобби"
    )
    @ApiResponses(value = {
            @ApiResponse(
                    responseCode = "200",
                    description = "Задача успешно удалена",
                    content = @Content(
                            mediaType = "application/json",
                            schema = @Schema(example = "Задача удалена")
                    )
            ),
            @ApiResponse(
                    responseCode = "404",
                    description = "Задача не найдена",
                    content = @Content
            )
    })
    @DeleteMapping("/delete")
    public ResponseEntity<String> deleteTask(@RequestBody DeleteTaskRequest request) {
        taskService.deleteTask(request.getTaskId());
        return ResponseEntity.ok("Задача удалена");
    }

    @Operation(
            summary = "Обновить задачу",
            description = "Обновляет существующую задачу по ID"
    )
    @ApiResponses(value = {
            @ApiResponse(
                    responseCode = "200",
                    description = "Задача успешно обновлена",
                    content = @Content(
                            mediaType = "application/json",
                            schema = @Schema(implementation = Task.class)
                    )
            ),
            @ApiResponse(
                    responseCode = "400",
                    description = "Неверные параметры запроса",
                    content = @Content
            ),
            @ApiResponse(
                    responseCode = "404",
                    description = "Задача не найдена",
                    content = @Content
            )
    })
    @PatchMapping("/update")
    public ResponseEntity<Task> updateTask(@RequestBody UpdateTaskRequest request) {
        Task updated = taskService.updateTask(request);
        return ResponseEntity.ok(updated);
    }

    @Operation(
            summary = "Получить задание по ID"
    )
    @ApiResponses(value = {
            @ApiResponse(
                    responseCode = "200",
                    description = "Задача успешно получена",
                    content = @Content(
                            mediaType = "application/json",
                            schema = @Schema(implementation = Task.class)
                    )
            ),
            @ApiResponse(
                    responseCode = "404",
                    description = "Задача не найдена",
                    content = @Content
            ),
            @ApiResponse(
                    responseCode = "400",
                    description = "Неверные параметры запроса",
                    content = @Content
            )})
    @GetMapping("/{id}")
    public ResponseEntity<Task> getTask(@PathVariable int id) {
        Task gettedTask = taskService.getTaskById(id);
        return ResponseEntity.ok(gettedTask);
    }
}
