# ==============================================================================
# LANDSAT DATA DOWNLOAD GUIDE
# ==============================================================================
# Step-by-step guide for downloading Landsat data
# ==============================================================================

cat("========================================\n")
cat("LANDSAT DATA DOWNLOAD GUIDE\n")
cat("========================================\n\n")

cat("METHOD 1: Google Earth Engine (Recommended)\n")
cat("--------------------------------------------\n")
cat("1. Initialize Google Earth Engine:\n")
cat("   source('R/02_initialize_gee.R')\n")
cat("   initialize_gee()\n\n")
cat("2. Load study area:\n")
cat("   source('R/03_load_study_area.R')\n")
cat("   aoi <- load_study_area()\n")
cat("   source('R/02_initialize_gee.R')\n")
cat("   aoi_ee <- aoi_to_ee(aoi)\n\n")
cat("3. Download Landsat data:\n")
cat("   source('R/04_download_landsat.R')\n")
cat("   files <- download_landsat_timeseries(aoi_ee)\n\n")
cat("Note: Files will be downloaded to Google Drive first.\n")
cat("      Use ee_drive_to_local() to download to your computer.\n\n")

cat("METHOD 2: USGS EarthExplorer (Manual)\n")
cat("--------------------------------------\n")
cat("1. Go to: https://earthexplorer.usgs.gov/\n")
cat("2. Create free account\n")
cat("3. Search Criteria:\n")
cat("   - Coordinates:", paste(STUDY_BBOX, collapse = ", "), "\n")
cat("   - Date Range: 2013-01-01 to 2024-12-31\n")
cat("   - Dataset: Landsat Collection 2 Level-2\n")
cat("4. Download Surface Reflectance products\n")
cat("5. Place .tif files in:", LANDSAT_DIR, "\n\n")

cat("METHOD 3: Test with Sample Data\n")
cat("--------------------------------\n")
cat("For testing, you can:\n")
cat("1. Use a smaller area (modify STUDY_BBOX in R/01_config.R)\n")
cat("2. Download just 2-3 images\n")
cat("3. Test the workflow before full analysis\n\n")

cat("========================================\n")
cat("DATA REQUIREMENTS\n")
cat("========================================\n\n")
cat("Required:\n")
cat("  - Landsat 8/9 Surface Reflectance (SR) products\n")
cat("  - Cloud cover < 20% (configurable in R/01_config.R)\n")
cat("  - Date range: 2013-01-01 to 2024-12-31\n")
cat("  - Format: GeoTIFF (.tif)\n\n")

cat("File Structure:\n")
cat("  Place all .tif files in:", LANDSAT_DIR, "\n")
cat("  Subdirectories are OK\n\n")

cat("After Downloading:\n")
cat("  Run: source('scripts/main_workflow.R')\n")
cat("  The workflow will automatically process all .tif files\n\n")

cat("========================================\n")
cat("HELP\n")
cat("========================================\n\n")
cat("For Google Earth Engine setup issues:\n")
cat("  - See: R/02_initialize_gee.R\n")
cat("  - Requires Google account\n")
cat("  - First-time authentication required\n\n")

cat("For USGS EarthExplorer:\n")
cat("  - Free account required\n")
cat("  - Download can take time for large areas\n")
cat("  - Use bulk download for multiple scenes\n\n")

cat("Current Study Area:\n")
if (exists("STUDY_BBOX")) {
  cat("  Bounding Box:", paste(STUDY_BBOX, collapse = ", "), "\n")
  cat("  Area: ~12,071 km²\n")
  cat("  This is a large area - consider starting with a smaller region for testing\n")
} else {
  cat("  Load configuration first: source('R/01_config.R')\n")
}

cat("\n")

