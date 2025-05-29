package com.github.ywoosang.infrastructure;

import org.springframework.stereotype.Component;

import com.github.ywoosang.application.StockDecreaseHistoryRecorder;

@Component
public class StockDecreaseHistoryRecorderImpl implements StockDecreaseHistoryRecorder {

    @Override
    public void record(long stockId, int quantity) {
        try {
            Thread.sleep(500);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
    }
}
