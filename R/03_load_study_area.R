# ==============================================================================
# LOAD STUDY AREA
# ==============================================================================
# Loads study area from shapefile or creates from bounding box coordinates
# ==============================================================================

source("R/01_config.R")

# Load study area shapefile
load_study_area <- function(shapefile_path = NULL, bbox = NULL) {
  
  if (is.null(shapefile_path)) {
    shapefile_path <- STUDY_AREA_SHP
  }
  
  # Option 1: Load from shapefile
  if (file.exists(shapefile_path)) {
    cat("Loading study area from shapefile:", shapefile_path, "\n")
    
    aoi <- st_read(shapefile_path, quiet = TRUE)
    
    # Ensure CRS is WGS84
    if (st_crs(aoi)$epsg != 4326) {
      cat("Reprojecting to WGS84 (EPSG:4326)...\n")
      aoi <- st_transform(aoi, crs = CRS_WGS84)
    }
    
    cat("✓ Study area loaded successfully!\n")
    cat("  Features:", nrow(aoi), "\n")
    cat("  CRS:", st_crs(aoi)$input, "\n")
    cat("  Bounding box:", st_bbox(aoi), "\n\n")
    
    return(aoi)
  }
  
  # Option 2: Create from bounding box
  if (!is.null(bbox)) {
    cat("Creating study area from bounding box coordinates...\n")
    
    # bbox format: c(xmin, ymin, xmax, ymax)
    aoi <- st_bbox(
      c(xmin = bbox[1], ymin = bbox[2], xmax = bbox[3], ymax = bbox[4]),
      crs = CRS_WGS84
    ) %>%
      st_as_sfc() %>%
      st_as_sf()
    
    cat("✓ Study area created from bounding box!\n")
    cat("  Bounding box:", bbox, "\n\n")
    
    return(aoi)
  }
  
  # Option 3: Use configuration bbox
  if (!is.null(STUDY_BBOX)) {
    cat("Using bounding box from configuration...\n")
    return(load_study_area(bbox = STUDY_BBOX))
  }
  
  stop("No study area provided. Please provide a shapefile path or bounding box.")
}

# Convert sf object to Earth Engine geometry
aoi_to_ee <- function(aoi_sf) {
  if (!require(rgee, quietly = TRUE)) {
    stop("Package 'rgee' is required. Please install it first.")
  }
  
  if (!require(geojsonio, quietly = TRUE)) {
    cat("Installing geojsonio package (required for sf_as_ee)...\n")
    install.packages("geojsonio", dependencies = TRUE)
    library(geojsonio)
  }
  
  cat("Converting study area to Earth Engine geometry...\n")
  
  # Convert sf to ee geometry
  tryCatch({
    aoi_ee <- sf_as_ee(aoi_sf)
    cat("✓ Study area converted to Earth Engine format.\n\n")
    return(aoi_ee)
  }, error = function(e) {
    cat("✗ Conversion failed:", e$message, "\n")
    cat("  Make sure geojsonio is installed: install.packages('geojsonio')\n\n")
    stop("Failed to convert study area to Earth Engine format")
  })
}

# Save study area info
save_study_area_info <- function(aoi, output_file = NULL) {
  if (is.null(output_file)) {
    output_file <- file.path(STATS_DIR, "study_area_info.txt")
  }
  
  bbox <- st_bbox(aoi)
  area_km2 <- as.numeric(st_area(aoi)) / 1e6  # Convert m² to km²
  
  info <- paste0(
    "Study Area Information\n",
    "======================\n",
    "Name: ", STUDY_AREA_NAME, "\n",
    "Number of features: ", nrow(aoi), "\n",
    "CRS: ", st_crs(aoi)$input, "\n",
    "Bounding Box:\n",
    "  Longitude: ", bbox[1], " to ", bbox[3], "\n",
    "  Latitude: ", bbox[2], " to ", bbox[4], "\n",
    "Area: ", round(area_km2, 2), " km²\n"
  )
  
  writeLines(info, output_file)
  cat("✓ Study area information saved to:", output_file, "\n\n")
}

# Example usage
if (!interactive()) {
  # Load study area
  aoi <- load_study_area()
  
  # Save info
  save_study_area_info(aoi)
  
  # Convert to EE format (if using GEE)
  # aoi_ee <- aoi_to_ee(aoi)
}

