#!/bin/bash

# Set to true for a dry run (no actual operations)
DRY_RUN=true

# Database Configuration - Replace with actual values
SOURCE_DB_NAME="source_db_name"
SOURCE_DB_USER="source_db_user"
SOURCE_DB_PASS="source_db_password"
DEST_DB_NAME="destination_db_name"
DEST_DB_USER="destination_db_user"
DEST_DB_PASS="destination_db_password"

# File Paths - Replace with actual values
SOURCE_FILES_PATH="/path/to/source/typo3"
DEST_FILES_PATH="/path/to/destination/typo3"
PUBLIC_PATH="public"

# Function to run or echo commands based on dry run
function run_or_echo {
    if [ "$DRY_RUN" = true ]; then
        echo "Dry run: $*"
    else
        $*
    fi
}

echo "Script start"

# Database operations
echo "Starting export of source database..."
run_or_echo mysqldump -u "$SOURCE_DB_USER" -p"$SOURCE_DB_PASS" "$SOURCE_DB_NAME" > source_db.sql
echo "Source database export completed."

echo "Starting import into destination database..."
run_or_echo mysql -u "$DEST_DB_USER" -p"$DEST_DB_PASS" "$DEST_DB_NAME" < source_db.sql
echo "Import into destination database completed."

# File operations
echo "Deleting existing files in the destination directory..."
run_or_echo rm -rf "$DEST_FILES_PATH/$PUBLIC_PATH/fileadmin"
run_or_echo rm -rf "$DEST_FILES_PATH/$PUBLIC_PATH/uploads"
echo "File deletion completed."

echo "Starting to copy TYPO3 files..."
run_or_echo cp -r "$SOURCE_FILES_PATH/$PUBLIC_PATH/fileadmin" "$DEST_FILES_PATH/$PUBLIC_PATH"
run_or_echo cp -r "$SOURCE_FILES_PATH/$PUBLIC_PATH/uploads" "$DEST_FILES_PATH/$PUBLIC_PATH"
echo "Copying of TYPO3 files completed."

# Cleanup
echo "Cleaning up..."
run_or_echo rm source_db.sql
echo "Cleanup completed."

# TYPO3 Updates
echo "Switching to TYPO3 installation directory..."
cd "$DEST_FILES_PATH"

echo "Updating Composer dependencies..."
composer update

echo "Updating the database schema..."
vendor/bin/typo3cms database:updateschema

echo "Flushing TYPO3 cache..."
vendor/bin/typo3cms cache:flush

echo "TYPO3 updates completed."

echo "End: Database and files have been successfully copied!"
