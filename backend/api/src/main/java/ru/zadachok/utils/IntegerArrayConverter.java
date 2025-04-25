// utils/IntegerArrayConverter.java
package ru.zadachok.utils;

import jakarta.persistence.AttributeConverter;
import jakarta.persistence.Converter;

@Converter
public class IntegerArrayConverter implements AttributeConverter<Integer[], String> {

    @Override
    public String convertToDatabaseColumn(Integer[] attribute) {
        if (attribute == null || attribute.length == 0) return "{}";
        StringBuilder sb = new StringBuilder("{");
        for (int i = 0; i < attribute.length; i++) {
            sb.append(attribute[i]);
            if (i < attribute.length - 1) sb.append(",");
        }
        sb.append("}");
        return sb.toString();
    }

    @Override
    public Integer[] convertToEntityAttribute(String dbData) {
        if (dbData == null || dbData.equals("{}") || dbData.length() < 3) return new Integer[0];
        String[] parts = dbData.replaceAll("[{}]", "").split(",");
        Integer[] result = new Integer[parts.length];
        for (int i = 0; i < parts.length; i++) {
            result[i] = Integer.parseInt(parts[i].trim());
        }
        return result;
    }
}
