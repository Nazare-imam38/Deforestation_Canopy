# ==============================================================================
# EXAMPLE USAGE - QUICK START GUIDE
# ==============================================================================
# This script demonstrates how to use individual functions
# ==============================================================================

# Load configuration
source("R/01_config.R")

# ==============================================================================
# EXAMPLE 1: Load Study Area from Shapefile
# ==============================================================================
source("R/03_load_study_area.R")

# Load study area
aoi <- load_study_area()

# Or create from bounding box
# aoi <- load_study_area(bbox = c(100.0, 0.0, 101.0, 1.0))

# ==============================================================================
# EXAMPLE 2: Preprocess Landsat Data
# ==============================================================================
source("R/05_preprocessing.R")

# Load and preprocess
landsat <- preprocess_landsat(
  data_dir = LANDSAT_DIR,
  aoi = aoi,
  mosaic = FALSE,  # Single scene
  clip = TRUE
)

# ==============================================================================
# EXAMPLE 3: Calculate Spectral Indices
# ==============================================================================
source("R/06_spectral_indices.R")

# Calculate NDVI and NBR
indices <- calculate_spectral_indices(
  landsat,
  indices = c("NDVI", "NBR")
)

# Save NDVI
writeRaster(indices$NDVI, "output/ndvi_example.tif", overwrite = TRUE)

# ==============================================================================
# EXAMPLE 4: Change Detection (if you have two time periods)
# ==============================================================================
# source("R/07_change_detection.R")
# 
# # Load NBR from two time periods
# nbr_before <- rast("data/Landsat/nbr_2015.tif")
# nbr_after <- rast("data/Landsat/nbr_2024.tif")
# 
# # Detect deforestation
# results <- detect_deforestation(nbr_before, nbr_after)

# ==============================================================================
# EXAMPLE 5: Create Visualization
# ==============================================================================
source("R/11_visualization.R")

# Plot NDVI map
if (exists("indices")) {
  plot_ndvi_map <- function(ndvi, output_file) {
    tmap_mode("plot")
    p <- tm_shape(ndvi) +
      tm_raster(title = "NDVI", palette = "YlGn", style = "cont") +
      tm_layout(title = "NDVI Map")
    tmap_save(p, output_file, width = 12, height = 8, dpi = 300)
  }
  
  plot_ndvi_map(indices$NDVI, "output/figures/ndvi_example.png")
}

cat("\n✓ Example usage complete!\n")
cat("Check output/figures/ for results.\n\n")

