package model;

import java.sql.Date;

public class Task {
    private int taskId;
    private String taskName;
    private int reward;
    private String description;
    private Date startPoint;
    private Date endPoint;
    private int customerId;
    private boolean taskState;

    public Task(int taskId, String taskName, int reward, String description, Date startPoint, Date endPoint, int customerId, boolean taskState) {
        this.taskId = taskId;
        this.taskName = taskName;
        this.reward = reward;
        this.description = description;
        this.startPoint = startPoint;
        this.endPoint = endPoint;
        this.customerId = customerId;
        this.taskState = taskState;
    }

    public Task(String taskName, int reward, String description, Date startPoint, Date endPoint, int customerId, boolean taskState) {
        this.taskName = taskName;
        this.reward = reward;
        this.description = description;
        this.startPoint = startPoint;
        this.endPoint = endPoint;
        this.customerId = customerId;
        this.taskState = taskState;
    }

    // геттеры и сеттеры

    public int getTaskId() {
        return taskId;
    }

    public String getTaskName() {
        return taskName;
    }

    public int getReward() {
        return reward;
    }

    public String getDescription() {
        return description;
    }

    public Date getStartPoint() {
        return startPoint;
    }

    public Date getEndPoint() {
        return endPoint;
    }

    public int getCustomerId() {
        return customerId;
    }

    public boolean isTaskState() {
        return taskState;
    }

    public void setTaskName(String taskName) {
        this.taskName = taskName;
    }

    public void setReward(int reward) {
        this.reward = reward;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public void setStartPoint(Date startPoint) {
        this.startPoint = startPoint;
    }

    public void setEndPoint(Date endPoint) {
        this.endPoint = endPoint;
    }

    public void setCustomerId(int customerId) {
        this.customerId = customerId;
    }

    public void setTaskState(boolean taskState) {
        this.taskState = taskState;
    }
}
