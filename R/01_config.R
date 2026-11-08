# ==============================================================================
# DEFORESTATION DETECTION PROJECT - CONFIGURATION
# ==============================================================================
# Project-wide configuration settings
# Modify these settings according to your study area and requirements
# ==============================================================================

# Project paths
PROJECT_ROOT <- getwd()
DATA_DIR <- file.path(PROJECT_ROOT, "data")
LANDSAT_DIR <- file.path(DATA_DIR, "Landsat")
SHAPEFILE_DIR <- file.path(DATA_DIR, "shapefiles")
TRAINING_DIR <- file.path(DATA_DIR, "training")
OUTPUT_DIR <- file.path(PROJECT_ROOT, "output")
MAPS_DIR <- file.path(OUTPUT_DIR, "maps")
STATS_DIR <- file.path(OUTPUT_DIR, "statistics")
FIGURES_DIR <- file.path(OUTPUT_DIR, "figures")

# Create output directories if they don't exist
dir.create(MAPS_DIR, showWarnings = FALSE, recursive = TRUE)
dir.create(STATS_DIR, showWarnings = FALSE, recursive = TRUE)
dir.create(FIGURES_DIR, showWarnings = FALSE, recursive = TRUE)

# ==============================================================================
# STUDY AREA CONFIGURATION
# ==============================================================================

# Study area name
STUDY_AREA_NAME <- "Tropical_Forest_Area"

# Coordinate Reference System
# WGS 84 (EPSG:4326) - Standard for satellite data
CRS_WGS84 <- "EPSG:4326"

# UTM Zone (modify based on your study area location)
# Example: UTM Zone 48N for Southeast Asia (Thailand/Cambodia region)
UTM_ZONE <- "EPSG:32648"  # UTM Zone 48N for Southeast Asia

# Study area bounding box (if using coordinates instead of shapefile)
# Format: c(xmin, ymin, xmax, ymax) - Longitude, Latitude
# Example: Southeast Asia region (Thailand/Cambodia border area)
# You can modify these coordinates to your specific study area
STUDY_BBOX <- c(102.5, 12.0, 103.5, 13.0)  # Longitude, Latitude
# Alternative examples:
# Amazon region: c(-60.0, -5.0, -59.0, -4.0)
# Central Africa: c(20.0, 0.0, 21.0, 1.0)
# If you have a shapefile, set STUDY_BBOX to NULL and place shapefile in data/shapefiles/

# Shapefile path (if using shapefile)
STUDY_AREA_SHP <- file.path(SHAPEFILE_DIR, "study_area.shp")

# ==============================================================================
# LANDSAT DATA CONFIGURATION
# ==============================================================================

# Time period for analysis
START_DATE <- "2013-01-01"  # Start date for Landsat 8/9
END_DATE <- "2024-12-31"    # End date

# For historical analysis (Landsat 5/7)
HISTORICAL_START <- "2000-01-01"
HISTORICAL_END <- "2012-12-31"

# Landsat collections in Google Earth Engine
LANDSAT_COLLECTIONS <- list(
  L5 = "LANDSAT/LT05/C02/T1_L2",      # Landsat 5 TM (1984-2012)
  L7 = "LANDSAT/LE07/C02/T1_L2",      # Landsat 7 ETM+ (1999-present)
  L8 = "LANDSAT/LC08/C02/T1_L2",      # Landsat 8 OLI (2013-present)
  L9 = "LANDSAT/LC09/C02/T1_L2"       # Landsat 9 (2021-present)
)

# Spatial resolution (meters)
PIXEL_SIZE <- 30  # Landsat native resolution

# Cloud cover threshold (percentage)
MAX_CLOUD_COVER <- 20  # Maximum cloud cover percentage

# ==============================================================================
# SPECTRAL INDICES CONFIGURATION
# ==============================================================================

# Landsat 8/9 band names
BANDS_L8 <- list(
  Blue = "SR_B2",
  Green = "SR_B3",
  Red = "SR_B4",
  NIR = "SR_B5",
  SWIR1 = "SR_B6",
  SWIR2 = "SR_B7",
  QA = "QA_PIXEL"
)

# Landsat 5/7 band names
BANDS_L5 <- list(
  Blue = "SR_B1",
  Green = "SR_B2",
  Red = "SR_B3",
  NIR = "SR_B4",
  SWIR1 = "SR_B5",
  SWIR2 = "SR_B7",
  QA = "QA_PIXEL"
)

# ==============================================================================
# CHANGE DETECTION CONFIGURATION
# ==============================================================================

# NBR differencing threshold for deforestation
# Negative values indicate forest loss
DNBR_THRESHOLD <- -0.1  # Threshold for high disturbance

# NDVI thresholds
NDVI_FOREST_MIN <- 0.4   # Minimum NDVI for forest
NDVI_FOREST_MAX <- 1.0   # Maximum NDVI for forest

# Years for change detection comparison
YEAR_BEFORE <- 2015  # Baseline year
YEAR_AFTER <- 2024   # Comparison year

# ==============================================================================
# BFAST CONFIGURATION
# ==============================================================================

# BFAST parameters
BFAST_FREQUENCY <- 12  # Monthly data (12 observations per year)
BFAST_H <- 0.15        # Minimal segment size (15% of time series)
BFAST_SEASON <- "harmonic"  # Seasonal model type

# ==============================================================================
# CLASSIFICATION CONFIGURATION
# ==============================================================================

# Land cover classes
LAND_COVER_CLASSES <- c(
  "Forest",
  "Agriculture",
  "Built-up",
  "Water",
  "Barren"
)

# Random Forest parameters
RF_NTREE <- 500        # Number of trees
RF_MTRY <- NULL        # Number of variables (NULL = sqrt of total)
RF_NODESIZE <- 1       # Minimum node size

# Training data file
TRAINING_DATA_FILE <- file.path(TRAINING_DIR, "training_points.csv")

# ==============================================================================
# VISUALIZATION CONFIGURATION
# ==============================================================================

# Map output format
MAP_FORMAT <- "png"  # Options: "png", "pdf", "tiff"
MAP_WIDTH <- 12      # Inches
MAP_HEIGHT <- 8      # Inches
MAP_DPI <- 300       # Resolution

# Color palettes
PALETTE_DEFORESTATION <- "-RdYlGn"  # Red-Yellow-Green (reversed)
PALETTE_NDVI <- "YlGn"               # Yellow-Green
PALETTE_NBR <- "RdYlBu"              # Red-Yellow-Blue

# ==============================================================================
# OUTPUT FILES
# ==============================================================================

# Output file names
OUTPUT_FILES <- list(
  ndvi_stack = file.path(OUTPUT_DIR, "ndvi_stack.tif"),
  nbr_stack = file.path(OUTPUT_DIR, "nbr_stack.tif"),
  dnbr_map = file.path(OUTPUT_DIR, "dnbr_forest_loss.tif"),
  deforestation_map = file.path(MAPS_DIR, "deforestation_map.tif"),
  landcover_map = file.path(MAPS_DIR, "landcover_classification.tif"),
  deforestation_stats = file.path(STATS_DIR, "deforestation_statistics.csv"),
  accuracy_report = file.path(STATS_DIR, "accuracy_assessment.txt")
)

cat("✓ Configuration loaded successfully!\n")
cat("  Project Root:", PROJECT_ROOT, "\n")
cat("  Study Area:", STUDY_AREA_NAME, "\n")
cat("  Analysis Period:", START_DATE, "to", END_DATE, "\n\n")

