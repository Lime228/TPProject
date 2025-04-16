package ru.zadachok.controller;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.AuthenticationException;
import org.springframework.web.bind.annotation.*;
import ru.zadachok.config.JwtTokenProvider;
import ru.zadachok.dto.AuthRequest;
import ru.zadachok.dto.RegisterRequest;
import ru.zadachok.dto.UserDto;
import ru.zadachok.exception.UserAlreadyExistsException;
import ru.zadachok.service.UserService;

import java.util.Map;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {
    private final UserService userService;
    private final AuthenticationManager authenticationManager;
    private final JwtTokenProvider tokenProvider;

    @PostMapping("/register")
    public ResponseEntity<?> register(@RequestBody RegisterRequest request) {
        try {
            UserDto user = userService.register(request);
            return ResponseEntity.ok(user);
        } catch (UserAlreadyExistsException e) {
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
                            request.getUsername(),
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