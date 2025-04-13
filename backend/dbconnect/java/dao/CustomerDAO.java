package dao;

import connection.Database;
import model.Customer;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CustomerDAO {

    public void insert(Customer customer) {
        String sql = "INSERT INTO \"TP\".\"Customer\" (\"Customer_name\", \"Customer_email\", \"Password\", \"Birthday_date\", \"Login\", \"Admin\") " +
                "VALUES (?, ?, ?, ?, ?, ?)";

        try (Connection conn = Database.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, customer.getName());
            stmt.setString(2, customer.getEmail());
            stmt.setString(3, customer.getPassword());
            stmt.setDate(4, customer.getBirthday());
            stmt.setString(5, customer.getLogin());
            stmt.setBoolean(6, customer.isAdmin());

            stmt.executeUpdate();
        } catch (SQLException e) {
            System.out.println("Ошибка вставки: " + e.getMessage());
        }
    }

    public List<Customer> getAll() {
        List<Customer> customers = new ArrayList<>();
        String sql = "SELECT * FROM \"TP\".\"Customer\"";

        try (Connection conn = Database.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                Customer customer = new Customer(
                        rs.getInt("Customer_ID"),
                        rs.getString("Customer_name"),
                        rs.getString("Customer_email"),
                        rs.getString("Password"),
                        rs.getDate("Birthday_date"),
                        rs.getString("Login"),
                        rs.getBoolean("Admin")
                );
                customers.add(customer);
            }
        } catch (SQLException e) {
            System.out.println("Ошибка получения: " + e.getMessage());
        }
        return customers;
    }

    public List<Customer> readAll() {
        List<Customer> customers = new ArrayList<>();
        String sql = "SELECT * FROM \"TP\".\"Customer\"";

        try (Connection conn = Database.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                Customer customer = new Customer(
                        rs.getInt("Customer_ID"),
                        rs.getString("Customer_name"),
                        rs.getString("Customer_email"),
                        rs.getString("Password"),
                        rs.getDate("Birthday_date"),
                        rs.getString("Login"),
                        rs.getBoolean("Admin")
                );
                customers.add(customer);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return customers;
    }

    public void update(Customer customer) {
        String sql = "UPDATE \"TP\".\"Customer\" SET \"Customer_name\" = ?, \"Customer_email\" = ?, \"Password\" = ?, \"Birthday_date\" = ?, \"Login\" = ?, \"Admin\" = ? " +
                "WHERE \"Customer_ID\" = ?";

        try (Connection conn = Database.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, customer.getName());
            stmt.setString(2, customer.getEmail());
            stmt.setString(3, customer.getPassword());
            stmt.setDate(4, customer.getBirthday());
            stmt.setString(5, customer.getLogin());
            stmt.setBoolean(6, customer.isAdmin());
            stmt.setInt(7, customer.getId());

            stmt.executeUpdate();
        } catch (SQLException e) {
            System.out.println("Ошибка обновления: " + e.getMessage());
        }
    }

    public void delete(int customerId) {
        String sql = "DELETE FROM \"TP\".\"Customer\" WHERE \"Customer_ID\" = ?";

        try (Connection conn = Database.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, customerId);
            stmt.executeUpdate();
        } catch (SQLException e) {
            System.out.println("Ошибка удаления: " + e.getMessage());
        }
    }
}
