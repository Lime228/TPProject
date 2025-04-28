package ru.zadachok.request;

import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.validation.constraints.NotBlank;
import lombok.*;



@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class AuthRequest {
    @JsonProperty("login")  // Входящее поле в JSON будет "login"
    @NotBlank
    private String login;

    @JsonProperty("password")  // Входящее поле в JSON будет "login"
    @NotBlank
    private String password;
}
