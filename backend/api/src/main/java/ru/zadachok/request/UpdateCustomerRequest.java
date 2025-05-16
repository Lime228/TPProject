package ru.zadachok.request;

import com.fasterxml.jackson.annotation.JsonProperty;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotNull;
import lombok.Data;
import java.sql.Date;

@Data
@Schema(description = "Запрос на обновление данных пользователя")
public class UpdateCustomerRequest {

    @JsonProperty("customerId")
    @NotNull
    @Schema(description = "Уникальный идентификатор пользователя",
            example = "123",
            requiredMode = Schema.RequiredMode.REQUIRED)
    private Integer customer_ID;

    @JsonProperty("birthday")
    @NotNull
    @Schema(description = "Дата рождения пользователя",
            example = "1990-01-15",
            format = "date",
            requiredMode = Schema.RequiredMode.NOT_REQUIRED)
    private Date birthday_date;

    @JsonProperty("photo")
    @NotNull
    @Schema(description = "Фотография пользователя в base64",
            format = "byte",
            requiredMode = Schema.RequiredMode.NOT_REQUIRED)
    private byte[] customer_photo;

    @JsonProperty("name")
    @NotNull
    @Schema(description = "Полное имя пользователя",
            example = "Иван Иванов",
            requiredMode = Schema.RequiredMode.NOT_REQUIRED,
            maxLength = 100)
    private String customer_name;
}