# ==============================================================================
# SPECTRAL INDICES CALCULATION
# ==============================================================================
# Calculate NDVI, NBR, and other vegetation indices
# ==============================================================================

source("R/01_config.R")

# Calculate NDVI (Normalized Difference Vegetation Index)
# Works with Landsat, Sentinel-2, and MODIS
calculate_ndvi <- function(landsat_stack, red_band = NULL, nir_band = NULL, 
                          sensor = "auto") {
  cat("Calculating NDVI...\n")
  
  # Auto-detect sensor type
  if (sensor == "auto") {
    n_bands <- nlyr(landsat_stack)
    if (n_bands >= 10) {
      sensor <- "sentinel2"  # Sentinel-2 has many bands
    } else if (n_bands >= 6) {
      sensor <- "landsat"     # Landsat 8/9
    } else {
      sensor <- "modis"       # MODIS or single band
    }
    cat("  Detected sensor:", sensor, "\n")
  }
  
  # Extract bands based on sensor
  if (sensor == "sentinel2") {
    # Sentinel-2: B4 (Red), B8 (NIR)
    if (is.null(red_band)) red_band <- landsat_stack[[3]]  # B4
    if (is.null(nir_band)) nir_band <- landsat_stack[[7]]  # B8
  } else if (sensor == "landsat") {
    # Landsat 8/9: B4 (Red), B5 (NIR)
    if (is.null(red_band)) red_band <- landsat_stack[[3]]  # B4
    if (is.null(nir_band)) nir_band <- landsat_stack[[4]]  # B5
  } else if (sensor == "modis") {
    # MODIS: If it's already NDVI, return as is
    if (nlyr(landsat_stack) == 1) {
      # Might already be NDVI
      names(landsat_stack) <- "NDVI"
      return(landsat_stack)
    }
  }
  
  # If landsat_stack is a multi-layer raster, extract bands
  if (nlyr(landsat_stack) >= 4 && is.null(red_band)) {
    # Default: Assume standard Landsat 8/9 order: B2, B3, B4, B5, B6, B7
    red_band <- landsat_stack[[3]]  # B4 (Red)
    nir_band <- landsat_stack[[4]]  # B5 (NIR)
  }
  
  if (is.null(red_band) || is.null(nir_band)) {
    stop("Cannot determine Red and NIR bands. Please specify manually.")
  }
  
  # NDVI = (NIR - Red) / (NIR + Red)
  ndvi <- (nir_band - red_band) / (nir_band + red_band)
  
  # Set layer name
  names(ndvi) <- "NDVI"
  
  cat("✓ NDVI calculated!\n")
  cat("  Range:", minmax(ndvi), "\n\n")
  
  return(ndvi)
}

# Calculate NBR (Normalized Burn Ratio)
# Works with Landsat and Sentinel-2
calculate_nbr <- function(landsat_stack, nir_band = NULL, swir2_band = NULL,
                         sensor = "auto") {
  cat("Calculating NBR...\n")
  
  # Auto-detect sensor
  if (sensor == "auto") {
    n_bands <- nlyr(landsat_stack)
    sensor <- ifelse(n_bands >= 10, "sentinel2", "landsat")
    cat("  Detected sensor:", sensor, "\n")
  }
  
  # Extract bands based on sensor
  if (sensor == "sentinel2") {
    # Sentinel-2: B8 (NIR), B12 (SWIR2)
    if (is.null(nir_band)) nir_band <- landsat_stack[[7]]   # B8
    if (is.null(swir2_band)) swir2_band <- landsat_stack[[11]]  # B12
  } else {
    # Landsat 8/9: B5 (NIR), B7 (SWIR2)
    if (nlyr(landsat_stack) >= 6) {
      if (is.null(nir_band)) nir_band <- landsat_stack[[4]]   # B5 (NIR)
      if (is.null(swir2_band)) swir2_band <- landsat_stack[[6]]  # B7 (SWIR2)
    } else {
      stop("Raster must have at least 6 bands (NIR and SWIR2 required)")
    }
  }
  
  # NBR = (NIR - SWIR2) / (NIR + SWIR2)
  nbr <- (nir_band - swir2_band) / (nir_band + swir2_band)
  
  # Set layer name
  names(nbr) <- "NBR"
  
  cat("✓ NBR calculated!\n")
  cat("  Range:", minmax(nbr), "\n\n")
  
  return(nbr)
}

