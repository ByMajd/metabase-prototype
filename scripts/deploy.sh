#!/bin/bash

set -e

echo "Starting Metabase platform deployment..."

cd ~/metabase-prototype

if [ ! -f .env ]; then
  echo "ERROR: .env file not found."
  echo "Create .env from .env.example before deployment."
  exit 1
fi

echo "Pulling latest project changes..."
git pull

echo "Starting Docker Compose stack..."
docker compose up -d

echo "Waiting for services..."
sleep 15

echo "Checking containers..."
docker compose ps

echo "Checking Metabase health..."
if curl -f http://localhost:3000/api/health; then
  echo
  echo "Metabase is healthy."
else
  echo
  echo "Metabase health check failed."
  exit 1
fi

echo "Deployment completed successfully."