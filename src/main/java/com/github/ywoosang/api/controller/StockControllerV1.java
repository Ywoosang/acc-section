package com.github.ywoosang.api.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.github.ywoosang.api.controller.dto.request.DecreaseStockRequest;
import com.github.ywoosang.application.DecreaseStockServiceV1;

@RestController
@RequestMapping("/api/v1/stocks")
public class StockControllerV1 {

    private final DecreaseStockServiceV1 decreaseStockService;

    public StockControllerV1(DecreaseStockServiceV1 decreaseStockService) {
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
