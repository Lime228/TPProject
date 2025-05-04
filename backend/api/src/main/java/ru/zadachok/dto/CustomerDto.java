package ru.zadachok.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.*;
import java.sql.Date;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "DTO для представления информации о пользователе",
        example = """
        {
            "customer_ID": 123,
            "login": "user123",
            "customer_email": "user@example.com",
            "admin": "USER",
            "birthday_date": "1990-01-15",
            "customer_name": "Иван Иванов"
        }""")
public class CustomerDto {
    @Schema(description = "Уникальный идентификатор пользователя",
            example = "123",
            requiredMode = Schema.RequiredMode.REQUIRED)
    private Long customer_ID;

    @Schema(description = "Логин пользователя",
            example = "user123",
            requiredMode = Schema.RequiredMode.REQUIRED,
            maxLength = 50)
    private String login;

    @Schema(description = "Email пользователя",
            example = "user@example.com",
            format = "email",
            requiredMode = Schema.RequiredMode.REQUIRED)
    private String customer_email;

    @Schema(description = "Роль пользователя",
            example = "USER",
            allowableValues = {"USER", "ADMIN"},
            requiredMode = Schema.RequiredMode.REQUIRED)
    private String admin;

    @Schema(description = "Дата рождения пользователя",
            example = "1990-01-15",
            format = "date",
            requiredMode = Schema.RequiredMode.NOT_REQUIRED)
    private Date birthday_date;

    @Schema(description = "Фотография пользователя в байтовом представлении",
            format = "byte",
            requiredMode = Schema.RequiredMode.NOT_REQUIRED)
    private byte[] customer_photo;

    @Schema(description = "Полное имя пользователя",
            example = "Иван Иванов",
            requiredMode = Schema.RequiredMode.NOT_REQUIRED,
            maxLength = 100)
    private String customer_name;
}