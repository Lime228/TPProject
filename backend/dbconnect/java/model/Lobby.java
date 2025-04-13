package model;

public class Lobby {
    private int lobbyId;
    private Integer taskId;
    private int shopId;
    private int customerId;

    public Lobby(int lobbyId, Integer taskId, int shopId, int customerId) {
        this.lobbyId = lobbyId;
        this.taskId = taskId;
        this.shopId = shopId;
        this.customerId = customerId;
    }

    public Lobby(Integer taskId, int shopId, int customerId) {
        this.taskId = taskId;
        this.shopId = shopId;
        this.customerId = customerId;
    }

    // Геттеры и сеттеры
    public int getLobbyId() {
        return lobbyId;
    }

    public Integer getTaskId() {
        return taskId;
    }

    public int getShopId() {
        return shopId;
    }

    public int getCustomerId() {
        return customerId;
    }

    public void setTaskId(Integer taskId) {
        this.taskId = taskId;
    }

    public void setShopId(int shopId) {
        this.shopId = shopId;
    }

    public void setCustomerId(int customerId) {
        this.customerId = customerId;
    }
}
