package ru.zadachok.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import ru.zadachok.model.Customer;

import java.util.Optional;

public interface CustomerRepository extends JpaRepository<Customer, Integer> {

    // Поиск по логину (поле login в Customer)
    Optional<Customer> findByLogin(String login);

    // Поиск по email (поле customer_email в Customer)
    @Query("SELECT c FROM Customer c WHERE c.customer_email = :email")
    Optional<Customer> findByEmail(@Param("email") String email);

    // Проверка существования логина (поле login в Custom)
    boolean existsByLogin(String login);

    // Проверка существования email (поле customer_email в Customer)
    @Query("SELECT COUNT(c) > 0 FROM Customer c WHERE c.customer_email = :email")
    boolean existsByEmail(@Param("email") String email);
}