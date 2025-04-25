package ru.zadachok.model;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDate;

@Entity
@Table(name = "\"Task\"", schema = "\"tp\"")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Task {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "\"task_id\"")
    private Integer id;

    @Column(name = "\"task_name\"", length = 50)
    private String name;

    @Column(name = "\"reward\"")
    private Integer reward;

    @Column(name = "\"description\"", length = 254)
    private String description;

    @Column(name = "\"start_point\"")
    private LocalDate startDate;

    @Column(name = "\"end_point\"")
    private LocalDate endDate;

    @Column(name = "\"task_state\"", nullable = false)
    private Boolean isActive;
}