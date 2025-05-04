package ru.zadachok.request;

import com.fasterxml.jackson.annotation.JsonProperty;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.*;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
@Schema(description = "Запрос на регистрацию нового пользователя")
public class RegisterRequest {
    @JsonProperty("login")
    @NotBlank
    @Size(min = 3, max = 20)
    @Schema(description = "Логин пользователя",
            example = "newuser",
            requiredMode = Schema.RequiredMode.REQUIRED,
            minLength = 3,
            maxLength = 20)
    private String login;

    @JsonProperty("password")
    @NotBlank
    @Size(min = 6, max = 40)
    @Schema(description = "Пароль пользователя",
            example = "securePass123",
            requiredMode = Schema.RequiredMode.REQUIRED,
            minLength = 6,
            maxLength = 40)
    private String password;

    @JsonProperty("email")
    @NotBlank
    @Email
    @Schema(description = "Email пользователя",
            example = "user@example.com",
            requiredMode = Schema.RequiredMode.REQUIRED,
            format = "email")
    private String customer_email;
}
