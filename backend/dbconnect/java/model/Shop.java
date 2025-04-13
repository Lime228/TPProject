package model;

public class Shop {
    private int shopId;
    private int productId;
    private int quantity;

    public Shop(int shopId, int productId, int quantity) {
        this.shopId = shopId;
        this.productId = productId;
        this.quantity = quantity;
    }

    public Shop(int productId, int quantity) {
        this.productId = productId;
        this.quantity = quantity;
    }

    public int getShopId() {
        return shopId;
    }

    public int getProductId() {
        return productId;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setProductId(int productId) {
        this.productId = productId;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }
}
