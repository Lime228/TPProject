package ru.zadachok.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.AuthenticationException;
import org.springframework.web.bind.annotation.*;
import ru.zadachok.config.JwtTokenProvider;
import ru.zadachok.request.AuthRequest;
import ru.zadachok.dto.CustomerDto;
import ru.zadachok.exception.CustomerAlreadyExistsException;
import ru.zadachok.service.CustomerService;
import ru.zadachok.request.RegisterRequest;
import java.util.Map;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {
    private final CustomerService customerService;
    private final AuthenticationManager authenticationManager;
    private final JwtTokenProvider tokenProvider;

    @PostMapping("/register")
    public ResponseEntity<?> register(@RequestBody RegisterRequest request) {
        try {
            CustomerDto user = customerService.register(request);
            return ResponseEntity.ok(user);
        } catch (CustomerAlreadyExistsException e) {
            return ResponseEntity.badRequest().body(
                    Map.of("error", e.getMessage())
            );
        }
    }

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


//    @PostMapping("/login")
//    public ResponseEntity<?> login(@RequestBody AuthRequest request) {
//        try {
//            // 1. Проверяем существует ли пользователь
//            var user = userService.loadUserByUsername(request.getUsername());
//
//            // 2. Аутентифицируем
//            Authentication authentication = authenticationManager.authenticate(
//                    new UsernamePasswordAuthenticationToken(
//                            request.getUsername(),
//                            request.getPassword()
//                    )
//            );
//
//            // 3. Генерируем токен
//            String jwt = tokenProvider.generateToken(authentication);
//            return ResponseEntity.ok(Map.of("token", jwt));
//
//        } catch (BadCredentialsException e) {
//            return ResponseEntity.status(401).body(Map.of("error", "Invalid credentials"));
//        } catch (Exception e) {
//            return ResponseEntity.status(500).body(Map.of("error", e.getMessage()));
//        }
//    }
}