package dao;

import connection.Database;
import model.Wallet;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class WalletDAO {

    public void create(Wallet wallet) {
        String sql = "INSERT INTO \"TP\".\"Wallet\" (\"Customer_ID\", \"Lobby_ID\", \"Balance\") VALUES (?, ?, ?)";

        try (Connection conn = Database.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, wallet.getCustomerId());
            stmt.setInt(2, wallet.getLobbyId());
            stmt.setInt(3, wallet.getBalance());

            stmt.executeUpdate();
            System.out.println("Wallet добавлен.");

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public List<Wallet> readAll() {
        List<Wallet> wallets = new ArrayList<>();
        String sql = "SELECT * FROM \"TP\".\"Wallet\"";

        try (Connection conn = Database.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                Wallet wallet = new Wallet(
                        rs.getInt("Wallet_ID"),
                        rs.getInt("Customer_ID"),
                        rs.getInt("Lobby_ID"),
                        rs.getInt("Balance")
                );
                wallets.add(wallet);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return wallets;
    }

    public void update(Wallet wallet) {
        String sql = "UPDATE \"TP\".\"Wallet\" SET \"Customer_ID\" = ?, \"Lobby_ID\" = ?, \"Balance\" = ? WHERE \"Wallet_ID\" = ?";

        try (Connection conn = Database.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, wallet.getCustomerId());
            stmt.setInt(2, wallet.getLobbyId());
            stmt.setInt(3, wallet.getBalance());
            stmt.setInt(4, wallet.getWalletId());

            stmt.executeUpdate();
            System.out.println("Wallet обновлён.");

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public void delete(int walletId) {
        String sql = "DELETE FROM \"TP\".\"Wallet\" WHERE \"Wallet_ID\" = ?";

        try (Connection conn = Database.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, walletId);
            stmt.executeUpdate();
            System.out.println("Wallet удалён.");

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
