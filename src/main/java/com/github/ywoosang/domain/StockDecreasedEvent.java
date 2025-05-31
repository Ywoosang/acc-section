package com.github.ywoosang.domain;

public final class StockDecreasedEvent extends DomainEvent<StockDecreasedEventPayload> {

    public StockDecreasedEvent(String traceId, StockDecreasedEventPayload payload) {
        super(traceId, payload);
    }
}
