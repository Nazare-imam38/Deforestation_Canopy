# ==============================================================================
# DOWNLOAD SENTINEL-2 DATA USING R PACKAGES
# ==============================================================================
# Sentinel-2 is excellent for deforestation detection
# Freely available, no login required for many sources
# ==============================================================================

source("R/01_config.R")

# Method 1: Using getSpatialData for Sentinel-2
download_sentinel_getspatialdata <- function(aoi, start_date, end_date) {
  cat("METHOD 1: Downloading Sentinel-2 using getSpatialData...\n")
  cat("--------------------------------------------------------\n")
  
  if (!require(getSpatialData, quietly = TRUE)) {
    if (!require(devtools, quietly = TRUE)) {
      install.packages("devtools")
      library(devtools)
    }
    devtools::install_github("16EAGLE/getSpatialData", dependencies = TRUE)
    library(getSpatialData)
  }
  
  # Convert AOI to proper format
  aoi_sfc <- st_geometry(aoi)
  set_aoi(aoi_sfc)
  
  # Search for Sentinel-2 data
  cat("Searching for Sentinel-2 data...\n")
  records <- getSentinel_records(
    time_range = c(start_date, end_date),
    products = "S2MSI2A"  # Sentinel-2 Level-2A (Surface Reflectance)
  )
  
  if (nrow(records) > 0) {
    cat("✓ Found", nrow(records), "Sentinel-2 scenes\n")
    
    # Download
    files <- getSentinel_data(
      records,
      dir_out = LANDSAT_DIR,
      force = FALSE
    )
    
    return(files)
  }
  
  return(NULL)
}

# Method 2: Using sen2r package (dedicated Sentinel-2 package)
download_sentinel_sen2r <- function(aoi, start_date, end_date) {
  cat("METHOD 2: Downloading Sentinel-2 using sen2r package...\n")
  cat("------------------------------------------------------\n")
  
  if (!require(sen2r, quietly = TRUE)) {
    cat("Installing sen2r package...\n")
    install.packages("sen2r", dependencies = TRUE)
    library(sen2r)
  }
  
  # Get bounding box
  bbox <- st_bbox(aoi)
  
  # Configure sen2r
  # Note: sen2r requires Copernicus account (free registration)
  cat("sen2r requires Copernicus account (free):\n")
  cat("  Register at: https://scihub.copernicus.eu/dhus/#/self-registration\n\n")
  
  # sen2r configuration
  # This is a simplified approach - sen2r has GUI and config file options
  cat("For automated download with sen2r:\n")
  cat("  1. Register at Copernicus (free)\n")
  cat("  2. Run: check_sen2r_deps()\n")
  cat("  3. Use sen2r() function with your AOI\n\n")
  
  return(NULL)
}

# Method 3: Direct download from Copernicus Open Access Hub
download_sentinel_copernicus <- function(aoi, start_date, end_date) {
  cat("METHOD 3: Downloading from Copernicus Open Access Hub...\n")
  cat("--------------------------------------------------------\n")
  
  # This method uses direct API access
  # Copernicus requires free registration but API is accessible
  
  cat("Copernicus Open Access Hub provides Sentinel-2 data.\n")
  cat("Free registration required: https://scihub.copernicus.eu/\n\n")
  
  # Get bounding box
  bbox <- st_bbox(aoi)
  
  # Create WKT polygon for search
  wkt_polygon <- paste0(
    "POLYGON((",
    bbox[1], " ", bbox[2], ",",  # min lon, min lat
    bbox[3], " ", bbox[2], ",",  # max lon, min lat
    bbox[3], " ", bbox[4], ",",  # max lon, max lat
    bbox[1], " ", bbox[4], ",",  # min lon, max lat
    bbox[1], " ", bbox[2],       # close polygon
    "))"
  )
  
  cat("Search area (WKT):", wkt_polygon, "\n\n")
  
  # Note: Full implementation would require Copernicus API credentials
  # For now, provide instructions
  
  return(NULL)
}

# Method 4: Using MODIS data (alternative, no login needed)
download_modis_terra <- function(aoi, start_date, end_date) {
  cat("METHOD 4: Downloading MODIS data (alternative)...\n")
  cat("--------------------------------------------------\n")
  
  if (!require(MODIStsp, quietly = TRUE)) {
    install.packages("MODIStsp", dependencies = TRUE)
    library(MODIStsp)
  }
  
  # MODIS provides vegetation indices
  # No login required, but requires NASA account (free)
  
  bbox <- st_bbox(aoi)
  
  cat("MODIS data available:\n")
  cat("  - MOD13Q1 (NDVI, 16-day, 250m)\n")
  cat("  - MOD16A2 (ET, 8-day, 500m)\n")
  cat("  - Good for time-series analysis\n\n")
  
  # MODIS download configuration
  MODIStsp(
    gui = FALSE,
    out_folder = LANDSAT_DIR,
    selprod = "Vegetation_Indexes_16Days_1Km (M*D13Q1)",
    bandsel = "NDVI",
    user = "your_nasa_username",  # NASA Earthdata account (free)
    password = "your_nasa_password",
    start_date = start_date,
    end_date = end_date,
    bbox = c(bbox[1], bbox[2], bbox[3], bbox[4]),
    spatmeth = "bbox",
    out_projsel = "User Defined",
    output_proj = st_crs(aoi)$proj4string,
    resampling = "bilinear",
    delete_hdf = TRUE,
    download_server = "http"
  )
}

# Main function - tries best available method
download_sentinel_automated <- function(aoi = NULL, start_date = START_DATE, 
                                       end_date = END_DATE) {
  
  cat("========================================\n")
  cat("AUTOMATED SENTINEL-2 DOWNLOAD\n")
  cat("========================================\n\n")
  
  if (is.null(aoi)) {
    source("R/03_load_study_area.R")
    aoi <- load_study_area()
  }
  
  bbox <- st_bbox(aoi)
  cat("Study Area:\n")
  cat("  Coordinates:", paste(round(bbox, 4), collapse = ", "), "\n")
  cat("  Date Range:", start_date, "to", end_date, "\n\n")
  
  # Try getSpatialData first (if it works)
  result <- tryCatch({
    download_sentinel_getspatialdata(aoi, start_date, end_date)
  }, error = function(e) {
    cat("getSpatialData method failed, trying alternatives...\n\n")
    return(NULL)
  })
  
  if (!is.null(result)) {
    return(result)
  }
  
  # If that fails, provide instructions for other methods
  cat("Alternative methods available. See download instructions.\n\n")
  
  return(NULL)
}

cat("✓ Sentinel download functions loaded!\n\n")

