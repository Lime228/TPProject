package ru.zadachok.service;

import lombok.RequiredArgsConstructor;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class EmailSenderService {

    private final JavaMailSender mailSender;

    // В будущем сюда будем передавать сгенерированный код
    public void sendCode(String toEmail, String code) {
        SimpleMailMessage message = new SimpleMailMessage();
        message.setTo(toEmail);
        message.setSubject("Восстановление пароля");
        message.setText("Ваш код для восстановления пароля: " + code);
        mailSender.send(message);
    }
}

