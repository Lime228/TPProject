// request/UpdateProductRequest.java
package ru.zadachok.request;

import lombok.Data;

@Data
public class UpdateProductRequest {
    private Integer productId;
    private String name;
    private String description;
    private byte[] photo;
    private Boolean state;
    private Integer price;
}
