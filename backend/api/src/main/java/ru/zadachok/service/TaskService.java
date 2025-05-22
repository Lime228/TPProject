package ru.zadachok.service;

import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import ru.zadachok.model.Lobby;
import ru.zadachok.model.Task;
import ru.zadachok.model.Wallet;
import ru.zadachok.repository.LobbyRepository;
import ru.zadachok.repository.TaskRepository;
import ru.zadachok.repository.WalletRepository;
import ru.zadachok.request.CreateTaskRequest;
import ru.zadachok.request.UpdateTaskRequest;
import ru.zadachok.dto.AI.NotificationRequest;
import ru.zadachok.dto.AI.GenerationResponse;

import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class TaskService {

    @Value("${ai.service.url}")
    private String aiServiceUrl;

    private final RestTemplate restTemplate = new RestTemplate();    private final TaskRepository taskRepository;
    private final LobbyRepository lobbyRepository;
    private final WalletRepository walletRepository;

    public Task createTask(CreateTaskRequest request) {
        Lobby lobby = lobbyRepository.findById(request.getLobbyId())
                .orElseThrow(() -> new RuntimeException("Лобби не найдено"));

        // Проверка, что пользователь есть в лобби (если customerId указан)
        if (request.getCustomerId() != null && lobby.getCustomerId() != null) {
            boolean isUserInLobby = Arrays.stream(lobby.getCustomerId())
                    .anyMatch(id -> id.equals(request.getCustomerId()));

            if (!isUserInLobby) {
                throw new RuntimeException("Пользователь не найден в лобби");
            }
        }

        Task task = Task.builder()
                .name(request.getName())
                .reward(request.getReward())
                .description(request.getDescription())
                .startDate(convertToTimestamp(request.getStartDate()))
                .endDate(convertToTimestamp(request.getEndDate()))
                .isActive(0) // по умолчанию неактивная
                .customerId(request.getCustomerId())
//                .aiNotification(generateAiNotification(request)) // предварительная генерация уведомления
//                .notificationSent(false)
                .build();

        Task savedTask = taskRepository.save(task);

        updateLobbyTasks(lobby, savedTask.getId());

        return savedTask;
    }

    private Timestamp convertToTimestamp(LocalDate date) {
        return date != null ? Timestamp.valueOf(date.atStartOfDay()) : null;
    }

    private String generateAiNotification(Task task) {
        try {
            if (task.getEndDate() == null) {
                return "Дедлайн не установлен";
            }

            String url = aiServiceUrl + "/generate-notification";

            long hoursRemaining = ChronoUnit.HOURS.between(
                    LocalDateTime.now(),
                    task.getEndDate().toLocalDateTime()
            );

            NotificationRequest aiRequest = new NotificationRequest(
                    task.getDescription(),
                    task.getName(),
                    (int) hoursRemaining
            );

            GenerationResponse response = restTemplate.postForObject(
                    url,
                    aiRequest,
                    GenerationResponse.class
            );

            return response != null ? response.getGeneratedText() : "Не удалось сгенерировать уведомление";
        } catch (Exception e) {
            return "Уведомление будет сгенерировано позже. Ошибка: " + e.getMessage();
        }
    }

    private String generateAiNotification(CreateTaskRequest request) {
        try {
            if (request.getEndDate() == null) {
                return "Дедлайн не установлен";
            }

            String url = aiServiceUrl + "/generate-notification";

            long hoursRemaining = ChronoUnit.HOURS.between(
                    LocalDate.now().atStartOfDay(),
                    request.getEndDate().atStartOfDay()
            );

            NotificationRequest aiRequest = new NotificationRequest(
                    request.getDescription(),
                    request.getName(),
                    (int) hoursRemaining
            );

            GenerationResponse response = restTemplate.postForObject(
                    url,
                    aiRequest,
                    GenerationResponse.class
            );

            return response != null ? response.getGeneratedText() : "Не удалось сгенерировать уведомление";
        } catch (Exception e) {
            return "Уведомление будет сгенерировано позже";
        }
    }

    private void updateLobbyTasks(Lobby lobby, Integer taskId) {
        Integer[] currentTaskIds = lobby.getTaskId();
        Integer[] newTaskIds;

        if (currentTaskIds == null || currentTaskIds.length == 0) {
            newTaskIds = new Integer[]{taskId};
        } else {
            newTaskIds = Arrays.copyOf(currentTaskIds, currentTaskIds.length + 1);
            newTaskIds[currentTaskIds.length] = taskId;
        }

        lobby.setTaskId(newTaskIds);
        lobbyRepository.save(lobby);
    }

    public void deleteTask(Integer taskId) {
        Task task = taskRepository.findById(taskId)
                .orElseThrow(() -> new RuntimeException("Задача не найдена"));

        List<Lobby> lobbies = lobbyRepository.findAll();
        lobbies.forEach(lobby -> {
            if (lobby.getTaskId() != null && Arrays.asList(lobby.getTaskId()).contains(taskId)) {
                List<Integer> updatedTaskIds = new ArrayList<>(Arrays.asList(lobby.getTaskId()));
                updatedTaskIds.remove(taskId);
                lobby.setTaskId(updatedTaskIds.toArray(new Integer[0]));
                lobbyRepository.save(lobby);
            }
        });

        taskRepository.deleteById(taskId);
    }

    public Task updateTask(UpdateTaskRequest request) {
        Task task = taskRepository.findById(request.getTaskId())
                .orElseThrow(() -> new RuntimeException("Задача не найдена"));

        Integer oldState = task.getIsActive();

        if (request.getName() != null) task.setName(request.getName());
        if (request.getDescription() != null) task.setDescription(request.getDescription());
        if (request.getStartDate() != null) task.setStartDate(convertToTimestamp(request.getStartDate()));
        if (request.getEndDate() != null) task.setEndDate(convertToTimestamp(request.getEndDate()));
        if (request.getReward() != null) task.setReward(request.getReward());
        if (request.getState() != null) task.setIsActive(request.getState());
        if (request.getCustomerId() != null) task.setCustomerId(request.getCustomerId());

        handleTaskCompletion(oldState, request.getState(), task);


        return taskRepository.save(task);
    }

    private void handleTaskCompletion(Integer oldState, Integer newState, Task task) {
        if (oldState != null && oldState == 1 && newState != null && newState == 2) {
            Integer customerId = task.getCustomerId();
            if (customerId != null) {
                Wallet wallet = walletRepository.findByCustomerId(customerId)
                        .orElseThrow(() -> new RuntimeException("Кошелек не найден"));
                wallet.setBalance(wallet.getBalance() + task.getReward());
                walletRepository.save(wallet);
            }
        }
    }

//    @Scheduled(fixedRate = 60000)
//    public void checkDeadlineNotifications() {
//        LocalDateTime now = LocalDateTime.now();
//        LocalDateTime threeHoursLater = now.plusHours(3);
//
//        List<Task> tasks = taskRepository.findByEndDateBetweenAndIsActive(
//                Timestamp.valueOf(now),
//                Timestamp.valueOf(threeHoursLater),
//                1
//        );
//
//        tasks.stream()
//                .filter(task -> !task.isNotificationSent() && task.getAiNotification() != null)
//                .forEach(this::processNotification);
//    }
//
//    private void processNotification(Task task) {
//        System.out.println("Отправка уведомления для задачи: " + task.getName());
//        System.out.println("Текст: " + task.getAiNotification());
//
//        task.setNotificationSent(true);
//        taskRepository.save(task);
//    }

    public Task getTaskById(Integer taskId) {
        return taskRepository.findById(taskId)
                .orElseThrow(() -> new RuntimeException("Задача не найдена"));
    }

    public List<Task> getAllTasks() {
        return taskRepository.findAll();
    }
}