package com.github.ywoosang;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableAsync;

@SpringBootApplication
@EnableAsync
public class AccApplication {

    public static void main(String[] args) {
        SpringApplication.run(AccApplication.class, args);
    }

}
