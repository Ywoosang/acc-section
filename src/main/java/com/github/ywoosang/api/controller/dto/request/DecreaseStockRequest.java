package com.github.ywoosang.api.controller.dto.request;

import com.github.ywoosang.application.DecreaseStockCommand;

public record DecreaseStockRequest(
    Long productId,
    Integer quantity
) {

    public DecreaseStockCommand toCommand() {
        return new DecreaseStockCommand(productId, quantity);
    }
}
