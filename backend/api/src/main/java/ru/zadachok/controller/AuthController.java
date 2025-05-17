package ru.zadachok.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.ConstraintViolationException;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.web.bind.annotation.*;
import ru.zadachok.config.JwtTokenProvider;
import ru.zadachok.model.Product;
import ru.zadachok.request.AuthRequest;
import ru.zadachok.dto.CustomerDto;
import ru.zadachok.exception.CustomerAlreadyExistsException;
import ru.zadachok.request.DeleteCustomerRequest;
import ru.zadachok.request.UpdateCustomerRequest;
import ru.zadachok.service.CustomerService;
import ru.zadachok.request.RegisterRequest;
import java.util.Map;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
@Tag(name = "Authentication", description = "Пользователь, регистрация, аутентификация")
public class AuthController {
    private final CustomerService customerService;
    private final AuthenticationManager authenticationManager;
    private final JwtTokenProvider tokenProvider;

    @Operation(summary = "Регистрация нового пользователя")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Пользователь успешно зарегистрирован",
                    content = {@Content(mediaType = "application/json",
                            schema = @Schema(implementation = CustomerDto.class))}),
            @ApiResponse(responseCode = "400", description = "Пользователь уже существует",
                    content = @Content)
    })
    @PostMapping("/register")
    public ResponseEntity<?> register(@RequestBody RegisterRequest request) {
        try {
            CustomerDto user = customerService.register(request);
            return ResponseEntity.ok(user);
        } catch (CustomerAlreadyExistsException e) {
            return ResponseEntity.badRequest().body(
                    Map.of("error", e.getMessage())
            );
        } catch (ConstraintViolationException e) {
            return ResponseEntity.badRequest().body(
                    Map.of("error", e.getConstraintViolations().iterator().next().getMessage())
            );
        }
    }

    @Operation(summary = "Аутентификация пользователя")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Аутентификация успешна, возвращен JWT токен",
                    content = {@Content(mediaType = "application/json",
                            schema = @Schema(example = "{\"token\": \"string\"}"))}),
            @ApiResponse(responseCode = "401", description = "Неверные учетные данные",
                    content = @Content)
    })
    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody AuthRequest request) {
        try {
            Authentication auth = authenticationManager.authenticate(
                    new UsernamePasswordAuthenticationToken(
                            request.getLogin(),
                            request.getPassword()
                    )
            );

            String jwt = tokenProvider.generateToken(auth);
            return ResponseEntity.ok(Map.of("token", jwt));
        } catch (AuthenticationException e) {
            return ResponseEntity.status(401).body(
                    Map.of("error", "Invalid credentials")
            );
        }
    }

    @Operation(summary = "Получение данных пользователя")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Данные пользователя успешно получены",
                    content = {@Content(mediaType = "application/json",
                            schema = @Schema(implementation = CustomerDto.class))}),
            @ApiResponse(responseCode = "404", description = "Пользователь не найден",
                    content = @Content)
    })
    @GetMapping("/{id}")
    public ResponseEntity<CustomerDto> getCustomer(@PathVariable int id) {
        CustomerDto gettedCustomer = customerService.getCustomerById(id);
        return ResponseEntity.ok(gettedCustomer);
    }

    @Operation(summary = "Обновление данных пользователя")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Данные пользователя успешно обновлены",
                    content = {@Content(mediaType = "application/json",
                            schema = @Schema(implementation = CustomerDto.class))}),
            @ApiResponse(responseCode = "404", description = "Пользователь не найден",
                    content = @Content)
    })
    @PutMapping("/update")
    public ResponseEntity<?> updateCustomer(@RequestBody UpdateCustomerRequest request) {
        try {
            CustomerDto updatedCustomer = customerService.updateCustomer(request);
            return ResponseEntity.ok(updatedCustomer);
        } catch (UsernameNotFoundException e) {
            return ResponseEntity.status(404).body(
                    Map.of("error", e.getMessage())
            );
        }
    }

    @Operation(summary = "Удаление пользователя")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Пользователь успешно удален",
                    content = {@Content(mediaType = "application/json",
                            schema = @Schema(example = "{\"message\": \"User deleted successfully\"}"))}),
            @ApiResponse(responseCode = "404", description = "Пользователь не найден",
                    content = @Content)
    })
    @DeleteMapping("/delete")
    public ResponseEntity<String> deleteCustomer(@RequestBody DeleteCustomerRequest request) {
        customerService.deleteCustomer(request);
        return ResponseEntity.ok("Лобби и связанные сущности удалены");
    }


}

//    @Operation(summary = "Запрос на восстановление пароля")
//    @ApiResponses(value = {
//            @ApiResponse(responseCode = "200", description = "Ссылка для сброса пароля отправлена на email",
//                    content = {@Content(mediaType = "application/json",
//                            schema = @Schema(example = "{\"message\": \"Password reset link sent to email\"}"))}),
//            @ApiResponse(responseCode = "404", description = "Пользователь с таким email не найден",
//                    content = @Content)
//    })
//    @PostMapping("/forgot-password")
//    public ResponseEntity<?> forgotPassword(@RequestParam String email) {
//        try {
//            customerService.initiatePasswordReset(email);
//            return ResponseEntity.ok(Map.of("message", "Password reset link sent to email"));
//        } catch (CustomerNotFoundException e) {
//            return ResponseEntity.status(404).body(
//                    Map.of("error", e.getMessage())
//            );
//        }
//    }
//
//    @Operation(summary = "Сброс пароля")
//    @ApiResponses(value = {
//            @ApiResponse(responseCode = "200", description = "Пароль успешно изменен",
//                    content = {@Content(mediaType = "application/json",
//                            schema = @Schema(example = "{\"message\": \"Password reset successfully\"}"))}),
//            @ApiResponse(responseCode = "400", description = "Неверный или просроченный токен",
//                    content = @Content),
//            @ApiResponse(responseCode = "404", description = "Пользователь не найден",
//                    content = @Content)
//    })
//    @PostMapping("/reset-password")
//    public ResponseEntity<?> resetPassword(@RequestBody PasswordResetRequest request) {
//        try {
//            customerService.resetPassword(request.getToken(), request.getNewPassword());
//            return ResponseEntity.ok(Map.of("message", "Password reset successfully"));
//        } catch (CustomerNotFoundException e) {
//            return ResponseEntity.status(404).body(
//                    Map.of("error", e.getMessage())
//            );
//        } catch (IllegalArgumentException e) {
//            return ResponseEntity.badRequest().body(
//                    Map.of("error", e.getMessage())
//            );
//        }
//    }