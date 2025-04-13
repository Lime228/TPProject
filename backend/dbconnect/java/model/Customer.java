package model;

import java.sql.Date;

public class Customer {
    private int id;
    private String name;
    private String email;
    private String password;
    private Date birthday;
    private String login;
    private boolean isAdmin;

    public Customer(int id, String name, String email, String password, Date birthday, String login, boolean isAdmin) {
        this.id = id;
        this.name = name;
        this.email = email;
        this.password = password;
        this.birthday = birthday;
        this.login = login;
        this.isAdmin = isAdmin;
    }

    public Customer(String name, String email, String password, Date birthday, String login, boolean isAdmin) {
        this(0, name, email, password, birthday, login, isAdmin);
    }

    // Геттеры и сеттеры (можно сгенерировать автоматически в IDE)
    // ...

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getName() { return name; }
    public String getEmail() { return email; }
    public String getPassword() { return password; }
    public Date getBirthday() { return birthday; }
    public String getLogin() { return login; }
    public boolean isAdmin() { return isAdmin; }


    public void setName(String name) { this.name = name; }
    public void setEmail(String email) { this.email = email; }
    public void setPassword(String password) { this.password = password; }
    public void setBirthday(Date birthday) { this.birthday = birthday; }
    public void setLogin(String login) { this.login = login; }
    public void setAdmin(boolean admin) { isAdmin = admin; }
}
