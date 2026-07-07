# Backup Script for PostgreSQL Database
# Usage: .\backup.ps1

$DB_NAME = "hoteldb"
$DB_USER = "admin"
$BACKUP_DIR = ".\database\backups"
$TIMESTAMP = Get-Date -Format "yyyyMMdd_HHmmss"
$BACKUP_FILE = "$BACKUP_DIR\hoteldb_$TIMESTAMP.sql"

# Create backup directory if it doesn't exist
New-Item -ItemType Directory -Force -Path $BACKUP_DIR | Out-Null

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "PostgreSQL Backup Script" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Database: $DB_NAME"
Write-Host "Backup file: $BACKUP_FILE"
Write-Host "-----------------------------------------"

# Check if database is running
Write-Host "Checking if database is running..."
$container = docker ps --filter "name=hotel_db" --format "{{.Names}}"
if (-not $container) {
    Write-Host "Error: Database container 'hotel_db' is not running." -ForegroundColor Red
    Write-Host "Please start the database using: docker-compose up -d"
    exit 1
}

# Perform backup
Write-Host "Starting backup..."
docker exec -t hotel_db pg_dump -U $DB_USER -d $DB_NAME > $BACKUP_FILE

# Check if backup was successful
if (Test-Path $BACKUP_FILE) {
    Write-Host "Backup completed successfully!" -ForegroundColor Green
    Write-Host "Backup saved to: $BACKUP_FILE"
} else {
    Write-Host "Backup failed!" -ForegroundColor Red
    exit 1
}

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Backup completed at $(Get-Date)" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan