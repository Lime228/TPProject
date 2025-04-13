package ru.zadachok.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.*;



@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class AuthRequest {
    @NotBlank
    private String username;

    @NotBlank
    private String password;
}