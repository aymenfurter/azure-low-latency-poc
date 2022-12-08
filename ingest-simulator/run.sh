#!/usr/bin/env bash

# Build the ingest-simulator application using Maven
mvn clean package

# Run the ingest-simulator JAR file
java -jar target/ingest-simulator-1.0.0-SNAPSHOT.jar
