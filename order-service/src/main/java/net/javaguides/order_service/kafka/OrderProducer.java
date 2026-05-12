package net.javaguides.order_service.kafka;

import net.javaguides.common_lib.dto.order.OrderEvent;
import net.javaguides.common_lib.encryption.EncryptionService;
import org.apache.kafka.clients.admin.NewTopic;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.kafka.support.KafkaHeaders;
import org.springframework.messaging.Message;
import org.springframework.messaging.support.MessageBuilder;
import org.springframework.stereotype.Service;

@Service
public class OrderProducer {
    private static final Logger LOGGER = LoggerFactory.getLogger(OrderProducer.class);
    private final NewTopic topic;
    private final KafkaTemplate<String, OrderEvent> kafkaTemplate;
    private final EncryptionService encryptionService;

    public OrderProducer(NewTopic topic, 
                         KafkaTemplate<String, OrderEvent> kafkaTemplate,
                         EncryptionService encryptionService) {
        this.topic = topic;
        this.kafkaTemplate = kafkaTemplate;
        this.encryptionService = encryptionService;
    }

    public void sendMessage(OrderEvent orderEvent){
        LOGGER.info("OrderDTO event AVANT chiffrement => email = {}", orderEvent.getEmail());
        
        // Chiffrer l'email (donnee sensible RGPD)
        if (orderEvent.getEmail() != null) {
            String encryptedEmail = encryptionService.encrypt(orderEvent.getEmail());
            orderEvent.setEmail(encryptedEmail);
        }
        
        LOGGER.info("OrderDTO event APRES chiffrement => email = {}", orderEvent.getEmail());

        Message<OrderEvent> message = MessageBuilder.withPayload(orderEvent)
                .setHeader(KafkaHeaders.TOPIC, topic.name())
                .build();
        kafkaTemplate.send(message);
    }
}