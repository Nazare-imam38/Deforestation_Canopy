# ==============================================================================
# CHANGE DETECTION
# ==============================================================================
# Detect deforestation using NBR differencing and thresholding
# ==============================================================================

source("R/01_config.R")

# Classify deforestation using dNBR threshold
classify_deforestation <- function(dnbr, threshold = DNBR_THRESHOLD) {
  cat("Classifying deforestation using dNBR threshold...\n")
  cat("  Threshold:", threshold, "\n")
  
  # Negative dNBR values indicate forest loss
  # Values below threshold are classified as deforestation
  deforestation <- dnbr < threshold
  
  # Convert to binary (0 = no change, 1 = deforestation)
  deforestation <- ifel(deforestation, 1, 0)
  
  names(deforestation) <- "Deforestation"
  
  # Calculate statistics
  stats <- freq(deforestation)
  total_pixels <- sum(stats$count)
  deforested_pixels <- stats$count[stats$value == 1]
  
  if (length(deforested_pixels) > 0) {
    deforested_area_pct <- (deforested_pixels / total_pixels) * 100
    cat("  Deforested pixels:", deforested_pixels, "\n")
    cat("  Deforested area:", round(deforested_area_pct, 2), "%\n")
  } else {
    cat("  No deforestation detected\n")
  }
  
  cat("✓ Classification complete!\n\n")
  return(deforestation)
}

# Create deforestation severity classes
classify_deforestation_severity <- function(dnbr) {
  cat("Classifying deforestation severity...\n")
  
  # Severity classes based on dNBR values
  # -0.1 to 0: Low severity
  # -0.27 to -0.1: Moderate severity
  # -0.44 to -0.27: High severity
  # < -0.44: Very high severity
  
  severity <- classify(
    dnbr,
    rcl = matrix(c(
      -Inf, -0.44, 4,  # Very high severity
      -0.44, -0.27, 3, # High severity
      -0.27, -0.1, 2,  # Moderate severity
      -0.1, 0, 1,      # Low severity
      0, Inf, 0        # No change
    ), ncol = 3, byrow = TRUE),
    include.lowest = TRUE
  )
  
  # Set class names
  levels(severity) <- data.frame(
    id = 0:4,
    class = c("No Change", "Low", "Moderate", "High", "Very High")
  )
  
  names(severity) <- "Severity"
  
  cat("✓ Severity classification complete!\n\n")
  return(severity)
}

# Calculate change statistics
calculate_change_statistics <- function(deforestation_map, pixel_size = PIXEL_SIZE) {
  cat("Calculating change statistics...\n")
  
  # Calculate pixel area in hectares
  pixel_area_ha <- (pixel_size^2) / 10000  # Convert m² to hectares
  
  # Get frequency table
  freq_table <- freq(deforestation_map)
  
  # Calculate areas
  total_pixels <- sum(freq_table$count)
  total_area_ha <- total_pixels * pixel_area_ha
  
  deforested_pixels <- freq_table$count[freq_table$value == 1]
  if (length(deforested_pixels) == 0) deforested_pixels <- 0
  
  deforested_area_ha <- deforested_pixels * pixel_area_ha
  deforested_area_pct <- (deforested_pixels / total_pixels) * 100
  
  # Create statistics data frame
  stats <- data.frame(
    Metric = c(
      "Total Area (ha)",
      "Deforested Area (ha)",
      "Deforested Area (%)",
      "Total Pixels",
      "Deforested Pixels"
    ),
    Value = c(
      round(total_area_ha, 2),
      round(deforested_area_ha, 2),
      round(deforested_area_pct, 2),
      total_pixels,
      deforested_pixels
    )
  )
  
  cat("✓ Statistics calculated!\n")
  cat("  Total Area:", round(total_area_ha, 2), "ha\n")
  cat("  Deforested Area:", round(deforested_area_ha, 2), "ha (", 
      round(deforested_area_pct, 2), "%)\n\n")
  
  return(stats)
}

# Detect deforestation hotspots (clusters)
detect_deforestation_hotspots <- function(deforestation_map, min_size = 10) {
  cat("Detecting deforestation hotspots...\n")
  
  # Convert to polygons
  deforestation_poly <- as.polygons(deforestation_map)
  
  # Filter only deforestation areas (value == 1)
  deforestation_poly <- deforestation_poly[deforestation_poly$Deforestation == 1]
  
  # Calculate area for each polygon
  deforestation_poly$area_ha <- expanse(deforestation_poly, unit = "ha")
  
  # Filter by minimum size
  hotspots <- deforestation_poly[deforestation_poly$area_ha >= min_size]
  
  cat("  Hotspots found:", nrow(hotspots), "\n")
  if (nrow(hotspots) > 0) {
    cat("  Total hotspot area:", round(sum(hotspots$area_ha), 2), "ha\n")
  }
  
  cat("✓ Hotspot detection complete!\n\n")
  return(hotspots)
}

# Main change detection workflow
detect_deforestation <- function(nbr_before, nbr_after, 
                                threshold = DNBR_THRESHOLD,
                                calculate_severity = TRUE,
                                detect_hotspots = TRUE) {
  cat("========================================\n")
  cat("DEFORESTATION CHANGE DETECTION\n")
  cat("========================================\n\n")
  
  # Calculate dNBR
  dnbr <- calculate_dnbr(nbr_before, nbr_after)
  
  # Save dNBR map
  writeRaster(dnbr, OUTPUT_FILES$dnbr_map, overwrite = TRUE)
  cat("  Saved dNBR map:", OUTPUT_FILES$dnbr_map, "\n\n")
  
  # Classify deforestation
  deforestation_map <- classify_deforestation(dnbr, threshold)
  
  # Save deforestation map
  writeRaster(deforestation_map, OUTPUT_FILES$deforestation_map, overwrite = TRUE)
  cat("  Saved deforestation map:", OUTPUT_FILES$deforestation_map, "\n\n")
  
  # Calculate severity if requested
  severity_map <- NULL
  if (calculate_severity) {
    severity_map <- classify_deforestation_severity(dnbr)
    severity_file <- file.path(MAPS_DIR, "deforestation_severity.tif")
    writeRaster(severity_map, severity_file, overwrite = TRUE)
    cat("  Saved severity map:", severity_file, "\n\n")
  }
  
  # Calculate statistics
  stats <- calculate_change_statistics(deforestation_map)
  
  # Save statistics
  write.csv(stats, OUTPUT_FILES$deforestation_stats, row.names = FALSE)
  cat("  Saved statistics:", OUTPUT_FILES$deforestation_stats, "\n\n")
  
  # Detect hotspots if requested
  hotspots <- NULL
  if (detect_hotspots) {
    hotspots <- detect_deforestation_hotspots(deforestation_map)
    if (nrow(hotspots) > 0) {
      hotspots_file <- file.path(MAPS_DIR, "deforestation_hotspots.shp")
      writeVector(hotspots, hotspots_file, overwrite = TRUE)
      cat("  Saved hotspots:", hotspots_file, "\n\n")
    }
  }
  
  cat("✓ Change detection complete!\n\n")
  
  return(list(
    dNBR = dnbr,
    Deforestation = deforestation_map,
    Severity = severity_map,
    Statistics = stats,
    Hotspots = hotspots
  ))
}

cat("✓ Change detection functions loaded!\n\n")

