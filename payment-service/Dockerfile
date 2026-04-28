FROM eclipse-temurin:17

WORKDIR /app

COPY target/payment-service.jar /app/payment-service.jar

EXPOSE 8085

ENTRYPOINT ["java", "-jar", "/app/payment-service.jar"]



