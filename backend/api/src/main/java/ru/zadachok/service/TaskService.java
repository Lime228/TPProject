package ru.zadachok.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import ru.zadachok.model.Lobby;
import ru.zadachok.model.Shop;
import ru.zadachok.model.Task;
import ru.zadachok.repository.LobbyRepository;
import ru.zadachok.repository.TaskRepository;
import ru.zadachok.request.CreateTaskRequest;
import ru.zadachok.request.UpdateTaskRequest;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

@Service
@RequiredArgsConstructor
public class TaskService {

    private final TaskRepository taskRepository;
    private final LobbyRepository lobbyRepository;

    public Task createTask(CreateTaskRequest request) {
        Lobby lobby = lobbyRepository.findById(request.getLobbyId())
                .orElseThrow(() -> new RuntimeException("Лобби не найдено"));

        Task task = Task.builder()
                .name(request.getName())
                .reward(request.getReward())
                .description(request.getDescription())
                .startDate(request.getStartDate())
                .endDate(request.getEndDate())
                .isActive(0)
                .customerId(request.getCustomerId()) // может быть null
                .build();

        Task savedTask = taskRepository.save(task);

        // Привязка задачи к лобби (предполагается, что в Lobby есть поле taskId: Integer[])
        List<Integer> taskIds = new ArrayList<>();
        if (lobby.getTaskId() != null) {
            taskIds = new ArrayList<>(Arrays.asList(lobby.getTaskId()));
        }
        taskIds.add(savedTask.getId());
        lobby.setTaskId(taskIds.toArray(new Integer[0]));
        lobbyRepository.save(lobby);

        return savedTask;
    }

    public void deleteTask(Integer taskId) {
        Task task = taskRepository.findById(taskId)
                .orElseThrow(() -> new RuntimeException("Задача не найдена"));

        // Удаляем taskId из Lobby
        List<Lobby> lobbies = lobbyRepository.findAll(); // если у тебя 1 lobby per task, можно findByTaskId

        for (Lobby lobby : lobbies) {
            Integer[] taskIds = lobby.getTaskId();
            if (taskIds != null && Arrays.asList(taskIds).contains(taskId)) {
                List<Integer> updated = new ArrayList<>(Arrays.asList(taskIds));
                updated.remove(taskId);
                lobby.setTaskId(updated.toArray(new Integer[0]));
                lobbyRepository.save(lobby);
                break; // прерываем, если задача найдена (оптимизация)
            }
        }

        taskRepository.deleteById(taskId);
    }

    public Task updateTask(UpdateTaskRequest request) {
        Task task = taskRepository.findById(request.getTaskId())
                .orElseThrow(() -> new RuntimeException("Задача не найдена"));

        if (request.getName() != null) task.setName(request.getName());
        if (request.getDescription() != null) task.setDescription(request.getDescription());
        if (request.getStartDate() != null) task.setStartDate(request.getStartDate());
        if (request.getEndDate() != null) task.setEndDate(request.getEndDate());
        if (request.getReward() != null) task.setReward(request.getReward());
        if (request.getState() != null) task.setIsActive(request.getReward());
        if (request.getCustomerId() != null) task.setCustomerId(request.getCustomerId());

        return taskRepository.save(task);
    }


    public Task getTaskById(Integer taskId) {
        return taskRepository.findById(taskId)
                .orElseThrow(() -> new RuntimeException("Задание с ID " + taskId + " не найден"));
    }
}
