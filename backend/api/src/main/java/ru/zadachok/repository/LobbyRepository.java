package ru.zadachok.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import ru.zadachok.model.Lobby;

import java.util.List;
import java.util.Optional;

public interface LobbyRepository extends JpaRepository<Lobby, Integer> {
    Optional<Lobby> findByCode(String code);
    boolean existsByCode(String code);

    List<Lobby> findAllByAdminId(Integer adminId);
}
