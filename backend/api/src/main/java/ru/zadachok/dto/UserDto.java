package ru.zadachok.dto;

import lombok.*;

import java.sql.Date;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserDto {
    private Long id;          // Теперь Long (вместо Integer)
    private String username;  // Соответствует полю name в Customer
    private String email;
    private String role;      // "USER" или "ADMIN" (на основе isAdmin из Customer)
    private Date birthday;    // Добавляем, если нужно (было в Customer)
    private String login;     // Добавляем, если нужно отдельно от username
}