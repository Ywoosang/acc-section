package com.github.ywoosang.domain;

import org.springframework.util.Assert;

public class Stock {

    private final long id;

    private final long productId;

    private int quantity;

    public static Stock create(Integer productId, Integer quantity) {
        Assert.notNull(productId, "재고 수량은 Null 일 수 없습니다.");
        Assert.isTrue(productId >= 1, "상품 ID 는 1 이상이어야 합니다.");
        Assert.notNull(quantity, "재고 수량은 Null 일 수 없습니다.");
        Assert.isTrue(quantity >= 1, "재고 수량은 1개 이상이어야 합니다.");
        return new Stock(-1L, productId, quantity);
    }

    public Stock(long id, long productId, int quantity) {
        this.id = id;
        this.productId = productId;
        this.quantity = quantity;
    }

    public void decrease(int quantity) {
        this.quantity -= quantity;
    }

    public void increase(int quantity) {
        this.quantity += quantity;
    }

    public long getId() {
        return id;
    }

    public long getProductId() {
        return productId;
    }

    public int getQuantity() {
        return quantity;
    }
}