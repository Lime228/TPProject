package dao;

import connection.Database;
import model.Product;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ProductDAO {

    public void insert(Product product) {
        String sql = "INSERT INTO \"TP\".\"Product\" (\"Product_name\", \"Description\", \"Photo\", \"Product_state\", \"Price\", \"Customer_ID\") " +
                "VALUES (?, ?, ?, ?, ?, ?)";

        try (Connection conn = Database.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, product.getName());
            stmt.setString(2, product.getDescription());
            stmt.setBytes(3, product.getPhoto());
            stmt.setInt(4, product.getState());
            stmt.setInt(5, product.getPrice());

            if (product.getCustomerId() != null) {
                stmt.setInt(6, product.getCustomerId());
            } else {
                stmt.setNull(6, Types.INTEGER);
            }

            stmt.executeUpdate();
        } catch (SQLException e) {
            System.out.println("Ошибка вставки продукта: " + e.getMessage());
        }
    }

    public List<Product> getAll() {
        List<Product> products = new ArrayList<>();
        String sql = "SELECT * FROM \"TP\".\"Product\"";

        try (Connection conn = Database.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                Product product = new Product(
                        rs.getInt("Product_ID"),
                        rs.getString("Product_name"),
                        rs.getString("Description"),
                        rs.getBytes("Photo"),
                        rs.getInt("Product_state"),
                        rs.getInt("Price"),
                        rs.getObject("Customer_ID") != null ? rs.getInt("Customer_ID") : null
                );
                products.add(product);
            }
        } catch (SQLException e) {
            System.out.println("Ошибка получения продуктов: " + e.getMessage());
        }
        return products;
    }

    public void update(Product product) {
        String sql = "UPDATE \"TP\".\"Product\" SET \"Product_name\" = ?, \"Description\" = ?, \"Photo\" = ?, \"Product_state\" = ?, \"Price\" = ?, \"Customer_ID\" = ? " +
                "WHERE \"Product_ID\" = ?";

        try (Connection conn = Database.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, product.getName());
            stmt.setString(2, product.getDescription());
            stmt.setBytes(3, product.getPhoto());
            stmt.setInt(4, product.getState());
            stmt.setInt(5, product.getPrice());

            if (product.getCustomerId() != null) {
                stmt.setInt(6, product.getCustomerId());
            } else {
                stmt.setNull(6, Types.INTEGER);
            }

            stmt.setInt(7, product.getId());

            stmt.executeUpdate();
        } catch (SQLException e) {
            System.out.println("Ошибка обновления продукта: " + e.getMessage());
        }
    }

    public void delete(int productId) {
        String sql = "DELETE FROM \"TP\".\"Product\" WHERE \"Product_ID\" = ?";

        try (Connection conn = Database.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, productId);
            stmt.executeUpdate();
        } catch (SQLException e) {
            System.out.println("Ошибка удаления продукта: " + e.getMessage());
        }
    }
}
