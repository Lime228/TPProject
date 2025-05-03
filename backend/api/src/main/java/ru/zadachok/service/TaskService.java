package ru.zadachok.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import ru.zadachok.model.Lobby;
import ru.zadachok.model.Task;
import ru.zadachok.repository.LobbyRepository;
import ru.zadachok.repository.TaskRepository;
import ru.zadachok.request.CreateTaskRequest;

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
                .isActive(true)
                .customerId(request.getCustomerId)
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
}
