package com.github.ywoosang.infrastructure;

import java.util.Optional;

import org.springframework.stereotype.Repository;

import com.github.ywoosang.domain.Stock;
import com.github.ywoosang.domain.StockRepository;

@Repository
public class StockRepositoryImpl implements StockRepository {

    @Override
    public Optional<Stock> findByProductId(long productId) {
        try {
            Stock stock = new Stock(1L, productId, Integer.MAX_VALUE);
            Thread.sleep(100);
            return Optional.of(stock);
        } catch (InterruptedException e) {
            throw new DatabaseException();
        }
    }

    @Override
    public void update(Stock stock) {
        try {
            Thread.sleep(500);
        } catch (InterruptedException e) {
            e.printStackTrace();
            throw new DatabaseException();
        }
    }
}
