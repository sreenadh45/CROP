#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}Starting deployment to production...${NC}"

# Load environment variables
if [ -f .env.production ]; then
    export $(cat .env.production | grep -v '^#' | xargs)
else
    echo -e "${RED}Error: .env.production file not found${NC}"
    exit 1
fi

# Backup current database
echo -e "${YELLOW}Backing up current database...${NC}"
./scripts/backup.sh

# Pull latest code
echo -e "${YELLOW}Pulling latest code...${NC}"
git pull origin main

# Build backend
echo -e "${YELLOW}Building backend...${NC}"
cd backend
mvn clean package -DskipTests

# Run database migrations
echo -e "${YELLOW}Running database migrations...${NC}"
java -jar target/*.jar db:migrate

# Build Docker images
echo -e "${YELLOW}Building Docker images...${NC}"
docker build -t crop-marketplace-backend:latest .
cd ..

# Stop old containers
echo -e "${YELLOW}Stopping old containers...${NC}"
docker-compose -f docker-compose.prod.yml down

# Start new containers
echo -e "${YELLOW}Starting new containers...${NC}"
docker-compose -f docker-compose.prod.yml up -d

# Wait for services to be ready
echo -e "${YELLOW}Waiting for services to be ready...${NC}"
sleep 30

# Run health checks
echo -e "${YELLOW}Running health checks...${NC}"
./scripts/health-check.sh

# Verify deployment
if [ $? -eq 0 ]; then
    echo -e "${GREEN}Deployment completed successfully!${NC}"
    
    # Send notification
    curl -X POST -H 'Content-type: application/json' \
        --data "{\"text\":\"✅ Deployment successful: Crop Marketplace v${VERSION}\"}" \
        ${SLACK_WEBHOOK_URL}
else
    echo -e "${RED}Deployment failed! Rolling back...${NC}"
    ./scripts/rollback.sh
    exit 1
fi
