package com.github.ywoosang.infrastructure;

import org.springframework.stereotype.Component;

import com.github.ywoosang.application.StockDecreaseAlarmSender;

@Component
public class StockDecreaseAlarmSenderImpl implements StockDecreaseAlarmSender {

    @Override
    public void send(long stockId, int quantity) {
        try {
            Thread.sleep(1000);
        } catch(InterruptedException e) {
            e.printStackTrace();
        }
    }
}
