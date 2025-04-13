package model;

public class TaskManager {
    private int taskLobbyId;
    private int lobbyId;
    private int taskId;

    public TaskManager(int taskLobbyId, int lobbyId, int taskId) {
        this.taskLobbyId = taskLobbyId;
        this.lobbyId = lobbyId;
        this.taskId = taskId;
    }

    public TaskManager(int lobbyId, int taskId) {
        this.lobbyId = lobbyId;
        this.taskId = taskId;
    }

    // Геттеры и сеттеры
    public int getTaskLobbyId() {
        return taskLobbyId;
    }

    public int getLobbyId() {
        return lobbyId;
    }

    public int getTaskId() {
        return taskId;
    }

    public void setLobbyId(int lobbyId) {
        this.lobbyId = lobbyId;
    }

    public void setTaskId(int taskId) {
        this.taskId = taskId;
    }
}
