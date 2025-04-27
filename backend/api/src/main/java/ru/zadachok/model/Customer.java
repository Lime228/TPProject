// model/Customer.java
package ru.zadachok.model;

import jakarta.persistence.*;
import lombok.*;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.util.Collection;
import java.sql.Date;
import java.util.List;

@Entity
@Table(name = "\"customer\"", schema = "\"tp\"")  // Указываем схему и таблицу
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Customer implements UserDetails {  // Для интеграции со Spring Security

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "\"customer_id\"")
    private Integer customer_ID;

    @Column(name = "\"customer_name\"", nullable = false)
    private String customer_name;

    @Column(name = "\"customer_email\"", nullable = false, unique = true)
    private String customer_email;

    @Column(name = "\"password\"", nullable = false)
    private String password;

    @Column(name = "\"birthday_date\"")
    private Date birthday_date;

    @Column(name = "\"login\"", nullable = false, unique = true)
    private String login;

    @Column(name = "\"admin\"", nullable = false)
    private boolean admin;

    // Для Spring Security
    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return List.of(new SimpleGrantedAuthority(admin ? "ROLE_ADMIN" : "ROLE_USER"));
    }

    @Override
    public String getUsername() {
        return login;  // Используем login как username для Security
    }

    @Override
    public boolean isAccountNonExpired() {
        return true;
    }

    @Override
    public boolean isAccountNonLocked() {
        return true;
    }

    @Override
    public boolean isCredentialsNonExpired() {
        return true;
    }

    @Override
    public boolean isEnabled() {
        return true;
    }
}