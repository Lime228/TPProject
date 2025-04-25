package ru.zadachok.dto;

import lombok.*;

import java.sql.Date;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor

public class CustomerDto {
    private Long customer_ID;          // Теперь Long (вместо Integer)
    private String login;  // Соответствует полю name в Customer
    private String customer_email;
    private String admin;      // "USER" или "ADMIN" (на основе isAdmin из Customer)
    private Date birthday_date;    // Добавляем, если нужно (было в Customer)
    private String customer_name;     // Добавляем, если нужно отдельно от username
}