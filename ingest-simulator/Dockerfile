FROM mcr.microsoft.com/openjdk/jdk:11-mariner

# Add the built artifact to the container.
ADD target/ingest-simulator-1.0.0-SNAPSHOT.jar /app/ingest-simulator.jar

ENTRYPOINT ["java", "-jar", "/app/ingest-simulator.jar"]
