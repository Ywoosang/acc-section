package com.github.ywoosang.api.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.github.ywoosang.api.controller.dto.request.DecreaseStockRequest;
import com.github.ywoosang.application.DecreaseStockServiceV2;

@RestController
@RequestMapping("/api/v2/stocks")
public class StockControllerV2 {

    private final DecreaseStockServiceV2 decreaseStockService;

    public StockControllerV2(DecreaseStockServiceV2 decreaseStockService) {
        this.decreaseStockService = decreaseStockService;
    }

    @PostMapping("/decrease")
    public ResponseEntity<Void> decreaseStock(
        @RequestBody DecreaseStockRequest request
    ) {
        decreaseStockService.decrease(request.toCommand());
        return ResponseEntity.noContent().build();
    }
}
