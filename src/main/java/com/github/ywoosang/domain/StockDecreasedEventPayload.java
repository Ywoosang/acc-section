package com.github.ywoosang.domain;

public record StockDecreasedEventPayload(
    long stockId,
    long productId,
    int quantity
) implements Payload {}
