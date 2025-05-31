package com.github.ywoosang.application;

public interface StockDecreaseHistoryRecorder {

    void record(long stockId, int quantity);
}
