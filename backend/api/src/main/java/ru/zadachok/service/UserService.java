// service/UserService.java
package ru.zadachok.service;

import lombok.RequiredArgsConstructor;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import ru.zadachok.dto.RegisterRequest;
import ru.zadachok.dto.UserDto;
import ru.zadachok.exception.UserAlreadyExistsException;
import ru.zadachok.model.Customer;
import ru.zadachok.repository.CustomerRepository;

@Service
@RequiredArgsConstructor
public class UserService {
    private final CustomerRepository customerRepository;
    private final PasswordEncoder passwordEncoder;

    public UserDto register(RegisterRequest request) {
        // Проверяем уникальность логина и email
        if (customerRepository.existsByLogin(request.getUsername())) {
            throw new UserAlreadyExistsException("Логин уже занят");
        }
        if (customerRepository.existsByEmail(request.getEmail())) {
            throw new UserAlreadyExistsException("Email уже занят");
        }

        // Создаем нового Customer
        Customer customer = Customer.builder()
                .name(request.getUsername())
                .email(request.getEmail())
                .password(passwordEncoder.encode(request.getPassword()))
                .login(request.getUsername())  // login = username
                .isAdmin(false)                // По умолчанию не админ
                .build();

        // Сохраняем через JPA
        Customer savedCustomer = customerRepository.save(customer);

        // Конвертируем в DTO
        return UserDto.builder()
                .id(customer.getId().longValue())  // Конвертируем Integer в Long
                .username(customer.getName())
                .email(customer.getEmail())
                .role(customer.isAdmin() ? "ADMIN" : "USER")  // Определяем роль
                .birthday(customer.getBirthday())  // Добавляем, если нужно
                .login(customer.getLogin())        // Добавляем, если нужно
                .build();
    }

    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        return customerRepository.findByLogin(username)
                .orElseThrow(() -> new UsernameNotFoundException("User not found"));
    }
}