# Calculate dNBR (differenced NBR) for change detection
calculate_dnbr <- function(nbr_before, nbr_after) {
  cat("Calculating dNBR (NBR difference)...\n")
  
  # Ensure same extent and resolution
  if (!compareGeom(nbr_before, nbr_after, stopOnError = FALSE)) {
    cat("  Aligning rasters...\n")
    template <- rast(ext = ext(nbr_before), 
                     crs = crs(nbr_before), 
                     resolution = res(nbr_before))
    nbr_after <- resample(nbr_after, template, method = "bilinear")
  }
  
  # dNBR = NBR_before - NBR_after
  # Negative values indicate forest loss
  dnbr <- nbr_before - nbr_after
  
  names(dnbr) <- "dNBR"
  
  cat("✓ dNBR calculated!\n")
  cat("  Range:", minmax(dnbr), "\n")
  cat("  Negative values indicate forest loss\n\n")
  
  return(dnbr)
}

# Calculate EVI (Enhanced Vegetation Index)
calculate_evi <- function(landsat_stack, blue_band = NULL, red_band = NULL, nir_band = NULL) {
  cat("Calculating EVI...\n")
  
  if (nlyr(landsat_stack) >= 4) {
    if (is.null(blue_band)) blue_band <- landsat_stack[[1]]  # B2
    if (is.null(red_band)) red_band <- landsat_stack[[3]]   # B4
    if (is.null(nir_band)) nir_band <- landsat_stack[[4]]   # B5
  }
  
  # EVI = 2.5 * ((NIR - Red) / (NIR + 6*Red - 7.5*Blue + 1))
  evi <- 2.5 * ((nir_band - red_band) / (nir_band + 6*red_band - 7.5*blue_band + 1))
  
  names(evi) <- "EVI"
  
  cat("✓ EVI calculated!\n\n")
  return(evi)
}

# Calculate SAVI (Soil-Adjusted Vegetation Index)
calculate_savi <- function(landsat_stack, red_band = NULL, nir_band = NULL, L = 0.5) {
  cat("Calculating SAVI...\n")
  
  if (nlyr(landsat_stack) >= 4) {
    if (is.null(red_band)) red_band <- landsat_stack[[3]]   # B4
    if (is.null(nir_band)) nir_band <- landsat_stack[[4]]   # B5
  }
  
  # SAVI = ((NIR - Red) / (NIR + Red + L)) * (1 + L)
  savi <- ((nir_band - red_band) / (nir_band + red_band + L)) * (1 + L)
  
  names(savi) <- "SAVI"
  
  cat("✓ SAVI calculated!\n\n")
  return(savi)
}

# Calculate all indices for a time series
calculate_indices_timeseries <- function(landsat_files, output_dir = OUTPUT_DIR) {
  cat("========================================\n")
  cat("CALCULATING SPECTRAL INDICES (TIME SERIES)\n")
  cat("========================================\n\n")
  
  ndvi_stack <- list()
  nbr_stack <- list()
  
  for (i in seq_along(landsat_files)) {
    cat("Processing file", i, "of", length(landsat_files), "\n")
    
    # Load raster
    landsat <- rast(landsat_files[i])
    
    # Calculate indices
    ndvi <- calculate_ndvi(landsat)
    nbr <- calculate_nbr(landsat)
    
    # Store in lists
    ndvi_stack[[i]] <- ndvi
    nbr_stack[[i]] <- nbr
  }
  
  # Stack all NDVI and NBR rasters
  cat("\nStacking time series...\n")
  ndvi_ts <- rast(ndvi_stack)
  nbr_ts <- rast(nbr_stack)
  
  # Save stacks
  ndvi_file <- OUTPUT_FILES$ndvi_stack
  nbr_file <- OUTPUT_FILES$nbr_stack
  
  writeRaster(ndvi_ts, ndvi_file, overwrite = TRUE)
  writeRaster(nbr_ts, nbr_file, overwrite = TRUE)
  
  cat("✓ Time series stacks saved!\n")
  cat("  NDVI stack:", ndvi_file, "\n")
  cat("  NBR stack:", nbr_file, "\n\n")
  
  return(list(NDVI = ndvi_ts, NBR = nbr_ts))
}

# Main function to calculate indices
calculate_spectral_indices <- function(landsat_stack, indices = c("NDVI", "NBR")) {
  cat("========================================\n")
  cat("SPECTRAL INDICES CALCULATION\n")
  cat("========================================\n\n")
  
  results <- list()
  
  if ("NDVI" %in% indices) {
    results$NDVI <- calculate_ndvi(landsat_stack)
  }
  
  if ("NBR" %in% indices) {
    results$NBR <- calculate_nbr(landsat_stack)
  }
  
  if ("EVI" %in% indices) {
    results$EVI <- calculate_evi(landsat_stack)
  }
  
  if ("SAVI" %in% indices) {
    results$SAVI <- calculate_savi(landsat_stack)
  }
  
  cat("✓ All requested indices calculated!\n\n")
  return(results)
}

cat("✓ Spectral indices functions loaded!\n\n")

