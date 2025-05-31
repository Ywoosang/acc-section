package com.github.ywoosang.application;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Async;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.event.TransactionPhase;
import org.springframework.transaction.event.TransactionalEventListener;

import com.github.ywoosang.domain.StockDecreasedEvent;
import com.github.ywoosang.domain.StockDecreasedEventPayload;

public class StockDecreaseApplicationEventHandler {

    private static final Logger log = LoggerFactory.getLogger(StockDecreaseApplicationEventHandler.class);

    private final StockDecreaseAlarmSender stockDecreaseAlarmSender;
    private final StockDecreaseHistoryRecorder stockDecreaseHistoryRecorder;

    public StockDecreaseApplicationEventHandler(StockDecreaseAlarmSender stockDecreaseAlarmSender,
        StockDecreaseHistoryRecorder stockDecreaseHistoryRecorder
    ) {
        this.stockDecreaseAlarmSender = stockDecreaseAlarmSender;
        this.stockDecreaseHistoryRecorder = stockDecreaseHistoryRecorder;
    }

    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
    @Async
    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void handleStockDecreaseEvent(StockDecreasedEvent event) {
        StockDecreasedEventPayload payload = event.getPayload();

        log.info("재고 감소 이력 저장");
        stockDecreaseHistoryRecorder.record(payload.stockId(), payload.quantity());

        log.info("재고 감소 알림 전송");
        stockDecreaseAlarmSender.send(payload.stockId(), payload.quantity());

        // TODO: 필요시 외부 이벤트 발행
    }
}
