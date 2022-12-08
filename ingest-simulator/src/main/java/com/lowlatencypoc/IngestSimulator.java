package com.lowlatencypoc;

import com.azure.messaging.eventhubs.EventDataBatch;
import com.azure.messaging.eventhubs.EventHubClientBuilder;
import com.azure.messaging.eventhubs.EventHubProducerClient;
import com.azure.messaging.eventhubs.EventData;
import io.micronaut.scheduling.annotation.Scheduled;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import com.azure.identity.DefaultAzureCredential;
import jakarta.inject.Singleton;
import java.time.Instant;
import com.azure.identity.DefaultAzureCredentialBuilder;
import com.azure.messaging.eventhubs.models.PartitionContext;
import com.azure.messaging.eventhubs.EventProcessorClientBuilder;
import com.azure.messaging.eventhubs.EventProcessorClient;
import com.azure.storage.blob.BlobContainerClientBuilder;
import com.azure.storage.blob.BlobContainerAsyncClient;
import com.azure.messaging.eventhubs.checkpointstore.blob.BlobCheckpointStore;

@Singleton
public class IngestSimulator {
    private static final Logger LOG = LoggerFactory.getLogger(IngestSimulator.class);
    private EventHubProducerClient client;
    private EventProcessorClient consumer;

    public IngestSimulator() {
        LOG.info("IngestSimulator constructor");

        DefaultAzureCredential defaultCredential = new DefaultAzureCredentialBuilder().build();

        this.client = new EventHubClientBuilder()
            .credential("tikseventhubnsdev.servicebus.windows.net", "ticks", defaultCredential)
            //.connectionString("<connectionString>", "ticks") - In case you don't want to use workload identity
            .buildProducerClient();

        setupConsumer();
    }

    @Scheduled(fixedRate = "10s")
    public void sendEvent() {
        long now = Instant.now().toEpochMilli();
        // long to String 
        String eventBody = String.valueOf(now);
        EventData eventData = new EventData(eventBody);
        EventDataBatch eventDataBatch = client.createBatch();        
        eventDataBatch.tryAdd(eventData);
        client.send(eventDataBatch);
        LOG.info("Sent event: {}", eventBody);
    }


    private void setupConsumer() {
        BlobContainerAsyncClient blobContainerAsyncClient = new BlobContainerClientBuilder()
        .connectionString("<connectionString>")
        .containerName("<containerName>")
        .buildAsyncClient();
        
        DefaultAzureCredential defaultCredential = new DefaultAzureCredentialBuilder().build();
        EventProcessorClientBuilder eventProcessorClientBuilder = new EventProcessorClientBuilder()
        .credential("tikseventhubnsdev.servicebus.windows.net", "ticks", defaultCredential)
        //.connectionString("<connectionString>", "ticks") - In case you don't want to use workload identity
        .consumerGroup(EventHubClientBuilder.DEFAULT_CONSUMER_GROUP_NAME)
        .checkpointStore(new BlobCheckpointStore(blobContainerAsyncClient))
        .processEvent(eventContext -> {
                PartitionContext partitionContext = eventContext.getPartitionContext();
                EventData eventData = eventContext.getEventData();
                String body = new String(eventData.getBody());
                Instant now = Instant.now();
                long timeDifference = now.toEpochMilli() - Long.parseLong(body);
                // Print the time difference to the log.
                LOG.info("⌛🚀 Time difference: " + timeDifference + "ms");
            })
        .processError(eventContext -> {
                LOG.error("Error occurred in partition processor for partition %s, %s.%n",
                    eventContext.getPartitionContext().getPartitionId(), eventContext.getThrowable().toString());
            });

        consumer = eventProcessorClientBuilder.buildEventProcessorClient();
        consumer.start();
    }
}