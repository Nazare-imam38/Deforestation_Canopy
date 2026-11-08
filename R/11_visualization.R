# ==============================================================================
# VISUALIZATION AND MAPPING
# ==============================================================================
# Create maps and plots for deforestation analysis
# ==============================================================================

source("R/01_config.R")

# Plot deforestation map using tmap
plot_deforestation_map <- function(deforestation_map, aoi = NULL, 
                                  output_file = NULL) {
  if (is.null(output_file)) {
    output_file <- file.path(FIGURES_DIR, "deforestation_map.png")
  }
  
  cat("Creating deforestation map...\n")
  
  # Set tmap mode
  tmap_mode("plot")
  
  # Create map
  p <- tm_shape(deforestation_map) +
    tm_raster(
      title = "Deforestation",
      palette = c("green", "red"),
      labels = c("No Change", "Deforestation"),
      style = "cat"
    ) +
    tm_layout(
      title = "Deforestation Detection using Landsat Time-Series",
      title.position = c("center", "top"),
      legend.position = c("right", "bottom")
    )
  
  # Add study area boundary if provided
  if (!is.null(aoi)) {
    p <- p + tm_shape(aoi) +
      tm_borders(col = "blue", lwd = 2)
  }
  
  # Save map
  tmap_save(p, output_file, width = MAP_WIDTH, height = MAP_HEIGHT, dpi = MAP_DPI)
  
  cat("  Saved map:", output_file, "\n\n")
}

# Plot NDVI time series
plot_ndvi_timeseries <- function(ndvi_values, dates = NULL, output_file = NULL) {
  if (is.null(output_file)) {
    output_file <- file.path(FIGURES_DIR, "ndvi_timeseries.png")
  }
  
  cat("Creating NDVI time series plot...\n")
  
  # Create data frame
  if (is.null(dates)) {
    dates <- seq_along(ndvi_values)
  }
  
  df <- data.frame(
    Date = dates,
    NDVI = ndvi_values
  )
  
  # Create plot
  p <- ggplot(df, aes(x = Date, y = NDVI)) +
    geom_line(color = "darkgreen", size = 1) +
    geom_point(color = "darkgreen", size = 2) +
    geom_hline(yintercept = NDVI_FOREST_MIN, linetype = "dashed", color = "red") +
    labs(
      title = "NDVI Time Series",
      x = "Date",
      y = "NDVI",
      subtitle = paste("Forest threshold:", NDVI_FOREST_MIN)
    ) +
    theme_minimal() +
    theme(
      plot.title = element_text(size = 14, face = "bold"),
      axis.text.x = element_text(angle = 45, hjust = 1)
    )
  
  ggsave(output_file, p, width = MAP_WIDTH, height = MAP_HEIGHT, dpi = MAP_DPI)
  
  cat("  Saved plot:", output_file, "\n\n")
}

# Plot NBR time series
plot_nbr_timeseries <- function(nbr_values, dates = NULL, output_file = NULL) {
  if (is.null(output_file)) {
    output_file <- file.path(FIGURES_DIR, "nbr_timeseries.png")
  }
  
  cat("Creating NBR time series plot...\n")
  
  # Create data frame
  if (is.null(dates)) {
    dates <- seq_along(nbr_values)
  }
  
  df <- data.frame(
    Date = dates,
    NBR = nbr_values
  )
  
  # Create plot
  p <- ggplot(df, aes(x = Date, y = NBR)) +
    geom_line(color = "brown", size = 1) +
    geom_point(color = "brown", size = 2) +
    labs(
      title = "NBR Time Series",
      x = "Date",
      y = "NBR"
    ) +
    theme_minimal() +
    theme(
      plot.title = element_text(size = 14, face = "bold"),
      axis.text.x = element_text(angle = 45, hjust = 1)
    )
  
  ggsave(output_file, p, width = MAP_WIDTH, height = MAP_HEIGHT, dpi = MAP_DPI)
  
  cat("  Saved plot:", output_file, "\n\n")
}

# Plot dNBR map
plot_dnbr_map <- function(dnbr_map, output_file = NULL) {
  if (is.null(output_file)) {
    output_file <- file.path(FIGURES_DIR, "dnbr_map.png")
  }
  
  cat("Creating dNBR map...\n")
  
  tmap_mode("plot")
  
  p <- tm_shape(dnbr_map) +
    tm_raster(
      title = "dNBR",
      palette = PALETTE_DEFORESTATION,
      style = "cont",
      midpoint = 0
    ) +
    tm_layout(
      title = "Normalized Burn Ratio Difference (dNBR)",
      title.position = c("center", "top")
    )
  
  tmap_save(p, output_file, width = MAP_WIDTH, height = MAP_HEIGHT, dpi = MAP_DPI)
  
  cat("  Saved map:", output_file, "\n\n")
}

