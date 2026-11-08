# ==============================================================================
# DOWNLOAD LANDSAT TIME-SERIES DATA
# ==============================================================================
# Downloads Landsat imagery from Google Earth Engine
# Supports Landsat 5, 7, 8, and 9
# ==============================================================================

source("R/01_config.R")

# Check if rgee is initialized
check_gee <- function() {
  if (!require(rgee)) {
    stop("Package 'rgee' is required. Please run R/02_initialize_gee.R first.")
  }
  tryCatch({
    ee_check()
    return(TRUE)
  }, error = function(e) {
    stop("Google Earth Engine not initialized. Please run R/02_initialize_gee.R first.")
  })
}

# Function to mask clouds using QA band
mask_clouds <- function(image) {
  # Get QA band
  qa <- image$select("QA_PIXEL")
  
  # Cloud mask bits (for Landsat 8/9)
  # Bit 3: Dilated cloud
  # Bit 4: Cirrus
  # Bit 5: Cloud
  cloud_mask <- qa$bitwiseAnd(bitwShiftL(1, 3))$eq(0)$
    And(qa$bitwiseAnd(bitwShiftL(1, 4))$eq(0))$
    And(qa$bitwiseAnd(bitwShiftL(1, 5))$eq(0))
  
  # Apply mask
  image$updateMask(cloud_mask)
}

# Function to apply scale factors for Surface Reflectance
apply_scale_factors <- function(image) {
  # Scale factors for Landsat 8/9 Surface Reflectance
  # Multiply by 0.0000275 and subtract 0.2
  image$multiply(0.0000275)$add(-0.2)
}

# Download Landsat 8/9 collection
download_landsat_8_9 <- function(aoi_ee, start_date, end_date, 
                                  collection = "LANDSAT/LC08/C02/T1_L2",
                                  output_dir = LANDSAT_DIR,
                                  max_images = NULL,
                                  via = "drive") {
  
  check_gee()
  
  cat("Downloading Landsat 8/9 collection...\n")
  cat("  Collection:", collection, "\n")
  cat("  Date range:", start_date, "to", end_date, "\n")
  cat("  Cloud cover threshold:", MAX_CLOUD_COVER, "%\n")
  
  # Load collection
  collection_ee <- ee$ImageCollection(collection)$
    filterBounds(aoi_ee)$
    filterDate(start_date, end_date)$
    filter(ee$Filter$lt("CLOUD_COVER", MAX_CLOUD_COVER))$
    map(apply_scale_factors)$
    map(mask_clouds)$
    sort("system:time_start", FALSE)  # Sort by date, newest first
  
  # Get collection size
  size <- collection_ee$size()$getInfo()
  cat("  Images found:", size, "\n")
  
  if (size == 0) {
    warning("No images found for the specified criteria.")
    return(NULL)
  }
  
  # Limit number of images if specified
  if (!is.null(max_images) && size > max_images) {
    cat("  Limiting to first", max_images, "images\n")
    collection_ee <- collection_ee$limit(max_images)
    size <- max_images
  }
  
  # Download options
  if (via == "drive") {
    cat("\nExporting to Google Drive...\n")
    cat("  This is recommended for large areas.\n")
    cat("  Files will appear in Google Drive folder 'rgee_backup'\n\n")
    
    # Export to Google Drive
    task_list <- list()
    image_list <- collection_ee$toList(size)
    
    for (i in 1:size) {
      tryCatch({
        image <- ee$Image(image_list$get(i - 1))
        
        # Get image metadata
        image_id <- tryCatch({
          image$get("LANDSAT_PRODUCT_ID")$getInfo()
        }, error = function(e) {
          date <- ee_get_date_img(image)$time_start
          paste0("L8_", format(as.Date(date), "%Y%m%d"))
        })
        
        cat("  Exporting image", i, "of", size, ":", image_id, "\n")
        
        # Create export task
        task <- ee$batch$Export$image$toDrive(
          image = image,
          description = paste0("Landsat_", image_id),
          folder = "rgee_backup",
          region = aoi_ee$geometry(),
          scale = PIXEL_SIZE,
          maxPixels = 1e9
        )
        
        # Start task
        task$start()
        task_list[[i]] <- task
        
        cat("    Task started. ID:", task$id, "\n")
        
      }, error = function(e) {
        cat("    Error exporting image", i, ":", e$message, "\n")
      })
    }
    
    cat("\n✓ Export tasks created!\n")
    cat("  Total tasks:", length(task_list), "\n")
    cat("  Check task status with: ee$batch$Task$list()\n")
    cat("  Files will be in Google Drive folder 'rgee_backup'\n\n")
    
    return(task_list)
    
  } else if (via == "local") {
    cat("\nDownloading directly to local machine...\n")
    cat("  This may be slower but downloads directly.\n\n")
    
    # Direct download (for smaller areas)
    tryCatch({
      downloaded <- ee_imagecollection_to_local(
        ic = collection_ee,
        region = aoi_ee,
        scale = PIXEL_SIZE,
        via = "local",
        dsn = output_dir
      )
      
      cat("✓ Download complete!\n")
      cat("  Files saved to:", output_dir, "\n\n")
      
      return(downloaded)
      
    }, error = function(e) {
      cat("✗ Direct download failed:", e$message, "\n")
      cat("  Try using via='drive' for large areas\n\n")
      return(NULL)
    })
  }
}

