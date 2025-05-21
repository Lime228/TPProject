package ru.zadachok.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import ru.zadachok.model.Task;

import java.sql.Timestamp;
import java.util.List;

public interface TaskRepository extends JpaRepository<Task, Integer> {

    List<Task> findByEndDateBetweenAndIsActive(Timestamp start, Timestamp end, Integer isActive);

    @Query("SELECT t FROM Task t WHERE t.endDate BETWEEN :start AND :end AND t.isActive = :isActive")
    List<Task> findTasksBetweenDates(
            @Param("start") Timestamp start,
            @Param("end") Timestamp end,
            @Param("isActive") Integer isActive);


    List<Task> findByIsActive(Integer isActive);

    @Query("SELECT t FROM Task t WHERE t.endDate < CURRENT_TIMESTAMP AND t.isActive = 1")
    List<Task> findOverdueActiveTasks();

    List<Task> findByCustomerIdAndIsActive(Integer customerId, Integer isActive);
}
