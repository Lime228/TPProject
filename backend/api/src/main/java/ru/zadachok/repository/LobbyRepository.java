// repository/LobbyRepository.java
package ru.zadachok.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import ru.zadachok.model.Lobby;

public interface LobbyRepository extends JpaRepository<Lobby, Integer> {
}
