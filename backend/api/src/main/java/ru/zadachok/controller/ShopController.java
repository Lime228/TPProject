package ru.zadachok.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import ru.zadachok.model.Lobby;
import ru.zadachok.model.Product;
import ru.zadachok.model.Shop;
import ru.zadachok.request.DeleteProductRequest;
import ru.zadachok.request.ProductBuyRequest;
import ru.zadachok.request.ProductCreateRequest;
import ru.zadachok.request.UpdateProductRequest;
import ru.zadachok.service.ShopService;

@RestController
@RequestMapping("/api/shop")
@RequiredArgsConstructor
@Tag(name = "Shop Management", description = "Управление магазином")
public class ShopController {

    private final ShopService shopService;

    @Operation(
            summary = "Создать новый товар",
            description = "Создает новый товар с указанными параметрами"
    )
    @ApiResponses(value = {
            @ApiResponse(
                    responseCode = "200",
                    description = "Товар успешно создан",
                    content = @Content(
                            mediaType = "application/json",
                            schema = @Schema(implementation = Product.class)
                    )
            ),
            @ApiResponse(
                    responseCode = "400",
                    description = "Неверные параметры запроса",
                    content = @Content
            ),
            @ApiResponse(
                    responseCode = "403",
                    description = "Доступ запрещен",
                    content = @Content
            )
    })
    @PostMapping("/product/create") // POST — создание ресурса
    public ResponseEntity<Product> createProduct(@RequestBody ProductCreateRequest request) {
        Product createdProduct = shopService.createProductForShop(request);
        return ResponseEntity.ok(createdProduct);
    }

    @Operation(
            summary = "Удалить товар",
            description = "Удаляет товар по ID"
    )
    @ApiResponses(value = {
            @ApiResponse(
                    responseCode = "200",
                    description = "Товар успешно удален",
                    content = @Content(
                            mediaType = "application/json",
                            schema = @Schema(example = "Продукт удалён успешно")
                    )
            ),
            @ApiResponse(
                    responseCode = "400",
                    description = "Неверные параметры запроса",
                    content = @Content
            ),
            @ApiResponse(
                    responseCode = "404",
                    description = "Товар не найден",
                    content = @Content
            ),
            @ApiResponse(
                    responseCode = "403",
                    description = "Доступ запрещен",
                    content = @Content
            )
    })
    @DeleteMapping("/product/delete") // DELETE — удаление ресурса
    public ResponseEntity<String> deleteProduct(@RequestBody DeleteProductRequest request) {
        shopService.deleteProduct(request);
        return ResponseEntity.ok("Продукт удалён успешно");
    }

    @Operation(
            summary = "Обновить товар",
            description = "Обновляет информацию о товаре"
    )
    @ApiResponses(value = {
            @ApiResponse(
                    responseCode = "200",
                    description = "Товар успешно обновлен",
                    content = @Content(
                            mediaType = "application/json",
                            schema = @Schema(implementation = Product.class)
                    )
            ),
            @ApiResponse(
                    responseCode = "400",
                    description = "Неверные параметры запроса",
                    content = @Content
            ),
            @ApiResponse(
                    responseCode = "404",
                    description = "Товар не найден",
                    content = @Content
            ),
            @ApiResponse(
                    responseCode = "403",
                    description = "Доступ запрещен",
                    content = @Content
            )
    })
    @PatchMapping("/product/update") // PATCH — частичное обновление ресурса
    public ResponseEntity<Product> updateProduct(@RequestBody UpdateProductRequest request) {
        Product updatedProduct = shopService.updateProduct(request);
        return ResponseEntity.ok(updatedProduct);
    }

    @Operation(
            summary = "Покупка товара",
            description = "Проверяет баланс пользователя и списывает деньги за товар"
    )
    @ApiResponses(value = {
            @ApiResponse(
                    responseCode = "200",
                    description = "Покупка успешна",
                    content = @Content(mediaType = "application/json", schema = @Schema(example = "Покупка прошла успешно. Остаток: 9500"))
            ),
            @ApiResponse(
                    responseCode = "400",
                    description = "Неверный запрос или недостаточно средств",
                    content = @Content
            ),
            @ApiResponse(
                    responseCode = "404",
                    description = "Товар или кошелек не найдены",
                    content = @Content
            )
    })
    @PostMapping("/product/buy") // POST — совершение действия
    public ResponseEntity<String> buyProduct(@RequestBody ProductBuyRequest request) {
        String message = shopService.buyProduct(request);
        return ResponseEntity.ok(message);
    }

    @GetMapping("/{id}")
    public ResponseEntity<Shop> getLobby(@PathVariable int id) {
        Shop gettedShop = shopService.getShopById(id);
        return ResponseEntity.ok(gettedShop);
    }
    @GetMapping("/product/{id}")
    public ResponseEntity<Product> getProduct(@PathVariable int id) {
        Product gettedProduct = shopService.getProductById(id);
        return ResponseEntity.ok(gettedProduct);
    }

}
