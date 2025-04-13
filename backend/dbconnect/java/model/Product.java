package model;

public class Product {
    private int id;
    private String name;
    private String description;
    private byte[] photo;
    private int state;
    private int price;
    private Integer customerId; // Может быть null

    public Product(int id, String name, String description, byte[] photo, int state, int price, Integer customerId) {
        this.id = id;
        this.name = name;
        this.description = description;
        this.photo = photo;
        this.state = state;
        this.price = price;
        this.customerId = customerId;
    }

    public Product(String name, String description, byte[] photo, int state, int price, Integer customerId) {
        this(0, name, description, photo, state, price, customerId);
    }

    // Геттеры и сеттеры (можешь сгенерировать в IDE)
    public int getId() { return id; }
    public String getName() { return name; }
    public String getDescription() { return description; }
    public byte[] getPhoto() { return photo; }
    public int getState() { return state; }
    public int getPrice() { return price; }
    public Integer getCustomerId() { return customerId; }

    public void setId(int id) { this.id = id; }
    public void setName(String name) { this.name = name; }
    public void setDescription(String description) { this.description = description; }
    public void setPhoto(byte[] photo) { this.photo = photo; }
    public void setState(int state) { this.state = state; }
    public void setPrice(int price) { this.price = price; }
    public void setCustomerId(Integer customerId) { this.customerId = customerId; }
}
