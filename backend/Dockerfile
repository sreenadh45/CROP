# Multi-stage build for production
FROM maven:3.9-eclipse-temurin-17-alpine AS builder

WORKDIR /app

# Copy Maven files
COPY pom.xml .
COPY mvnw .
COPY .mvn .mvn

# Download dependencies
RUN mvn dependency:go-offline -B

# Copy source code
COPY src src

# Build application
RUN mvn clean package -DskipTests -Pprod

# Runtime stage
FROM eclipse-temurin:17-jre-alpine

# Install required packages
RUN apk add --no-cache curl tzdata ca-certificates bash

# Create application user
RUN addgroup -S spring && adduser -S spring -G spring

# Set timezone
ENV TZ=Asia/Kolkata
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Create application directories
RUN mkdir -p /app/logs /app/temp /app/backup && \
    chown -R spring:spring /app

WORKDIR /app

# Copy JAR from builder
COPY --from=builder /app/target/*.jar app.jar

# Copy healthcheck script
COPY healthcheck.sh /app/healthcheck.sh
RUN chmod +x /app/healthcheck.sh

# Copy entrypoint script
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

# Switch to non-root user
USER spring:spring

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=60s --retries=3 \
  CMD ["/app/healthcheck.sh"]

# Set JVM options
ENV JAVA_OPTS="\
    -XX:+UseContainerSupport \
    -XX:MaxRAMPercentage=75.0 \
    -XX:InitialRAMPercentage=50.0 \
    -XX:+UseG1GC \
    -XX:+UseStringDeduplication \
    -XX:+HeapDumpOnOutOfMemoryError \
    -XX:HeapDumpPath=/app/logs/heapdump.hprof \
    -XX:+PrintGCDetails \
    -XX:+PrintGCDateStamps \
    -Xloggc:/app/logs/gc.log \
    -Djava.security.egd=file:/dev/./urandom"

# Run application
ENTRYPOINT ["/app/entrypoint.sh"]
