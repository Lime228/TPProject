package dao;

import connection.Database;
import model.TaskManager;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class TaskManagerDAO {

    public void create(TaskManager taskManager) {
        String sql = "INSERT INTO \"TP\".\"Task_Manager\" (\"Lobby_ID\", \"Task_ID\") VALUES (?, ?)";

        try (Connection conn = Database.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, taskManager.getLobbyId());
            stmt.setInt(2, taskManager.getTaskId());

            stmt.executeUpdate();
            System.out.println("Task_Manager добавлен.");

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public List<TaskManager> readAll() {
        List<TaskManager> taskManagers = new ArrayList<>();
        String sql = "SELECT * FROM \"TP\".\"Task_Manager\"";

        try (Connection conn = Database.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                TaskManager taskManager = new TaskManager(
                        rs.getInt("Task_Lobby_ID"),
                        rs.getInt("Lobby_ID"),
                        rs.getInt("Task_ID")
                );
                taskManagers.add(taskManager);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return taskManagers;
    }

    public void update(TaskManager taskManager) {
        String sql = "UPDATE \"TP\".\"Task_Manager\" SET \"Lobby_ID\" = ?, \"Task_ID\" = ? WHERE \"Task_Lobby_ID\" = ?";

        try (Connection conn = Database.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, taskManager.getLobbyId());
            stmt.setInt(2, taskManager.getTaskId());
            stmt.setInt(3, taskManager.getTaskLobbyId());

            stmt.executeUpdate();
            System.out.println("Task_Manager обновлён.");

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public void delete(int taskLobbyId) {
        String sql = "DELETE FROM \"TP\".\"Task_Manager\" WHERE \"Task_Lobby_ID\" = ?";

        try (Connection conn = Database.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, taskLobbyId);
            stmt.executeUpdate();
            System.out.println("Task_Manager удалён.");

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
