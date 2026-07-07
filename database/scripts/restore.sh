#!/bin/bash

# Restore Script for PostgreSQL Database
# Usage: ./restore.sh <backup_file.sql.gz>

set -e

# Configuration
DB_NAME="hoteldb"
DB_USER="admin"
DB_HOST="localhost"
DB_PORT="5432"
BACKUP_FILE=$1

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "========================================="
echo "PostgreSQL Restore Script"
echo "========================================="

# Check if backup file is provided
if [ -z "${BACKUP_FILE}" ]; then
    echo -e "${RED}Error: No backup file specified.${NC}"
    echo "Usage: ./restore.sh <backup_file.sql.gz>"
    echo ""
    echo "Available backups:"
    ls -lh ./database/backups/*.sql.gz 2>/dev/null || echo "No backups found."
    exit 1
fi

# Check if backup file exists
if [ ! -f "${BACKUP_FILE}" ]; then
    echo -e "${RED}Error: Backup file '${BACKUP_FILE}' not found.${NC}"
    exit 1
fi

echo "Database: ${DB_NAME}"
echo "Backup file: ${BACKUP_FILE}"
echo "-----------------------------------------"

# Check if database is running
echo "Checking if database is running..."
if ! docker ps | grep -q hotel_db; then
    echo -e "${RED}Error: Database container 'hotel_db' is not running.${NC}"
    echo "Please start the database using: docker-compose up -d"
    exit 1
fi

# Confirm restore
read -p "⚠️  This will overwrite the current database. Continue? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Restore cancelled."
    exit 1
fi

# Restore database
echo "Starting restore..."

# Drop and recreate database
echo "Dropping and recreating database..."
docker exec -t hotel_db psql -U ${DB_USER} -d postgres -c "DROP DATABASE IF EXISTS ${DB_NAME};"
docker exec -t hotel_db psql -U ${DB_USER} -d postgres -c "CREATE DATABASE ${DB_NAME};"

# Restore from backup
if [[ "${BACKUP_FILE}" == *.gz ]]; then
    echo "Restoring from compressed backup..."
    gunzip -c ${BACKUP_FILE} | docker exec -i hotel_db psql -U ${DB_USER} -d ${DB_NAME}
else
    echo "Restoring from uncompressed backup..."
    docker exec -i hotel_db psql -U ${DB_USER} -d ${DB_NAME} < ${BACKUP_FILE}
fi

# Check if restore was successful
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Restore completed successfully!${NC}"
    
    # Verify restore
    echo "-----------------------------------------"
    echo "Verifying restore..."
    
    # Count tables
    TABLE_COUNT=$(docker exec -t hotel_db psql -U ${DB_USER} -d ${DB_NAME} -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='public';")
    echo "Tables in database: ${TABLE_COUNT}"
    
    # Count bookings
    BOOKING_COUNT=$(docker exec -t hotel_db psql -U ${DB_USER} -d ${DB_NAME} -t -c "SELECT COUNT(*) FROM hotel_bookings;")
    echo "Bookings in database: ${BOOKING_COUNT}"
    
    # Show sample data
    echo "-----------------------------------------"
    echo "Sample data:"
    docker exec -t hotel_db psql -U ${DB_USER} -d ${DB_NAME} -c "SELECT id, city, status, amount FROM hotel_bookings LIMIT 5;"
    
    echo -e "${GREEN}✅ Verification completed!${NC}"
else
    echo -e "${RED}❌ Restore failed!${NC}"
    exit 1
fi

echo "========================================="
echo "Restore completed at $(date)"
echo "========================================="