package ru.zadachok.request;

import jakarta.validation.constraints.NotBlank;
import lombok.*;



@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class AuthRequest {
    @NotBlank
    private String login;

    @NotBlank
    private String password;
}
