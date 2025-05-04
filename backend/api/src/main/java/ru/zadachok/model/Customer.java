package ru.zadachok.model;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.persistence.*;
import lombok.*;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.util.Collection;
import java.sql.Date;
import java.util.List;

@Entity
@Table(name = "\"customer\"", schema = "\"tp\"")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "Модель пользователя системы")
public class Customer implements UserDetails {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "\"customer_id\"")
    @Schema(description = "Уникальный ID пользователя",
            example = "1",
            accessMode = Schema.AccessMode.READ_ONLY)
    private Integer customer_ID;

    @Column(name = "\"customer_name\"", nullable = false)
    @Schema(description = "Полное имя пользователя",
            example = "Иван Иванов",
            requiredMode = Schema.RequiredMode.REQUIRED,
            minLength = 2,
            maxLength = 100)
    private String customer_name;

    @Column(name = "\"customer_email\"", nullable = false, unique = true)
    @Schema(description = "Email пользователя",
            example = "user@example.com",
            format = "email",
            requiredMode = Schema.RequiredMode.REQUIRED)
    private String customer_email;

    @Column(name = "\"password\"", nullable = false)
    @Schema(description = "Зашифрованный пароль пользователя",
            example = "$2a$10$N9qo8uLOickgx2ZMRZoMy...",
            requiredMode = Schema.RequiredMode.REQUIRED,
            accessMode = Schema.AccessMode.WRITE_ONLY)
    private String password;

    @Column(name = "\"birthday_date\"")
    @Schema(description = "Дата рождения пользователя",
            example = "1990-01-15",
            format = "date")
    private Date birthday_date;

    @Column(name = "\"login\"", nullable = false, unique = true)
    @Schema(description = "Уникальный логин для входа в систему",
            example = "user123",
            requiredMode = Schema.RequiredMode.REQUIRED,
            minLength = 3,
            maxLength = 50)
    private String login;

    @Column(name = "\"customer_photo\"")
    @Schema(description = "Фотография пользователя в бинарном формате",
            format = "byte",
            accessMode = Schema.AccessMode.READ_ONLY)
    private byte[] customer_photo;

    @Column(name = "\"admin\"", nullable = false)
    @Schema(description = "Флаг администратора системы",
            example = "false",
            defaultValue = "false")
    private boolean admin;

    // Методы Spring Security
    @Override
    @Schema(hidden = true)
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return List.of(new SimpleGrantedAuthority(admin ? "ROLE_ADMIN" : "ROLE_USER"));
    }

    @Override
    @Schema(hidden = true)
    public String getUsername() {
        return login;
    }

    @Override
    @Schema(hidden = true)
    public boolean isAccountNonExpired() {
        return true;
    }

    @Override
    @Schema(hidden = true)
    public boolean isAccountNonLocked() {
        return true;
    }

    @Override
    @Schema(hidden = true)
    public boolean isCredentialsNonExpired() {
        return true;
    }

    @Override
    @Schema(hidden = true)
    public boolean isEnabled() {
        return true;
    }
}