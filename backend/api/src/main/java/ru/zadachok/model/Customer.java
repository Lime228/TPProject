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
@Table(name = "\"Customer\"", schema = "\"TP\"")  // Указываем схему и таблицу
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Customer implements UserDetails {  // Для интеграции со Spring Security

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "\"Customer_ID\"")
    private Integer id;

    @Column(name = "\"Customer_name\"", nullable = false)
    private String name;

    @Column(name = "\"Customer_email\"", nullable = false, unique = true)
    private String email;

    @Column(name = "\"Password\"", nullable = false)
    private String password;

    @Column(name = "\"Birthday_date\"")
    private Date birthday;

    @Column(name = "\"Login\"", nullable = false, unique = true)
    private String login;

    @Column(name = "\"Admin\"", nullable = false)
    private boolean isAdmin;

    // Для Spring Security
    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return List.of(new SimpleGrantedAuthority(isAdmin ? "ROLE_ADMIN" : "ROLE_USER"));
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