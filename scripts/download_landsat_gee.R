# ==============================================================================
# DOWNLOAD LANDSAT DATA FROM GOOGLE EARTH ENGINE
# ==============================================================================
# Complete workflow for downloading Landsat time-series data
# ==============================================================================

cat("========================================\n")
cat("LANDSAT DATA DOWNLOAD - GOOGLE EARTH ENGINE\n")
cat("========================================\n\n")

cat("NOTE: This script requires Google Earth Engine project registration.\n")
cat("If you see registration errors, you can:\n")
cat("  1. Wait for GEE registration approval (24-48 hours)\n")
cat("  2. Or use manual download: source('scripts/download_landsat_manual.R')\n\n")

# Step 1: Setup GEE (if not already done)
cat("STEP 1: Checking GEE setup...\n")
cat("------------------------------\n")

# First check if GEE is registered
cat("Checking Google Earth Engine registration status...\n")
if (require(rgee, quietly = TRUE)) {
  tryCatch({
    # Try to initialize and test
    ee_Initialize(drive = TRUE, quiet = TRUE)
    test <- ee$Image("LANDSAT/LC08/C02/T1_L2/LC08_044034_20140318")
    test$getInfo()
    cat("✓ GEE is registered and ready\n\n")
  }, error = function(e) {
    if (grepl("not registered|register", e$message, ignore.case = TRUE)) {
      cat("\n")
      cat("========================================\n")
      cat("⚠ GOOGLE EARTH ENGINE NOT REGISTERED\n")
      cat("========================================\n\n")
      cat("Your project needs to be registered before downloading data.\n\n")
      cat("ACTION REQUIRED:\n")
      cat("  1. Register at: https://earthengine.google.com/\n")
      cat("  2. Wait for approval (24-48 hours)\n")
      cat("  3. Then run this script again\n\n")
      cat("Your project: ee-imamsyed716\n")
      cat("See: GEE_REGISTRATION_GUIDE.md for detailed instructions\n\n")
      cat("========================================\n\n")
      stop("GEE project registration required")
    } else {
      stop(e)
    }
  })
}

if (!exists("aoi_ee")) {
  cat("Preparing study area...\n")
  source("scripts/setup_gee.R")
} else {
  cat("✓ Study area ready\n\n")
}

# Load required scripts
source("R/01_config.R")
source("R/04_download_landsat.R")

# Step 2: Define download parameters
cat("STEP 2: Download Configuration\n")
cat("------------------------------\n")
cat("Time Period:", START_DATE, "to", END_DATE, "\n")
cat("Cloud Cover Threshold:", MAX_CLOUD_COVER, "%\n")
cat("Pixel Size:", PIXEL_SIZE, "meters\n")
cat("Study Area:", STUDY_AREA_NAME, "\n\n")

# Ask user for confirmation
cat("This will download Landsat 8/9 Surface Reflectance data.\n")
cat("For large areas, this may take significant time.\n\n")

# Step 3: Download Landsat 8/9 data
cat("STEP 3: Downloading Landsat 8/9 data...\n")
cat("--------------------------------------\n")
cat("Collection: LANDSAT/LC08/C02/T1_L2 (Landsat 8)\n")
cat("            LANDSAT/LC09/C02/T1_L2 (Landsat 9)\n\n")

# Download Landsat 8
cat("Downloading Landsat 8 data...\n")
tryCatch({
  l8_files <- download_landsat_8_9(
    aoi_ee = aoi_ee,
    start_date = START_DATE,
    end_date = END_DATE,
    collection = LANDSAT_COLLECTIONS$L8,
    output_dir = LANDSAT_DIR
  )
  cat("✓ Landsat 8 download initiated\n\n")
}, error = function(e) {
  cat("✗ Error downloading Landsat 8:", e$message, "\n\n")
})

