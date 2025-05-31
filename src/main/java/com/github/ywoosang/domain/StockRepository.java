package com.github.ywoosang.domain;

import java.util.Optional;

public interface StockRepository {

    Optional<Stock> findByProductId(long productId);

    void update(Stock stock);
}
