package ru.zadachok.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import ru.zadachok.model.Customer;
import ru.zadachok.model.Product;
import ru.zadachok.model.Shop;
import ru.zadachok.model.Wallet;
import ru.zadachok.repository.CustomerRepository;
import ru.zadachok.repository.ProductRepository;
import ru.zadachok.repository.ShopRepository;
import ru.zadachok.repository.WalletRepository;
import ru.zadachok.request.DeleteProductRequest;
import ru.zadachok.request.ProductBuyRequest;
import ru.zadachok.request.ProductCreateRequest;
import ru.zadachok.request.UpdateProductRequest;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

@Service
@RequiredArgsConstructor
public class ShopService {

    private final ProductRepository productRepository;
    private final ShopRepository shopRepository;
    private final CustomerRepository customerRepository;
    private final WalletRepository walletRepository;

    public Product createProductForShop(ProductCreateRequest request) {
        Shop shop = shopRepository.findById(request.getShopId())
                .orElseThrow(() -> new IllegalArgumentException("Shop not found"));

        Customer customer = customerRepository.findById(request.getCustomerId())
                .orElseThrow(() -> new IllegalArgumentException("Customer not found"));

        Product product = Product.builder()
                .name(request.getName())
                .description(request.getDescription())
                .photo(request.getPhoto())
                .state(request.isState())
                .price(request.getPrice())
                .customer(customer)
                .build();

        Product savedProduct = productRepository.save(product);

        // Добавим productId в Shop
        List<Integer> ids = new ArrayList<>(Arrays.asList(shop.getProductId()));
        ids.add(savedProduct.getId());
        shop.setProductId(ids.toArray(new Integer[0]));

        shopRepository.save(shop);

        return savedProduct;
    }
    // service/ShopService.java
    public void deleteProduct(DeleteProductRequest request) {
        Shop shop = shopRepository.findById(request.getShopId())
                .orElseThrow(() -> new RuntimeException("Магазин не найден"));

        // Удалим productId из списка в магазине
        List<Integer> ids = new ArrayList<>(Arrays.asList(shop.getProductId()));
        if (!ids.remove(request.getProductId())) {
            throw new RuntimeException("Продукт не найден в списке магазина");
        }
        shop.setProductId(ids.toArray(new Integer[0]));
        shopRepository.save(shop);

        // Удалим сам продукт из таблицы Product
        productRepository.deleteById(request.getProductId());
    }
    public Product updateProduct(UpdateProductRequest request) {
        Product product = productRepository.findById(request.getProductId())
                .orElseThrow(() -> new RuntimeException("Продукт не найден"));

        if (request.getName() != null) product.setName(request.getName());
        if (request.getDescription() != null) product.setDescription(request.getDescription());
        if (request.getPhoto() != null) product.setPhoto(request.getPhoto());
        if (request.getState() != null) product.setState(request.getState());
        if (request.getPrice() != null) product.setPrice(request.getPrice());

        return productRepository.save(product);
    }

    public String buyProduct(ProductBuyRequest request) {
        Product product = productRepository.findById(request.getProductId())
                .orElseThrow(() -> new RuntimeException("Продукт не найден"));

        Wallet wallet = walletRepository.findByCustomerId(request.getCustomerId())
                .orElseThrow(() -> new RuntimeException("Кошелек не найден"));

        if (wallet.getBalance() < product.getPrice()) {
            throw new RuntimeException("Недостаточно средств на балансе");
        }

        wallet.setBalance(wallet.getBalance() - product.getPrice());
        walletRepository.save(wallet);

        return "Покупка прошла успешно. Остаток: " + wallet.getBalance();
    }

    public Shop getShopById(Integer shopId) {
        return shopRepository.findById(shopId)
                .orElseThrow(() -> new RuntimeException("Магазин с ID " + shopId + " не найден"));
    }

    public Product getProductById(Integer productId) {
        return productRepository.findById(productId)
                .orElseThrow(() -> new RuntimeException("Магазин с ID " + productId + " не найден"));
    }
}
