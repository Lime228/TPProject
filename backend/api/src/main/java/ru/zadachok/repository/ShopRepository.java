package ru.zadachok.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import ru.zadachok.model.Shop;

public interface ShopRepository extends JpaRepository<Shop, Integer> {
}
