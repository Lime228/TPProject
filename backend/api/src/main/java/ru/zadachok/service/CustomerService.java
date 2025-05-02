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
                .login(request.getLogin())
                .admin(false)
                .customer_photo(null) // <-- можно явно, можно вообще не писать
                .build();

        // Сохраняем через JPA
        Customer savedCustomer = customerRepository.save(customer);

        // Конвертируем в DTO
        return CustomerDto.builder()
                .customer_ID(savedCustomer.getCustomer_ID().longValue())
                .login(savedCustomer.getLogin())
                .customer_email(savedCustomer.getCustomer_email())
                .admin(savedCustomer.isAdmin() ? "ADMIN" : "USER")
                .birthday_date(savedCustomer.getBirthday_date())
                .customer_name(savedCustomer.getCustomer_name())
                .customer_photo(savedCustomer.getCustomer_photo())  // напрямую byte[]
                .build();

    }

    public UserDetails loadCustomerByCustomername(String login) throws UsernameNotFoundException {
        return customerRepository.findByLogin(login)
                .orElseThrow(() -> new UsernameNotFoundException("Customer not found"));
    }
}