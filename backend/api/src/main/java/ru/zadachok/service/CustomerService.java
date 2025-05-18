// service/CustomerService.java
package ru.zadachok.service;

import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import ru.zadachok.dto.CustomerDto;
import ru.zadachok.exception.CustomerAlreadyExistsException;
import ru.zadachok.model.Customer;
import ru.zadachok.model.Lobby;
import ru.zadachok.model.Product;
import ru.zadachok.model.Wallet;
import ru.zadachok.repository.CustomerRepository;
import ru.zadachok.repository.LobbyRepository;
import ru.zadachok.repository.ProductRepository;
import ru.zadachok.repository.WalletRepository;
import ru.zadachok.request.*;

import java.util.List;

@Service
@RequiredArgsConstructor
public class CustomerService {
    private final CustomerRepository customerRepository;
    private final PasswordEncoder passwordEncoder;
    private final LobbyRepository lobbyRepository;
    private final LobbyService lobbyService;
    private final WalletRepository walletRepository;

    public CustomerDto register(RegisterRequest request) {
        if (request.getLogin().matches(".*[а-яА-ЯёЁ].*")) {
            throw new CustomerAlreadyExistsException("Логин не должен содержать русские буквы");
        }
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
                .customer_photo(null)
                .build();

        // Сохраняем через JPA
        Customer savedCustomer = customerRepository.save(customer);

        // Конвертируем в DTO
        return CustomerDto.builder()
                .customer_ID(savedCustomer.getCustomer_ID())
                .login(savedCustomer.getLogin())
                .customer_email(savedCustomer.getCustomer_email())
                .admin(savedCustomer.isAdmin() ? "ADMIN" : "USER")
                .birthday_date(savedCustomer.getBirthday_date())
                .customer_name(savedCustomer.getCustomer_name())
                .customer_photo(savedCustomer.getCustomer_photo())  // byte[]
                .build();

    }

    public UserDetails loadCustomerByCustomername(String login) throws UsernameNotFoundException {
        return customerRepository.findByLogin(login)
                .orElseThrow(() -> new UsernameNotFoundException("Customer not found"));
    }


    public CustomerDto updateCustomer(UpdateCustomerRequest request) {
        Customer customer = customerRepository.findById(request.getCustomer_ID())
                .orElseThrow(() -> new UsernameNotFoundException("Пользователь не найден"));

        if (request.getBirthday_date() != null) {
            customer.setBirthday_date(request.getBirthday_date());
        }
        if (request.getCustomer_name() != null) {
            customer.setCustomer_name(request.getCustomer_name());
        }
        if (request.getCustomer_photo() != null) {
            customer.setCustomer_photo(request.getCustomer_photo());
        }

        Customer updatedCustomer = customerRepository.save(customer);

        return CustomerDto.builder()
                .customer_ID(updatedCustomer.getCustomer_ID())
                .login(updatedCustomer.getLogin())
                .customer_email(updatedCustomer.getCustomer_email())
                .admin(updatedCustomer.isAdmin() ? "ADMIN" : "USER")
                .birthday_date(updatedCustomer.getBirthday_date())
                .customer_name(updatedCustomer.getCustomer_name())
                .customer_photo(updatedCustomer.getCustomer_photo())
                .build();
    }


    @Transactional
    public void deleteCustomer(DeleteCustomerRequest request) {
        int customerId = request.getCustomer_ID();

        Customer customer = customerRepository.findById(customerId)
                .orElseThrow(() -> new RuntimeException("Пользователь с ID " + customerId + " не найден"));

        // Найдем лобби, где этот пользователь состоит (он может быть только в одном)
        List<Lobby> allLobbies = lobbyRepository.findAll();

        Lobby customerLobby = null;
        for (Lobby lobby : allLobbies) {
            Integer[] customerIds = lobby.getCustomerId();
            if (customerIds != null && List.of(customerIds).contains(customerId)) {
                customerLobby = lobby;
                break;
            }
        }

        if (customerLobby != null) {
            if (customer.isAdmin()) {
                lobbyService.deleteLobby(DeleteLobbyRequest.builder()
                        .lobbyId(customerLobby.getLobbyId())
                        .build());
            } else {
                lobbyService.removeCustomerFromLobby(RemoveFromLobbyRequest.builder()
                        .lobbyId(customerLobby.getLobbyId())
                        .customerId(customerId)
                        .build());
            }
        }

        // Удаляем кошельки пользователя
        walletRepository.deleteAllByCustomerId(customerId);

        // Удаляем самого пользователя
        customerRepository.deleteById(customerId);
    }


    public CustomerDto getCustomerById(int id) {
        Customer customer =customerRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Пользователь с ID " + id + " не найден"));

        return CustomerDto.builder()
                .customer_ID(customer.getCustomer_ID())
                .login(customer.getLogin())
                .customer_email(customer.getCustomer_email())
                .admin(customer.isAdmin() ? "ADMIN" : "USER")
                .birthday_date(customer.getBirthday_date())
                .customer_name(customer.getCustomer_name())
                .customer_photo(customer.getCustomer_photo())
                .build();
    }

    public CustomerDto getCustomerByLogin(String login) {
        Customer customer =customerRepository.findByLogin(login)
                .orElseThrow(() -> new RuntimeException("Пользователь с логином " + login + " не найден"));

        return CustomerDto.builder()
                .customer_ID(customer.getCustomer_ID())
                .login(customer.getLogin())
                .customer_email(customer.getCustomer_email())
                .admin(customer.isAdmin() ? "ADMIN" : "USER")
                .birthday_date(customer.getBirthday_date())
                .customer_name(customer.getCustomer_name())
                .customer_photo(customer.getCustomer_photo())
                .build();
    }
}