package com.github.ywoosang.application;

public interface StockDecreaseAlarmSender {
    void send(long stockId, int quantity);
}
