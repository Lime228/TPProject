package ru.zadachok.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import ru.zadachok.model.Task;

public interface TaskRepository extends JpaRepository<Task, Integer> {
}
