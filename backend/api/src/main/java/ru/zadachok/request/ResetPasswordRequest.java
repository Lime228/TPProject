package ru.zadachok.request;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class ResetPasswordRequest {
    @NotBlank
    private String login;

    @NotBlank
    private String code;

    @NotBlank
    private String newPassword;
}