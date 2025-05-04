package ru.zadachok.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import ru.zadachok.model.Task;
import ru.zadachok.request.CreateTaskRequest;
import ru.zadachok.service.TaskService;

@RestController
@RequestMapping("/api/task")
@RequiredArgsConstructor
public class TaskController {

    private final TaskService taskService;

    @PostMapping("/create") // POST — создание новой задачи
    public ResponseEntity<Task> create(@RequestBody CreateTaskRequest request) {
        Task task = taskService.createTask(request);
        return ResponseEntity.ok(task);
    }
}
