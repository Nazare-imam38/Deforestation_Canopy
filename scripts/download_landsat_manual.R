# ==============================================================================
# MANUAL LANDSAT DATA DOWNLOAD GUIDE
# ==============================================================================
# Use this if GEE registration is pending or you prefer manual download
# ==============================================================================

cat("========================================\n")
cat("MANUAL LANDSAT DATA DOWNLOAD GUIDE\n")
cat("========================================\n\n")

# Load configuration
source("R/01_config.R")
source("R/03_load_study_area.R")
aoi <- load_study_area()

cat("Since Google Earth Engine registration is pending, you can download\n")
cat("Landsat data manually from USGS EarthExplorer.\n\n")

cat("========================================\n")
cat("DOWNLOAD INSTRUCTIONS\n")
cat("========================================\n\n")

cat("STEP 1: Create USGS Account\n")
cat("---------------------------\n")
cat("1. Visit: https://earthexplorer.usgs.gov/\n")
cat("2. Click 'Register' (top right)\n")
cat("3. Create a free account\n\n")

cat("STEP 2: Search for Landsat Data\n")
cat("-------------------------------\n")
bbox <- st_bbox(aoi)
cat("Study Area Coordinates:\n")
cat("  Longitude:", round(bbox[1], 4), "to", round(bbox[3], 4), "\n")
cat("  Latitude:", round(bbox[2], 4), "to", round(bbox[4], 4), "\n\n")

cat("Search Criteria:\n")
cat("  1. Go to 'Search Criteria' tab\n")
cat("  2. Select 'Geographic' → 'Coordinates'\n")
cat("  3. Enter coordinates:\n")
cat("     North:", round(bbox[4], 4), "\n")
cat("     South:", round(bbox[2], 4), "\n")
cat("     East:", round(bbox[3], 4), "\n")
cat("     West:", round(bbox[1], 4), "\n")
cat("  4. Date Range:", START_DATE, "to", END_DATE, "\n")
cat("  5. Click 'Data Sets' tab\n\n")

cat("STEP 3: Select Landsat Collection\n")
cat("---------------------------------\n")
cat("1. Expand 'Landsat Collection 2 Level-2'\n")
cat("2. Select:\n")
cat("   - Landsat 8-9 OLI/TIRS C2 L2 (for 2013-present)\n")
cat("   - Landsat 4-5 TM C2 L2 (for historical data)\n")
cat("3. Click 'Results' tab\n\n")

cat("STEP 4: Filter and Download\n")
cat("----------------------------\n")
cat("1. Filter by cloud cover: <", MAX_CLOUD_COVER, "%\n")
cat("2. Select images you want to download\n")
cat("3. Click 'Download Options'\n")
cat("4. Choose 'Surface Reflectance' products\n")
cat("5. Download files\n\n")

cat("STEP 5: Organize Files\n")
cat("----------------------\n")
cat("1. Extract downloaded .tar.gz files\n")
cat("2. Copy .tif files to:\n")
cat("   ", LANDSAT_DIR, "\n")
cat("3. You can organize by date in subfolders if desired\n\n")

cat("STEP 6: Verify Files\n")
cat("-------------------\n")
cat("After placing files, verify with:\n")
cat("  landsat_files <- list.files('", LANDSAT_DIR, "', pattern='.tif$', recursive=TRUE)\n")
cat("  cat('Found', length(landsat_files), 'Landsat files\\n')\n\n")

cat("========================================\n")
cat("FILE REQUIREMENTS\n")
cat("========================================\n\n")
cat("Required bands (Landsat 8/9):\n")
cat("  - B2 (Blue)\n")
cat("  - B3 (Green)\n")
cat("  - B4 (Red)\n")
cat("  - B5 (NIR)\n")
cat("  - B6 (SWIR1)\n")
cat("  - B7 (SWIR2)\n\n")

cat("File format: GeoTIFF (.tif)\n")
cat("Product: Surface Reflectance (SR)\n")
cat("Collection: Landsat Collection 2 Level-2\n\n")

cat("========================================\n")
cat("AFTER DOWNLOAD\n")
cat("========================================\n\n")
cat("Once files are in", LANDSAT_DIR, ":\n\n")
cat("1. Run preprocessing:\n")
cat("   source('R/05_preprocessing.R')\n")
cat("   landsat <- preprocess_landsat(data_dir = '", LANDSAT_DIR, "', aoi = aoi)\n\n")

cat("2. Calculate indices:\n")
cat("   source('R/06_spectral_indices.R')\n")
cat("   indices <- calculate_spectral_indices(landsat)\n\n")

cat("3. Run full workflow:\n")
cat("   source('scripts/main_workflow.R')\n\n")

cat("========================================\n")
cat("ALTERNATIVE: Wait for GEE Registration\n")
cat("========================================\n\n")
cat("If you prefer to wait for GEE registration approval:\n")
cat("  1. Check status: source('scripts/check_gee_status.R')\n")
cat("  2. Once approved: source('scripts/download_landsat_gee.R')\n\n")

cat("GEE is faster and more automated, but manual download works too!\n\n")

