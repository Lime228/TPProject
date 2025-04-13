import dao.CustomerDAO;
import model.Customer;

import java.io.PrintStream;
import java.io.UnsupportedEncodingException;
import java.sql.Date;
import java.util.List;

public class Main {
    public static void main(String[] args) throws UnsupportedEncodingException {
        System.setOut(new PrintStream(System.out, true, "UTF-8"));
        // Создаем экземпляр DAO для работы с Customer
        CustomerDAO customerDAO = new CustomerDAO();

        // 1. Добавление новой записи в таблицу Customer
        System.out.println("Добавляем нового пользователя...");
        Customer newCustomer = new Customer(
                "John Doe", // Customer_name
                "johndoe@example.com", // Customer_email
                "password123", // Password
                Date.valueOf("1990-01-01"), // Birthday_date
                "johndoe", // Login
                true // Admin
        );

        // 2. Выводим все записи до удаления
        System.out.println("Записи в таблице Customer до удаления:");
        List<Customer> customersBeforeDelete = customerDAO.getAll();
        for (Customer customer : customersBeforeDelete) {
            System.out.println(customer.getId() + ": " + customer.getName());
        }

        // 3. Удаляем только что добавленную запись
        // Предположим, что у нас есть ID для этой записи, который мы знаем заранее.
        // Обычно, мы могли бы получить его через другой запрос, но для примера тут будет простой вариант:
        // Допустим, ID = 1, так как это первая запись, добавленная в таблицу.
        System.out.println("\nУдаляем запись с ID: 3");
        customerDAO.delete(3);  // Удаляем запись с ID = 1

        // 4. Проверяем таблицу после удаления записи
        System.out.println("Записи в таблице Customer после удаления:");
        List<Customer> customersAfterDelete = customerDAO.getAll();
        for (Customer customer : customersAfterDelete) {
            System.out.println(customer.getId() + ": " + customer.getName());
        }
    }
}
