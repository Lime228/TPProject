package dao;

import connection.Database;
import model.Lobby;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class LobbyDAO {

    public void create(Lobby lobby) {
        String sql = "INSERT INTO \"TP\".\"Lobby\" (\"Task_ID\", \"Shop_ID\", \"Customer_ID\") VALUES (?, ?, ?)";

        try (Connection conn = Database.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            if (lobby.getTaskId() != null) {
                stmt.setInt(1, lobby.getTaskId());
            } else {
                stmt.setNull(1, Types.INTEGER);
            }
            stmt.setInt(2, lobby.getShopId());
            stmt.setInt(3, lobby.getCustomerId());

            stmt.executeUpdate();
            System.out.println("Lobby добавлен.");

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public List<Lobby> readAll() {
        List<Lobby> lobbies = new ArrayList<>();
        String sql = "SELECT * FROM \"TP\".\"Lobby\"";

        try (Connection conn = Database.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                Lobby lobby = new Lobby(
                        rs.getInt("Lobby_ID"),
                        (Integer) rs.getObject("Task_ID"),
                        rs.getInt("Shop_ID"),
                        rs.getInt("Customer_ID")
                );
                lobbies.add(lobby);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return lobbies;
    }

    public void update(Lobby lobby) {
        String sql = "UPDATE \"TP\".\"Lobby\" SET \"Task_ID\" = ?, \"Shop_ID\" = ?, \"Customer_ID\" = ? WHERE \"Lobby_ID\" = ?";

        try (Connection conn = Database.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            if (lobby.getTaskId() != null) {
                stmt.setInt(1, lobby.getTaskId());
            } else {
                stmt.setNull(1, Types.INTEGER);
            }
            stmt.setInt(2, lobby.getShopId());
            stmt.setInt(3, lobby.getCustomerId());
            stmt.setInt(4, lobby.getLobbyId());

            stmt.executeUpdate();
            System.out.println("Lobby обновлён.");

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public void delete(int lobbyId) {
        String sql = "DELETE FROM \"TP\".\"Lobby\" WHERE \"Lobby_ID\" = ?";

        try (Connection conn = Database.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, lobbyId);
            stmt.executeUpdate();
            System.out.println("Lobby удалён.");

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
