package com.github.ywoosang.domain;

import java.time.LocalDateTime;

public abstract class DomainEvent<T extends Payload> {

    private final String traceId;

    private final T payload;

    private final LocalDateTime occurredAt;

    protected DomainEvent(String traceId, T payload) {
        this.traceId = traceId;
        this.payload = payload;
        this.occurredAt = LocalDateTime.now();
    }

    public String getTraceId() {
        return traceId;
    }

    public T getPayload() {
        return payload;
    }

    public LocalDateTime getOccurredAt() {
        return occurredAt;
    }
}
