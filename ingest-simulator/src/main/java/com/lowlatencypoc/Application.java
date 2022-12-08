package com.lowlatencypoc;

import io.micronaut.runtime.Micronaut;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class Application {
    private static final Logger LOG = LoggerFactory.getLogger(Application.class);

    public static void main(String[] args) {
        // Starting Up Log
        LOG.info("Starting..");

        Micronaut.run(Application.class, args);
        
        // Ensure Micronaut keeps running
        while (true) {
            try {
                Thread.sleep(1000);
            } catch (InterruptedException e) {
            }
        } 



    }
}