package ru.zadachok.request;

import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.*;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class RegisterRequest {

    @JsonProperty("login")  // Входящее поле в JSON будет "login"
    @NotBlank
    @Size(min = 3, max = 20)
    private String login;

    @JsonProperty("password")  // Входящее поле в JSON будет "password"
    @NotBlank
    @Size(min = 6, max = 40)
    private String password;

    @JsonProperty("email")  // Тут ты меняешь отображение
    @NotBlank
    @Email
    private String customer_email;
}
