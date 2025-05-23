package ru.zadachok.request;

import com.fasterxml.jackson.annotation.JsonProperty;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
@Schema(description = "Запрос на удаление пользователя")
public class DeleteCustomerRequest {

    @JsonProperty("customerId")
    @NotNull
    @Schema(description = "Уникальный идентификатор пользователя",
            example = "123",
            requiredMode = Schema.RequiredMode.REQUIRED)
    private Integer customer_ID;

    @JsonProperty("login")
    @NotNull
    @Schema(description = "Логин пользователя",
            example = "user123",
            requiredMode = Schema.RequiredMode.REQUIRED,
            maxLength = 50)
    private String login;

    @JsonProperty("password")
    @NotNull
    @Schema(description = "Зашифрованный пароль пользователя",
            example = "$2a$10$N9qo8uLOickgx2ZMRZoMy...",
            requiredMode = Schema.RequiredMode.REQUIRED)
    private String password;

}