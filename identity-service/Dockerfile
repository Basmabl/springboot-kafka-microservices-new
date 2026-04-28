FROM eclipse-temurin:17

WORKDIR /app

COPY target/identity-service.jar /app/identity-service.jar

EXPOSE 9898

ENTRYPOINT ["java", "-jar", "/app/identity-service.jar"]



