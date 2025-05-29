package com.github.ywoosang.application;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.github.ywoosang.domain.Stock;
import com.github.ywoosang.domain.StockNotFoundException;
import com.github.ywoosang.domain.StockRepository;

@Service
public class DecreaseStockServiceV1 {
    private static final Logger log = LoggerFactory.getLogger(DecreaseStockServiceV1.class);

    private final StockRepository stockRepository;
    private final StockDecreaseAlarmSender stockDecreaseAlarmSender;
    private final StockDecreaseHistoryRecorder stockDecreaseHistoryRecorder;


    public DecreaseStockServiceV1(StockRepository stockRepository,
        StockDecreaseAlarmSender stockDecreaseAlarmSender, StockDecreaseHistoryRecorder stockDecreaseHistoryRecorder
    ) {
        this.stockRepository = stockRepository;
        this.stockDecreaseAlarmSender = stockDecreaseAlarmSender;
        this.stockDecreaseHistoryRecorder = stockDecreaseHistoryRecorder;
    }

    @Transactional
    public void decrease(DecreaseStockCommand cmd) {
            log.info("재고 감소 로직 실행");
            Stock stock = stockRepository.findByProductId(cmd.productId()).orElseThrow(StockNotFoundException::new);
            stock.decrease(cmd.quantity());
            stockRepository.update(stock);

            // 비관심사1: 재고 감소 이력 저장 (단순 저장용, 도메인에서 비즈니스로직으로 사용하지 않는다고 가정)
            stockDecreaseHistoryRecorder.record(stock.getId(), stock.getQuantity());

            // 비관심사2: 재고 감소 알림 전송
            log.info("재고 감소 알림 전송");
            stockDecreaseAlarmSender.send(stock.getId(), stock.getQuantity());
    }
}
