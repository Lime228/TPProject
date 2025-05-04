package ru.zadachok.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import ru.zadachok.model.Product;
import ru.zadachok.request.DeleteProductRequest;
import ru.zadachok.request.ProductCreateRequest;
import ru.zadachok.request.UpdateProductRequest;
import ru.zadachok.service.ShopService;

@RestController
@RequestMapping("/api/shop")
@RequiredArgsConstructor
public class ShopController {

    private final ShopService shopService;

    @PostMapping("/product/create") // POST — создание ресурса
    public ResponseEntity<Product> createProduct(@RequestBody ProductCreateRequest request) {
        Product createdProduct = shopService.createProductForShop(request);
        return ResponseEntity.ok(createdProduct);
    }

    @DeleteMapping("/product/delete") // DELETE — удаление ресурса
    public ResponseEntity<String> deleteProduct(@RequestBody DeleteProductRequest request) {
        shopService.deleteProduct(request);
        return ResponseEntity.ok("Продукт удалён успешно");
    }

    @PatchMapping("/product/update") // PATCH — частичное обновление ресурса
    public ResponseEntity<Product> updateProduct(@RequestBody UpdateProductRequest request) {
        Product updatedProduct = shopService.updateProduct(request);
        return ResponseEntity.ok(updatedProduct);
    }
}
