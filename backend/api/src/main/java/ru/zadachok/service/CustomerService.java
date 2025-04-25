// service/CustomerService.java
package ru.zadachok.service;

import lombok.RequiredArgsConstructor;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import ru.zadachok.dto.CustomerDto;
import ru.zadachok.exception.CustomerAlreadyExistsException;
import ru.zadachok.model.Customer;
import ru.zadachok.repository.CustomerRepository;
import ru.zadachok.request.RegisterRequest;

@Service
@RequiredArgsConstructor
public class CustomerService {
    private final CustomerRepository customerRepository;
    private final PasswordEncoder passwordEncoder;

    public CustomerDto register(RegisterRequest request) {
        // Проверяем уникальность логина и email
        if (customerRepository.existsByLogin(request.getLogin())) {
            throw new CustomerAlreadyExistsException("Логин уже занят");
        }
        if (customerRepository.existsByEmail(request.getCustomer_email())) {
            throw new CustomerAlreadyExistsException("Email уже занят");
        }

        // Создаем нового Customer
        Customer customer = Customer.builder()
                .customer_name(request.getLogin())
                .customer_email(request.getCustomer_email())
                .password(passwordEncoder.encode(request.getPassword()))
                .login(request.getLogin())  // login = Customer_name
                .admin(false)                // По умолчанию не админ
                .build();

        // Сохраняем через JPA
        Customer savedCustomer = customerRepository.save(customer);

        // Конвертируем в DTO
        return CustomerDto.builder()
                .customer_ID(customer.getCustomer_ID().longValue())  // Конвертируем Integer в Long
                .login(customer.getLogin())
                .customer_email(customer.getCustomer_email())
                .admin(customer.isAdmin() ? "ADMIN" : "USER")  // Определяем isAdmin
                .birthday_date(customer.getBirthday_date())  // Добавляем, если нужно
                .login(customer.getLogin())        // Добавляем, если нужно
                .build();
    }

    public UserDetails loadCustomerByCustomername(String login) throws UsernameNotFoundException {
        return customerRepository.findByLogin(login)
                .orElseThrow(() -> new UsernameNotFoundException("Customer not found"));
    }
}