# Download Landsat 5/7 (historical data)
download_landsat_5_7 <- function(aoi_ee, start_date, end_date,
                                  collection = "LANDSAT/LT05/C02/T1_L2",
                                  output_dir = LANDSAT_DIR) {
  
  check_gee()
  
  cat("Downloading Landsat 5/7 collection...\n")
  cat("  Collection:", collection, "\n")
  cat("  Date range:", start_date, "to", end_date, "\n")
  
  # Similar process as L8/9 but with different band names
  collection_ee <- ee$ImageCollection(collection)$
    filterBounds(aoi_ee)$
    filterDate(start_date, end_date)$
    filter(ee$Filter$lt("CLOUD_COVER", MAX_CLOUD_COVER))$
    map(apply_scale_factors)$
    map(mask_clouds)
  
  size <- collection_ee$size()$getInfo()
  cat("  Images found:", size, "\n")
  
  if (size == 0) {
    warning("No images found for the specified criteria.")
    return(NULL)
  }
  
  return(collection_ee)
}

# Alternative: Download using getSpatialData package
download_landsat_alternative <- function(aoi, start_date, end_date) {
  if (!require(getSpatialData)) {
    stop("Package 'getSpatialData' is required for alternative download method.")
  }
  
  cat("Using getSpatialData package for Landsat download...\n")
  
  # Login to USGS (required once)
  # login_USGS("your_username")
  
  # Set AOI
  set_aoi(aoi)
  
  # Search for Landsat data
  records <- getLandsat_records(
    time_range = c(start_date, end_date),
    products = "LANDSAT_8_C1"
  )
  
  cat("  Records found:", nrow(records), "\n")
  
  # Download records
  # files <- getLandsat_data(records)
  
  return(records)
}

# Main download function
download_landsat_timeseries <- function(aoi_ee = NULL, 
                                        start_date = START_DATE,
                                        end_date = END_DATE,
                                        use_gee = TRUE) {
  
  if (use_gee) {
    if (is.null(aoi_ee)) {
      stop("aoi_ee (Earth Engine geometry) is required for GEE download.")
    }
    
    # Download Landsat 8/9
    l8_files <- download_landsat_8_9(aoi_ee, start_date, end_date)
    
    # Download historical if needed
    if (HISTORICAL_START < "2013-01-01") {
      l5_files <- download_landsat_5_7(
        aoi_ee, 
        HISTORICAL_START, 
        HISTORICAL_END,
        collection = LANDSAT_COLLECTIONS$L5
      )
    }
    
    return(list(L8 = l8_files))
  } else {
    # Alternative method
    source("R/03_load_study_area.R")
    aoi <- load_study_area()
    return(download_landsat_alternative(aoi, start_date, end_date))
  }
}

cat("✓ Landsat download functions loaded!\n")
cat("\nUsage:\n")
cat("  1. Initialize GEE: source('R/02_initialize_gee.R')\n")
cat("  2. Load study area: aoi_ee <- aoi_to_ee(load_study_area())\n")
cat("  3. Download: files <- download_landsat_timeseries(aoi_ee)\n\n")

