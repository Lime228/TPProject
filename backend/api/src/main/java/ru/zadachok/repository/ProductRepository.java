package ru.zadachok.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import ru.zadachok.model.Product;

public interface ProductRepository extends JpaRepository<Product, Integer> {
}