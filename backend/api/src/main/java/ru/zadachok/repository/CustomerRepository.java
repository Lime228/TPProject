package ru.zadachok.repository;

import ru.zadachok.model.Customer;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

public interface CustomerRepository extends JpaRepository<Customer, Integer> {
    Optional<Customer> findByLogin(String login);       // Аналог findByUsername
    Optional<Customer> findByEmail(String email);      // Для проверки уникальности
    boolean existsByLogin(String login);               // Для валидации
    boolean existsByEmail(String email);               // Для валидации
}