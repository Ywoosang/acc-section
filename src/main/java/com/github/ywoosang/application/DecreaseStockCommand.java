package com.github.ywoosang.application;

public record DecreaseStockCommand(
    long productId,
    int quantity
) {

}
