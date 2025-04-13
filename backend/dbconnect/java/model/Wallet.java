package model;

public class Wallet {
    private int walletId;
    private int customerId;
    private int lobbyId;
    private int balance;

    public Wallet(int walletId, int customerId, int lobbyId, int balance) {
        this.walletId = walletId;
        this.customerId = customerId;
        this.lobbyId = lobbyId;
        this.balance = balance;
    }

    public Wallet(int customerId, int lobbyId, int balance) {
        this.customerId = customerId;
        this.lobbyId = lobbyId;
        this.balance = balance;
    }

    // геттеры и сеттеры

    public int getWalletId() {
        return walletId;
    }

    public int getCustomerId() {
        return customerId;
    }

    public int getLobbyId() {
        return lobbyId;
    }

    public int getBalance() {
        return balance;
    }

    public void setCustomerId(int customerId) {
        this.customerId = customerId;
    }

    public void setLobbyId(int lobbyId) {
        this.lobbyId = lobbyId;
    }

    public void setBalance(int balance) {
        this.balance = balance;
    }
}
