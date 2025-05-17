package ru.zadachok.config;

import lombok.RequiredArgsConstructor;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;
import ru.zadachok.model.Customer;
import ru.zadachok.repository.CustomerRepository;

import java.util.Collections;

@Service
@RequiredArgsConstructor
public class CustomerDetailsService implements UserDetailsService {

    private final CustomerRepository customerRepository;

    @Override
    public UserDetails loadUserByUsername(String login) throws UsernameNotFoundException {
        Customer customer = customerRepository.findByLogin(login)
                .orElseThrow(() -> new UsernameNotFoundException("Customer not found"));

        String role = customer.isAdmin() ? "ROLE_ADMIN" : "ROLE_USER";

        return org.springframework.security.core.userdetails.User.builder()
                .username(customer.getLogin())
                .password(customer.getPassword())
                .authorities(Collections.singletonList(new SimpleGrantedAuthority(role)))
                .build();
    }
}
