package ru.zadachok.request;

import com.fasterxml.jackson.annotation.JsonProperty;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
@Schema(description = "Запрос на восстановление пароля")
public class RestorePasswordRequest {

    @JsonProperty("login")
    @NotNull
    @Schema(description = "Логин пользователя",
            example = "user123",
            requiredMode = Schema.RequiredMode.REQUIRED,
            maxLength = 50)
    private String login;

    @JsonProperty("email")
    @NotNull
    @Email
    @Schema(description = "Email, связанный с аккаунтом",
            example = "user123@example.com",
            requiredMode = Schema.RequiredMode.REQUIRED,
            maxLength = 100)
    private String email;
}