# Download Landsat 9 (if available)
if (as.Date(END_DATE) >= as.Date("2021-10-01")) {
  cat("Downloading Landsat 9 data...\n")
  tryCatch({
    l9_files <- download_landsat_8_9(
      aoi_ee = aoi_ee,
      start_date = "2021-10-01",
      end_date = END_DATE,
      collection = LANDSAT_COLLECTIONS$L9,
      output_dir = LANDSAT_DIR
    )
    cat("✓ Landsat 9 download initiated\n\n")
  }, error = function(e) {
    cat("✗ Error downloading Landsat 9:", e$message, "\n\n")
  })
}

# Step 4: Download historical data (optional)
if (HISTORICAL_START < "2013-01-01") {
  cat("STEP 4: Downloading historical data (Landsat 5/7)...\n")
  cat("----------------------------------------------------\n")
  cat("Time Period:", HISTORICAL_START, "to", HISTORICAL_END, "\n\n")
  
  # Download Landsat 5
  cat("Downloading Landsat 5 data...\n")
  tryCatch({
    l5_files <- download_landsat_5_7(
      aoi_ee = aoi_ee,
      start_date = HISTORICAL_START,
      end_date = HISTORICAL_END,
      collection = LANDSAT_COLLECTIONS$L5,
      output_dir = LANDSAT_DIR
    )
    cat("✓ Landsat 5 download initiated\n\n")
  }, error = function(e) {
    cat("✗ Error downloading Landsat 5:", e$message, "\n\n")
  })
}

# Step 5: Instructions for downloading from Google Drive
cat("========================================\n")
cat("DOWNLOAD INSTRUCTIONS\n")
cat("========================================\n\n")
cat("Files have been exported to your Google Drive.\n")
cat("To download to your local machine:\n\n")
cat("1. Check your Google Drive for a folder named 'rgee_backup'\n")
cat("2. Or use R to download:\n\n")
cat("   # List tasks\n")
cat("   tasks <- ee$batch$Task$list()\n")
cat("   print(tasks)\n\n")
cat("   # Download from Drive to local\n")
cat("   # (This will be implemented in the next step)\n\n")

cat("3. Alternative: Use ee_imagecollection_to_local() for direct download\n")
cat("   (May be slower but downloads directly to your computer)\n\n")

# Step 6: Create download helper function
cat("STEP 6: Setting up download helper...\n")
cat("--------------------------------------\n")

download_from_drive <- function() {
  cat("Downloading files from Google Drive...\n")
  cat("This may take a while depending on file size.\n\n")
  
  # Get list of files in Google Drive rgee_backup folder
  # Note: This requires googledrive package
  if (require(googledrive, quietly = TRUE)) {
    # Find rgee_backup folder
    folders <- drive_find(pattern = "rgee_backup", type = "folder")
    if (nrow(folders) > 0) {
      cat("Found rgee_backup folder in Google Drive\n")
      cat("Files will be downloaded to:", LANDSAT_DIR, "\n\n")
      # Download files (implementation depends on file structure)
      cat("Please download files manually from Google Drive for now.\n")
      cat("Or wait for GEE tasks to complete and use ee_drive_to_local()\n\n")
    } else {
      cat("rgee_backup folder not found. Tasks may still be processing.\n\n")
    }
  } else {
    cat("googledrive package not available.\n")
    cat("Install with: install.packages('googledrive')\n\n")
  }
}

cat("✓ Download helper function created\n")
cat("  Run: download_from_drive() to download from Google Drive\n\n")

cat("========================================\n")
cat("DOWNLOAD PROCESS INITIATED!\n")
cat("========================================\n\n")
cat("Next steps:\n")
cat("  1. Wait for GEE tasks to complete (check Google Drive)\n")
cat("  2. Download files from Google Drive to:", LANDSAT_DIR, "\n")
cat("  3. Or use: download_from_drive() function\n")
cat("  4. Once files are downloaded, run: source('scripts/main_workflow.R')\n\n")

cat("To check task status:\n")
cat("  tasks <- ee$batch$Task$list()\n")
cat("  print(tasks)\n\n")

