FROM openjdk:17-jdk-alpine

# Install bash for compatibility
RUN apk add --no-cache bash

# Create application directory
RUN mkdir /opt/server

# Create user
RUN adduser -D -h /opt/server crud

# Set ownership
RUN chown crud:crud -R /opt/server

# Set working directory
WORKDIR /opt/server

# Copy Maven wrapper and pom.xml first for better caching
COPY pom.xml ./
COPY .mvn .mvn
COPY mvnw ./

# Make mvnw executable
RUN chmod +x mvnw

# Download dependencies
RUN ./mvnw dependency:go-offline -B

# Copy source code
COPY src ./src

# Build the application
RUN ./mvnw clean package -DskipTests

# Switch to non-root user
USER crud

# Expose port
EXPOSE 8080

# Run the application
CMD ["java", "-jar", "target/crud-app-1.0.0.jar"]