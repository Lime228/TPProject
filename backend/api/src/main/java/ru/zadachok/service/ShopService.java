package ru.zadachok.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import ru.zadachok.model.Customer;
import ru.zadachok.model.Product;
import ru.zadachok.model.Shop;
import ru.zadachok.repository.CustomerRepository;
import ru.zadachok.repository.ProductRepository;
import ru.zadachok.repository.ShopRepository;
import ru.zadachok.request.ProductCreateRequest;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

@Service
@RequiredArgsConstructor
public class ShopService {

    private final ProductRepository productRepository;
    private final ShopRepository shopRepository;
    private final CustomerRepository customerRepository;

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
}