# Plot land cover classification
plot_landcover_map <- function(landcover_map, aoi = NULL, output_file = NULL) {
  if (is.null(output_file)) {
    output_file <- file.path(FIGURES_DIR, "landcover_map.png")
  }
  
  cat("Creating land cover map...\n")
  
  tmap_mode("plot")
  
  # Color palette for land cover classes
  lc_colors <- c(
    "Forest" = "darkgreen",
    "Agriculture" = "yellow",
    "Built-up" = "red",
    "Water" = "blue",
    "Barren" = "tan"
  )
  
  p <- tm_shape(landcover_map) +
    tm_raster(
      title = "Land Cover",
      palette = lc_colors,
      style = "cat"
    ) +
    tm_layout(
      title = "Land Cover Classification",
      title.position = c("center", "top")
    )
  
  if (!is.null(aoi)) {
    p <- p + tm_shape(aoi) +
      tm_borders(col = "black", lwd = 2)
  }
  
  tmap_save(p, output_file, width = MAP_WIDTH, height = MAP_HEIGHT, dpi = MAP_DPI)
  
  cat("  Saved map:", output_file, "\n\n")
}

# Create deforestation statistics bar chart
plot_deforestation_stats <- function(stats, output_file = NULL) {
  if (is.null(output_file)) {
    output_file <- file.path(FIGURES_DIR, "deforestation_statistics.png")
  }
  
  cat("Creating deforestation statistics plot...\n")
  
  # Create plot
  p <- ggplot(stats, aes(x = Metric, y = Value)) +
    geom_bar(stat = "identity", fill = "steelblue") +
    labs(
      title = "Deforestation Statistics",
      x = "Metric",
      y = "Value"
    ) +
    theme_minimal() +
    theme(
      plot.title = element_text(size = 14, face = "bold"),
      axis.text.x = element_text(angle = 45, hjust = 1)
    )
  
  ggsave(output_file, p, width = MAP_WIDTH, height = MAP_HEIGHT, dpi = MAP_DPI)
  
  cat("  Saved plot:", output_file, "\n\n")
}

# Create multi-panel comparison map
plot_comparison_map <- function(before_map, after_map, change_map, 
                               output_file = NULL) {
  if (is.null(output_file)) {
    output_file <- file.path(FIGURES_DIR, "comparison_map.png")
  }
  
  cat("Creating comparison map...\n")
  
  tmap_mode("plot")
  
  # Create individual maps
  p1 <- tm_shape(before_map) +
    tm_raster(title = "Before", palette = PALETTE_NDVI) +
    tm_layout(title = "Before (2015)")
  
  p2 <- tm_shape(after_map) +
    tm_raster(title = "After", palette = PALETTE_NDVI) +
    tm_layout(title = "After (2024)")
  
  p3 <- tm_shape(change_map) +
    tm_raster(title = "Change", palette = PALETTE_DEFORESTATION) +
    tm_layout(title = "Deforestation")
  
  # Combine maps
  combined <- tmap_arrange(p1, p2, p3, ncol = 3)
  
  tmap_save(combined, output_file, width = MAP_WIDTH * 3, height = MAP_HEIGHT, dpi = MAP_DPI)
  
  cat("  Saved map:", output_file, "\n\n")
}

# Main visualization workflow
create_all_visualizations <- function(deforestation_results, ndvi_ts = NULL, 
                                      nbr_ts = NULL, landcover = NULL) {
  cat("========================================\n")
  cat("CREATING ALL VISUALIZATIONS\n")
  cat("========================================\n\n")
  
  # Deforestation map
  if (!is.null(deforestation_results$Deforestation)) {
    plot_deforestation_map(deforestation_results$Deforestation)
  }
  
  # dNBR map
  if (!is.null(deforestation_results$dNBR)) {
    plot_dnbr_map(deforestation_results$dNBR)
  }
  
  # NDVI time series
  if (!is.null(ndvi_ts)) {
    mean_ndvi <- global(ndvi_ts, fun = "mean", na.rm = TRUE)
    plot_ndvi_timeseries(as.numeric(mean_ndvi[, 1]))
  }
  
  # NBR time series
  if (!is.null(nbr_ts)) {
    mean_nbr <- global(nbr_ts, fun = "mean", na.rm = TRUE)
    plot_nbr_timeseries(as.numeric(mean_nbr[, 1]))
  }
  
  # Land cover map
  if (!is.null(landcover)) {
    plot_landcover_map(landcover)
  }
  
  # Statistics plot
  if (!is.null(deforestation_results$Statistics)) {
    plot_deforestation_stats(deforestation_results$Statistics)
  }
  
  cat("✓ All visualizations created!\n\n")
}

cat("✓ Visualization functions loaded!\n\n")

