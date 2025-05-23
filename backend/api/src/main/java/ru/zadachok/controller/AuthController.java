package ru.zadachok.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.ConstraintViolationException;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.web.bind.annotation.*;
import ru.zadachok.config.JwtTokenProvider;
import ru.zadachok.model.Customer;
import ru.zadachok.model.Product;
import ru.zadachok.repository.CustomerRepository;
import ru.zadachok.repository.ProductRepository;
import ru.zadachok.request.*;
import ru.zadachok.dto.CustomerDto;
import ru.zadachok.exception.CustomerAlreadyExistsException;
import ru.zadachok.service.CustomerService;
import ru.zadachok.service.EmailSenderService;
import ru.zadachok.service.PasswordResetCodeService;

import java.util.Map;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
@Tag(name = "Authentication", description = "Пользователь, регистрация, аутентификация")
public class AuthController {
    private final CustomerService customerService;
    private final AuthenticationManager authenticationManager;
    private final JwtTokenProvider tokenProvider;
    private final CustomerRepository customerRepository;
    private final EmailSenderService emailSenderService;


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

    @Operation(summary = "Получение данных пользователя по логину")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Данные пользователя успешно получены",
                    content = {@Content(mediaType = "application/json",
                            schema = @Schema(implementation = CustomerDto.class))}),
            @ApiResponse(responseCode = "404", description = "Пользователь не найден",
                    content = @Content)
    })
    @GetMapping("/login/{log}")
    public ResponseEntity<CustomerDto> getCustomer(@PathVariable String log) {
        CustomerDto gettedCustomer = customerService.getCustomerByLogin(log);
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

    @Operation(summary = "Восстановление пароля по логину и email")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Код восстановления отправлен на почту",
                    content = {@Content(mediaType = "application/json",
                            schema = @Schema(example = "{\"message\": \"Код для восстановления отправлен на почту: user123@example.com\"}"))}),
            @ApiResponse(responseCode = "400", description = "Email не совпадает с логином",
                    content = @Content),
            @ApiResponse(responseCode = "404", description = "Пользователь не найден",
                    content = @Content)
    })
    @PostMapping("/restore")
    public ResponseEntity<String> restorePassword(@Valid @RequestBody RestorePasswordRequest request) {
        if (customerService.restorePassword(request)){
            return ResponseEntity.ok("Код для восстановления отправлен на указанную почт.");
        }
        return ResponseEntity.status(400).body("Почта пользователя не совпадает с введенной");
    }

    @Operation(summary = "Проверка кода восстановления и сброс пароля")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Пароль успешно изменен",
                    content = {@Content(mediaType = "application/json",
                            schema = @Schema(example = "{\"message\": \"Пароль успешно изменён\"}"))}),
            @ApiResponse(responseCode = "400", description = "Неверный или просроченный код",
                    content = @Content),
            @ApiResponse(responseCode = "404", description = "Пользователь не найден",
                    content = @Content)
    })
    @PostMapping("/reset-password")
    public ResponseEntity<String> resetPassword(@Valid @RequestBody ResetPasswordRequest request) {
        if(customerService.resetPassword(request)) {
            return ResponseEntity.ok("Пароль успешно изменён");
        }
        return ResponseEntity.status(400).body("Неверный или просроченный код");
    }
}
