package ru.zadachok.request;

import com.fasterxml.jackson.annotation.JsonProperty;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import lombok.*;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
@Schema(description = "Запрос на аутентификацию пользователя")
public class AuthRequest {
    @JsonProperty("login")
    @NotBlank
    @Schema(description = "Логин пользователя",
            example = "user123",
            requiredMode = Schema.RequiredMode.REQUIRED,
            minLength = 3,
            maxLength = 20)
    private String login;

    @JsonProperty("password")
    @NotBlank
    @Schema(description = "Пароль пользователя",
            example = "securePassword123",
            requiredMode = Schema.RequiredMode.REQUIRED,
            minLength = 6,
            maxLength = 40)
    private String password;
}
