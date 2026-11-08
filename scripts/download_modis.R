# ==============================================================================
# DOWNLOAD MODIS DATA FOR DEFORESTATION ANALYSIS
# ==============================================================================
# MODIS provides vegetation indices - excellent for deforestation detection
# Free NASA account required (registration takes 2 minutes)
# ==============================================================================

cat("========================================\n")
cat("DOWNLOAD MODIS DATA\n")
cat("========================================\n\n")

# Load packages
source("R/00_setup_packages.R")
source("R/01_config.R")
source("R/03_load_study_area.R")

# Install MODIStsp if needed
if (!require(MODIStsp, quietly = TRUE)) {
  cat("Installing MODIStsp package...\n")
  install.packages("MODIStsp", dependencies = TRUE)
  library(MODIStsp)
}

# Load study area
aoi <- load_study_area()
bbox <- st_bbox(aoi)

cat("MODIS Data Products:\n")
cat("  - MOD13Q1: NDVI/EVI, 16-day, 250m resolution\n")
cat("  - MOD16A2: Evapotranspiration, 8-day, 500m\n")
cat("  - MOD09Q1: Surface Reflectance, 8-day, 250m\n")
cat("  - Excellent for time-series deforestation analysis\n\n")

cat("Study Area:\n")
cat("  North:", round(bbox[4], 4), "\n")
cat("  South:", round(bbox[2], 4), "\n")
cat("  East:", round(bbox[3], 4), "\n")
cat("  West:", round(bbox[1], 4), "\n")
cat("  Date Range:", START_DATE, "to", END_DATE, "\n\n")

cat("========================================\n")
cat("NASA EARTHDATA ACCOUNT\n")
cat("========================================\n\n")
cat("MODIS requires free NASA Earthdata account:\n")
cat("  1. Register at: https://urs.earthdata.nasa.gov/\n")
cat("  2. It's completely free\n")
cat("  3. Takes 2 minutes\n\n")

cat("After registration, provide credentials:\n")
cat("  MODIStsp(gui = TRUE)  # Interactive mode\n")
cat("  Or configure in script below\n\n")

cat("========================================\n")
cat("AUTOMATED MODIS DOWNLOAD\n")
cat("========================================\n\n")

# MODIS download configuration
cat("Downloading MOD13Q1 (NDVI product)...\n")
cat("This is excellent for deforestation time-series analysis.\n\n")

# Note: MODIStsp requires credentials
# For automated use, you can set them here or use GUI
cat("To download automatically, run:\n\n")

cat("MODIStsp(\n")
cat("  gui = FALSE,\n")
cat("  out_folder = '", LANDSAT_DIR, "',\n", sep = "")
cat("  selprod = 'Vegetation_Indexes_16Days_1Km (M*D13Q1)',\n")
cat("  bandsel = 'NDVI',\n")
cat("  user = 'your_nasa_username',\n")
cat("  password = 'your_nasa_password',\n")
cat("  start_date = '", START_DATE, "',\n", sep = "")
cat("  end_date = '", END_DATE, "',\n", sep = "")
cat("  bbox = c(", paste(round(bbox, 4), collapse = ", "), "),\n", sep = "")
cat("  spatmeth = 'bbox',\n")
cat("  out_projsel = 'User Defined',\n")
cat("  output_proj = 'EPSG:4326',\n")
cat("  resampling = 'bilinear',\n")
cat("  delete_hdf = TRUE\n")
cat(")\n\n")

cat("========================================\n")
cat("ALTERNATIVE: Use Pre-processed MODIS\n")
cat("========================================\n\n")
cat("You can also download pre-processed MODIS data from:\n")
cat("  - AppEEARS: https://appeears.earthdatacloud.nasa.gov/\n")
cat("  - No coding required, web interface\n")
cat("  - Download as GeoTIFF\n")
cat("  - Place files in:", LANDSAT_DIR, "\n\n")

cat("Then run: source('scripts/run_immediate_workflow.R')\n\n")

cat("========================================\n")
cat("RECOMMENDATION\n")
cat("========================================\n\n")
cat("For immediate deforestation analysis:\n")
cat("  1. Use AppEEARS (easiest): https://appeears.earthdatacloud.nasa.gov/\n")
cat("  2. Download MOD13Q1 NDVI for your area\n")
cat("  3. Place .tif files in:", LANDSAT_DIR, "\n")
cat("  4. Run: source('scripts/run_immediate_workflow.R')\n\n")

cat("MODIS NDVI is excellent for:\n")
cat("  - Time-series deforestation detection\n")
cat("  - BFAST analysis\n")
cat("  - Long-term trends\n\n")

