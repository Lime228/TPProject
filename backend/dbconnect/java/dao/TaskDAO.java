package dao;

import connection.Database;
import model.Task;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class TaskDAO {

    public void create(Task task) {
        String sql = "INSERT INTO \"TP\".\"Task\" (\"Task_name\", \"Reward\", \"Description\", \"Start_point\", \"End_point\", \"Customer_ID\", \"Task_state\") VALUES (?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = Database.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, task.getTaskName());
            stmt.setInt(2, task.getReward());
            stmt.setString(3, task.getDescription());
            stmt.setDate(4, task.getStartPoint());
            stmt.setDate(5, task.getEndPoint());
            stmt.setInt(6, task.getCustomerId());
            stmt.setBoolean(7, task.isTaskState());

            stmt.executeUpdate();
            System.out.println("Task добавлен.");

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public List<Task> readAll() {
        List<Task> tasks = new ArrayList<>();
        String sql = "SELECT * FROM \"TP\".\"Task\"";

        try (Connection conn = Database.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                Task task = new Task(
                        rs.getInt("Task_ID"),
                        rs.getString("Task_name"),
                        rs.getInt("Reward"),
                        rs.getString("Description"),
                        rs.getDate("Start_point"),
                        rs.getDate("End_point"),
                        rs.getInt("Customer_ID"),
                        rs.getBoolean("Task_state")
                );
                tasks.add(task);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return tasks;
    }

    public void update(Task task) {
        String sql = "UPDATE \"TP\".\"Task\" SET \"Task_name\" = ?, \"Reward\" = ?, \"Description\" = ?, \"Start_point\" = ?, \"End_point\" = ?, \"Customer_ID\" = ?, \"Task_state\" = ? WHERE \"Task_ID\" = ?";

        try (Connection conn = Database.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, task.getTaskName());
            stmt.setInt(2, task.getReward());
            stmt.setString(3, task.getDescription());
            stmt.setDate(4, task.getStartPoint());
            stmt.setDate(5, task.getEndPoint());
            stmt.setInt(6, task.getCustomerId());
            stmt.setBoolean(7, task.isTaskState());
            stmt.setInt(8, task.getTaskId());

            stmt.executeUpdate();
            System.out.println("Task обновлён.");

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public void delete(int taskId) {
        String sql = "DELETE FROM \"TP\".\"Task\" WHERE \"Task_ID\" = ?";

        try (Connection conn = Database.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, taskId);
            stmt.executeUpdate();
            System.out.println("Task удалён.");

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
