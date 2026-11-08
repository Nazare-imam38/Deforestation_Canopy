# ==============================================================================
# BFAST TIME-SERIES ANALYSIS
# ==============================================================================
# Breaks For Additive Seasonal & Trend analysis for deforestation detection
# ==============================================================================

source("R/01_config.R")

# Extract time series from NDVI stack for a single pixel
extract_pixel_timeseries <- function(ndvi_stack, x, y) {
  # Extract values at specific coordinates
  point <- vect(data.frame(x = x, y = y), crs = crs(ndvi_stack))
  values <- extract(ndvi_stack, point)
  
  # Remove first column (ID)
  ts_values <- as.numeric(values[1, -1])
  
  return(ts_values)
}

# Extract mean NDVI time series for entire study area
extract_mean_timeseries <- function(ndvi_stack) {
  cat("Extracting mean NDVI time series...\n")
  
  # Calculate mean NDVI for each time step
  mean_values <- global(ndvi_stack, fun = "mean", na.rm = TRUE)
  mean_values <- as.numeric(mean_values[, 1])
  
  cat("✓ Mean time series extracted!\n")
  cat("  Length:", length(mean_values), "observations\n")
  cat("  Range:", range(mean_values, na.rm = TRUE), "\n\n")
  
  return(mean_values)
}

# Create time series object from values
create_timeseries_object <- function(values, start_year, frequency = BFAST_FREQUENCY) {
  # Create ts object
  ts_obj <- ts(values, start = start_year, frequency = frequency)
  
  return(ts_obj)
}

# Run BFAST analysis
run_bfast <- function(ts_obj, h = BFAST_H, season = BFAST_SEASON, max.iter = 10) {
  cat("Running BFAST analysis...\n")
  cat("  Time series length:", length(ts_obj), "\n")
  cat("  Frequency:", frequency(ts_obj), "\n")
  cat("  H parameter:", h, "\n")
  cat("  Season:", season, "\n\n")
  
  # Run BFAST
  result <- bfast(ts_obj, h = h, season = season, max.iter = max.iter)
  
  cat("✓ BFAST analysis complete!\n")
  
  # Extract breakpoints
  if (!is.null(result$output[[1]]$bp.Vt)) {
    breaks <- result$output[[1]]$bp.Vt$breakpoints
    cat("  Breakpoints detected:", length(breaks), "\n")
    if (length(breaks) > 0) {
      cat("  Breakpoint positions:", breaks, "\n")
    }
  } else {
    cat("  No breakpoints detected\n")
  }
  
  cat("\n")
  return(result)
}

# Apply BFAST to each pixel (pixel-wise analysis)
bfast_pixelwise <- function(ndvi_stack, start_year, h = BFAST_H, 
                           season = BFAST_SEASON, progress = TRUE) {
  cat("Running pixel-wise BFAST analysis...\n")
  cat("  This may take a long time for large areas!\n\n")
  
  # Get dimensions
  n_layers <- nlyr(ndvi_stack)
  n_cells <- ncell(ndvi_stack[[1]])
  
  # Initialize output rasters
  breakpoint_count <- rast(ndvi_stack[[1]])
  breakpoint_count[] <- 0
  
  breakpoint_year <- rast(ndvi_stack[[1]])
  breakpoint_year[] <- NA
  
  # Extract time series for each pixel
  cat("Processing pixels...\n")
  
  # Sample pixels for faster processing (adjust sample size as needed)
  sample_size <- min(10000, n_cells)  # Process max 10,000 pixels
  sample_cells <- sample(1:n_cells, sample_size)
  
  for (i in seq_along(sample_cells)) {
    if (progress && i %% 100 == 0) {
      cat("  Progress:", round(i/length(sample_cells)*100, 1), "%\r")
    }
    
    cell <- sample_cells[i]
    
    # Extract time series for this pixel
    values <- as.numeric(ndvi_stack[cell])
    
    # Skip if too many NAs
    if (sum(is.na(values)) > length(values) * 0.5) next
    
    # Create time series
    ts_obj <- ts(values, start = start_year, frequency = BFAST_FREQUENCY)
    
    # Run BFAST
    tryCatch({
      result <- bfast(ts_obj, h = h, season = season, max.iter = 5)
      
      # Extract breakpoints
      if (!is.null(result$output[[1]]$bp.Vt)) {
        breaks <- result$output[[1]]$bp.Vt$breakpoints
        if (length(breaks) > 0) {
          breakpoint_count[cell] <- length(breaks)
          breakpoint_year[cell] <- start_year + (breaks[1] / frequency(ts_obj))
        }
      }
    }, error = function(e) {
      # Skip pixels with errors
    })
  }
  
  if (progress) cat("\n")
  
  cat("✓ Pixel-wise BFAST complete!\n\n")
  
  return(list(
    BreakpointCount = breakpoint_count,
    BreakpointYear = breakpoint_year
  ))
}

# Plot BFAST results
plot_bfast_results <- function(bfast_result, output_file = NULL) {
  if (is.null(output_file)) {
    output_file <- file.path(FIGURES_DIR, "bfast_analysis.png")
  }
  
  cat("Plotting BFAST results...\n")
  
  png(output_file, width = MAP_WIDTH * 100, height = MAP_HEIGHT * 100, res = MAP_DPI)
  plot(bfast_result)
  dev.off()
  
  cat("  Saved plot:", output_file, "\n\n")
}

# Main BFAST workflow
analyze_bfast <- function(ndvi_stack, start_year = 2000, 
                         pixelwise = FALSE, 
                         output_dir = OUTPUT_DIR) {
  cat("========================================\n")
  cat("BFAST TIME-SERIES ANALYSIS\n")
  cat("========================================\n\n")
  
  # Extract mean time series
  mean_ts_values <- extract_mean_timeseries(ndvi_stack)
  
  # Create time series object
  ts_obj <- create_timeseries_object(mean_ts_values, start_year)
  
  # Run BFAST on mean time series
  bfast_result <- run_bfast(ts_obj)
  
  # Plot results
  plot_bfast_results(bfast_result)
  
  # Pixel-wise analysis (optional, time-consuming)
  pixelwise_results <- NULL
  if (pixelwise) {
    pixelwise_results <- bfast_pixelwise(ndvi_stack, start_year)
    
    # Save pixel-wise results
    breakpoint_file <- file.path(MAPS_DIR, "bfast_breakpoints.tif")
    breakpoint_year_file <- file.path(MAPS_DIR, "bfast_breakpoint_years.tif")
    
    writeRaster(pixelwise_results$BreakpointCount, breakpoint_file, overwrite = TRUE)
    writeRaster(pixelwise_results$BreakpointYear, breakpoint_year_file, overwrite = TRUE)
    
    cat("  Saved pixel-wise results\n\n")
  }
  
  cat("✓ BFAST analysis complete!\n\n")
  
  return(list(
    MeanTS = bfast_result,
    Pixelwise = pixelwise_results
  ))
}

cat("✓ BFAST analysis functions loaded!\n\n")

