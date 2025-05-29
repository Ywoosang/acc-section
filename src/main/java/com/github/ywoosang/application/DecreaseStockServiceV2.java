package com.github.ywoosang.application;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.slf4j.MDC;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.github.ywoosang.domain.Stock;
import com.github.ywoosang.domain.StockDecreasedEvent;
import com.github.ywoosang.domain.StockDecreasedEventPayload;
import com.github.ywoosang.domain.StockNotFoundException;
import com.github.ywoosang.domain.StockRepository;

@Service
public class DecreaseStockServiceV2 {
    private static final Logger log = LoggerFactory.getLogger(DecreaseStockServiceV1.class);

    private final StockRepository stockRepository;
    private final ApplicationEventPublisher eventPublisher;

    public DecreaseStockServiceV2(StockRepository stockRepository, ApplicationEventPublisher eventPublisher) {
        this.stockRepository = stockRepository;
        this.eventPublisher = eventPublisher;
    }

    @Transactional
    public void decrease(DecreaseStockCommand cmd) {
        log.info("재고 감소 로직 실행");
        Stock stock = stockRepository.findByProductId(cmd.productId()).orElseThrow(StockNotFoundException::new);
        stock.decrease(cmd.quantity());
        stockRepository.update(stock);

        log.info("재고 감소 Application 이벤트 발행");
        eventPublisher.publishEvent(new StockDecreasedEvent(
            MDC.get("traceId"),
            new StockDecreasedEventPayload(
                stock.getId(),
                stock.getProductId(),
                stock.getQuantity()
            )
        ));
    }
}
