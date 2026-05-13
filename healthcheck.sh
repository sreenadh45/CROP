#!/bin/sh

# Health check script for backend service

# Check actuator health endpoint
response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/actuator/health)

if [ "$response" -eq 200 ]; then
    # Additional check - database connectivity
    if curl -s http://localhost:8080/actuator/health | grep -q '"status":"UP"'; then
        exit 0
    fi
fi

exit 1
