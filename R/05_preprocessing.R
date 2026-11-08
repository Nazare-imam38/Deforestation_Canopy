# ==============================================================================
# LANDSAT PREPROCESSING
# ==============================================================================
# Preprocessing steps: mosaicking, clipping, resampling, alignment
# ==============================================================================

source("R/01_config.R")

# Load and stack Landsat rasters
load_landsat_rasters <- function(data_dir = LANDSAT_DIR, pattern = "\\.tif$") {
  cat("Loading Landsat rasters from:", data_dir, "\n")
  
  # Find all GeoTIFF files
  files <- list.files(data_dir, pattern = pattern, full.names = TRUE, recursive = TRUE)
  
  if (length(files) == 0) {
    stop("No Landsat files found in ", data_dir)
  }
  
  cat("  Found", length(files), "files\n")
  
  # Load rasters
  rasters <- lapply(files, function(f) {
    tryCatch({
      rast(f)
    }, error = function(e) {
      warning("Error loading ", f, ": ", e$message)
      return(NULL)
    })
  })
  
  # Remove NULLs
  rasters <- rasters[!sapply(rasters, is.null)]
  
  cat("  Successfully loaded", length(rasters), "rasters\n\n")
  return(rasters)
}

# Mosaic multiple rasters (if study area spans multiple scenes)
mosaic_rasters <- function(rasters, method = "mean") {
  cat("Mosaicking", length(rasters), "rasters...\n")
  
  if (length(rasters) == 1) {
    cat("  Only one raster, skipping mosaicking\n\n")
    return(rasters[[1]])
  }
  
  # Ensure all rasters have same CRS and resolution
  cat("  Aligning rasters...\n")
  
  # Get common extent
  extents <- lapply(rasters, ext)
  common_ext <- do.call(union, extents)
  
  # Get common CRS (use first raster's CRS)
  common_crs <- crs(rasters[[1]])
  
  # Resample all to common grid
  template <- rast(ext = common_ext, crs = common_crs, resolution = PIXEL_SIZE)
  
  rasters_aligned <- lapply(rasters, function(r) {
    resample(r, template, method = "bilinear")
  })
  
  # Mosaic
  cat("  Creating mosaic...\n")
  mosaic_raster <- do.call(mosaic, c(rasters_aligned, fun = method))
  
  cat("✓ Mosaicking complete!\n\n")
  return(mosaic_raster)
}

# Clip raster to study area
clip_to_aoi <- function(raster, aoi) {
  cat("Clipping raster to study area...\n")
  
  # Convert aoi to SpatVector if needed
  if (inherits(aoi, "sf")) {
    aoi_vect <- vect(aoi)
  } else if (inherits(aoi, "SpatVector")) {
    aoi_vect <- aoi
  } else {
    stop("aoi must be sf or SpatVector object")
  }
  
  # Ensure same CRS
  if (crs(raster) != crs(aoi_vect)) {
    cat("  Reprojecting AOI to match raster CRS...\n")
    aoi_vect <- project(aoi_vect, crs(raster))
  }
  
  # Crop and mask
  clipped <- crop(raster, aoi_vect)
  clipped <- mask(clipped, aoi_vect)
  
  cat("✓ Clipping complete!\n\n")
  return(clipped)
}

# Align multiple rasters to same grid
align_rasters <- function(rasters, reference = NULL) {
  cat("Aligning", length(rasters), "rasters to common grid...\n")
  
  # Use first raster as reference if not specified
  if (is.null(reference)) {
    reference <- rasters[[1]]
  }
  
  # Create template from reference
  template <- rast(ext = ext(reference), 
                   crs = crs(reference), 
                   resolution = res(reference))
  
  # Resample all rasters
  aligned <- lapply(rasters, function(r) {
    resample(r, template, method = "bilinear")
  })
  
  cat("✓ Alignment complete!\n\n")
  return(aligned)
}

# Extract bands from Landsat stack
extract_bands <- function(landsat_stack, bands = c("Red", "NIR", "SWIR1", "SWIR2")) {
  cat("Extracting bands from Landsat stack...\n")
  
  # Landsat 8/9 Collection 2 Level-2 Surface Reflectance band mapping
  # SR_B1 = Coastal/Aerosol (index 1, typically not used)
  # SR_B2 = Blue (index 2)
  # SR_B3 = Green (index 3)
  # SR_B4 = Red (index 4)
  # SR_B5 = NIR (index 5)
  # SR_B6 = SWIR1 (index 6)
  # SR_B7 = SWIR2 (index 7)
  band_mapping <- list(
    "Coastal" = 1,  # B1 (Coastal/Aerosol)
    "Blue" = 2,      # B2
    "Green" = 3,    # B3
    "Red" = 4,      # B4
    "NIR" = 5,      # B5
    "SWIR1" = 6,    # B6
    "SWIR2" = 7     # B7
  )
  
  extracted <- list()
  
  for (band in bands) {
    if (band %in% names(band_mapping)) {
      band_num <- band_mapping[[band]]
      if (band_num <= nlyr(landsat_stack)) {
        extracted[[band]] <- landsat_stack[[band_num]]
        cat("  Extracted:", band, "\n")
      }
    }
  }
  
  cat("✓ Band extraction complete!\n\n")
  return(extracted)
}

# Preprocess complete workflow
preprocess_landsat <- function(data_dir = LANDSAT_DIR, aoi = NULL, 
                               mosaic = TRUE, clip = TRUE) {
  cat("========================================\n")
  cat("LANDSAT PREPROCESSING WORKFLOW\n")
  cat("========================================\n\n")
  
  # Load rasters
  rasters <- load_landsat_rasters(data_dir)
  
  # Mosaic if needed
  if (mosaic && length(rasters) > 1) {
    processed <- mosaic_rasters(rasters)
  } else {
    processed <- rasters[[1]]
  }
  
  # Clip to AOI if provided
  if (clip && !is.null(aoi)) {
    processed <- clip_to_aoi(processed, aoi)
  }
  
  cat("✓ Preprocessing complete!\n")
  cat("  Output dimensions:", dim(processed), "\n")
  cat("  CRS:", crs(processed), "\n")
  cat("  Extent:", as.character(ext(processed)), "\n\n")
  
  return(processed)
}

cat("✓ Preprocessing functions loaded!\n\n")

