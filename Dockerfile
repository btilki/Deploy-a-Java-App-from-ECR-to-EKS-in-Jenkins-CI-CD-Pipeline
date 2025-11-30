# Use Amazon Corretto 8 JRE base image (Alpine for smaller size)
FROM amazoncorretto:8-alpine3.17-jre

# Expose application port
EXPOSE 8080

# Copy app jar file(s) from build output to image
COPY ./target/java-maven-app-*.jar /usr/app/

# Set working directory for app execution
WORKDIR /usr/app

# Default command to run the jar application
CMD java -jar java-maven-app-*.jar
