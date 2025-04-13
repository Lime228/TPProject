package dao;

import connection.Database;
import model.Shop;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ShopDAO {

    public void create(Shop shop) {
        String sql = "INSERT INTO \"TP\".\"Shop\" (\"Product_ID\", \"Quantity\") VALUES (?, ?)";
        try (Connection conn = Database.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, shop.getProductId());
            stmt.setInt(2, shop.getQuantity());
            stmt.executeUpdate();
            System.out.println("Shop добавлен.");

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public List<Shop> readAll() {
        List<Shop> shops = new ArrayList<>();
        String sql = "SELECT * FROM \"TP\".\"Shop\"";

        try (Connection conn = Database.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                Shop shop = new Shop(
                        rs.getInt("Shop_ID"),
                        rs.getInt("Product_ID"),
                        rs.getInt("Quantity")
                );
                shops.add(shop);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return shops;
    }

    public void update(Shop shop) {
        String sql = "UPDATE \"TP\".\"Shop\" SET \"Product_ID\" = ?, \"Quantity\" = ? WHERE \"Shop_ID\" = ?";

        try (Connection conn = Database.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, shop.getProductId());
            stmt.setInt(2, shop.getQuantity());
            stmt.setInt(3, shop.getShopId());
            stmt.executeUpdate();
            System.out.println("Shop обновлён.");

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public void delete(int shopId) {
        String sql = "DELETE FROM \"TP\".\"Shop\" WHERE \"Shop_ID\" = ?";

        try (Connection conn = Database.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, shopId);
            stmt.executeUpdate();
            System.out.println("Shop удалён.");

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
