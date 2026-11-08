# ==============================================================================
# APPEEARS DOWNLOAD GUIDE - EASIEST METHOD
# ==============================================================================
# AppEEARS provides easy access to MODIS and other satellite data
# No complex login, web-based interface
# ==============================================================================

cat("========================================\n")
cat("APPEEARS DOWNLOAD GUIDE\n")
cat("Easiest Method - No Complex Login\n")
cat("========================================\n\n")

source("R/01_config.R")
source("R/03_load_study_area.R")

aoi <- load_study_area()
bbox <- st_bbox(aoi)

cat("AppEEARS (Application for Extracting and Exploring Analysis Ready Samples)\n")
cat("Provides easy access to satellite data without complex API programming.\n\n")

cat("========================================\n")
cat("STEP-BY-STEP INSTRUCTIONS\n")
cat("========================================\n\n")

cat("STEP 1: Create Account (2 minutes)\n")
cat("----------------------------------\n")
cat("1. Visit: https://appeears.earthdatacloud.nasa.gov/\n")
cat("2. Click 'Login' → 'Create Account'\n")
cat("3. Fill form (free, takes 2 minutes)\n")
cat("4. Verify email\n\n")

cat("STEP 2: Create New Request\n")
cat("--------------------------\n")
cat("1. Login to AppEEARS\n")
cat("2. Click 'Extract' → 'Area' or 'Point'\n")
cat("3. Select 'Area' for your study region\n\n")

cat("STEP 3: Define Your Area\n")
cat("------------------------\n")
cat("Use these coordinates:\n")
cat("  North:", round(bbox[4], 4), "\n")
cat("  South:", round(bbox[2], 4), "\n")
cat("  East:", round(bbox[3], 4), "\n")
cat("  West:", round(bbox[1], 4), "\n\n")

cat("Or draw on map using the interactive tool.\n\n")

cat("STEP 4: Select Product\n")
cat("----------------------\n")
cat("Recommended products for deforestation:\n\n")
cat("OPTION A: MODIS MOD13Q1 (Best for time-series)\n")
cat("  - Product: MODIS Terra Vegetation Indices 16-Day\n")
cat("  - Bands: NDVI, EVI\n")
cat("  - Resolution: 250m\n")
cat("  - Temporal: 16-day composite\n")
cat("  - Excellent for BFAST analysis\n\n")

cat("OPTION B: MODIS MOD09Q1 (Surface Reflectance)\n")
cat("  - Product: MODIS Terra Surface Reflectance 8-Day\n")
cat("  - Bands: Red, NIR\n")
cat("  - Resolution: 250m\n")
cat("  - Can calculate NDVI\n\n")

cat("OPTION C: MODIS MOD16A2 (Evapotranspiration)\n")
cat("  - Product: MODIS Terra Net Evapotranspiration 8-Day\n")
cat("  - Useful for forest health monitoring\n\n")

cat("STEP 5: Set Date Range\n")
cat("----------------------\n")
cat("Start Date:", START_DATE, "\n")
cat("End Date:", END_DATE, "\n\n")

cat("STEP 6: Submit and Download\n")
cat("---------------------------\n")
cat("1. Click 'Submit'\n")
cat("2. Wait for processing (usually 5-15 minutes)\n")
cat("3. Download as GeoTIFF\n")
cat("4. Extract files\n")
cat("5. Place .tif files in:", LANDSAT_DIR, "\n\n")

cat("========================================\n")
cat("FILE ORGANIZATION\n")
cat("========================================\n\n")
cat("After download, organize files:\n")
cat("  ", LANDSAT_DIR, "/\n", sep = "")
cat("    ├── MOD13Q1_NDVI_2023_001.tif\n")
cat("    ├── MOD13Q1_NDVI_2023_017.tif\n")
cat("    └── ...\n\n")

cat("========================================\n")
cat("AFTER DOWNLOAD\n")
cat("========================================\n\n")
cat("Once files are in", LANDSAT_DIR, ":\n\n")
cat("1. Verify files:\n")
cat("   source('scripts/verify_downloaded_data.R')\n\n")
cat("2. Run analysis:\n")
cat("   source('scripts/run_immediate_workflow.R')\n\n")

cat("========================================\n")
cat("ADVANTAGES OF APPEEARS\n")
cat("========================================\n\n")
cat("✓ No complex API programming\n")
cat("✓ Web-based interface (user-friendly)\n")
cat("✓ Free account (2-minute registration)\n")
cat("✓ Pre-processed data (ready to use)\n")
cat("✓ Multiple products available\n")
cat("✓ Direct GeoTIFF download\n")
cat("✓ No R package dependencies\n\n")

cat("========================================\n")
cat("QUICK START\n")
cat("========================================\n\n")
cat("1. Go to: https://appeears.earthdatacloud.nasa.gov/\n")
cat("2. Register (2 minutes)\n")
cat("3. Create area request with coordinates above\n")
cat("4. Select MOD13Q1 NDVI\n")
cat("5. Download and place files in:", LANDSAT_DIR, "\n")
cat("6. Run: source('scripts/run_immediate_workflow.R')\n\n")

cat("This is the EASIEST and most reliable method!\n\n")

