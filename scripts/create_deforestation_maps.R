# ==============================================================================
# CREATE DEFORESTATION VISUALIZATION MAPS
# ==============================================================================
# Creates publication-quality maps of deforestation detection results
# ==============================================================================

cat("========================================\n")
cat("CREATING DEFORESTATION MAPS\n")
cat("========================================\n\n")

# Load packages
source("R/00_setup_packages.R")
source("R/01_config.R")

# Load change detection results if not already loaded
if (!exists("dNBR") || !exists("deforestation_class")) {
  cat("Loading change detection results...\n")
  change_dir <- file.path(OUTPUT_DIR, "change_detection")
  
  dNBR_file <- file.path(change_dir, "dnbr.tif")
  class_file <- file.path(change_dir, "deforestation_classification.tif")
  ndvi_change_file <- file.path(change_dir, "ndvi_change.tif")
  
  if (file.exists(dNBR_file)) {
    dNBR <- rast(dNBR_file)
    cat("✓ Loaded dNBR\n")
  } else {
    stop("dNBR not found. Run: source('scripts/detect_deforestation_changes.R')")
  }
  
  if (file.exists(class_file)) {
    deforestation_class <- rast(class_file)
    cat("✓ Loaded deforestation classification\n")
  }
  
  if (file.exists(ndvi_change_file)) {
    ndvi_change <- rast(ndvi_change_file)
    cat("✓ Loaded NDVI change\n\n")
  }
}

cat("========================================\n")
cat("STEP 1: CREATING BASIC MAPS\n")
cat("========================================\n\n")

# Create maps directory
maps_dir <- file.path(OUTPUT_DIR, "maps")
dir.create(maps_dir, showWarnings = FALSE, recursive = TRUE)

cat("Creating visualization maps...\n\n")

# Map 1: dNBR Map
cat("1. Creating dNBR map...\n")
png(file.path(maps_dir, "dnbr_map.png"), width = 12, height = 10, units = "in", res = 300)
plot(dNBR, 
     main = "Deforestation Detection (dNBR)\nPositive values indicate forest loss",
     col = rev(terrain.colors(255)),
     axes = TRUE,
     mar = c(5, 4, 4, 2))
dev.off()
cat("   ✓ Saved: dnbr_map.png\n")

# Map 2: Deforestation Classification
cat("2. Creating deforestation classification map...\n")
png(file.path(maps_dir, "deforestation_classification_map.png"), 
    width = 12, height = 10, units = "in", res = 300)

# Define colors for classification
class_colors <- c(
  "1" = "darkgreen",      # Reforestation
  "2" = "lightgreen",     # No change
  "3" = "yellow",         # Low deforestation
  "4" = "orange",         # Moderate deforestation
  "5" = "red",            # High deforestation
  "6" = "darkred"         # Severe deforestation
)

class_labels <- c(
  "1" = "Reforestation",
  "2" = "No Change",
  "3" = "Low Deforestation",
  "4" = "Moderate Deforestation",
  "5" = "High Deforestation",
  "6" = "Severe Deforestation"
)

plot(deforestation_class,
     main = "Deforestation Classification",
     col = class_colors,
     axes = TRUE,
     mar = c(5, 4, 4, 2))

# Add legend
legend("bottomright",
       legend = class_labels,
       fill = class_colors,
       title = "Classification",
       cex = 0.8)

dev.off()
cat("   ✓ Saved: deforestation_classification_map.png\n")

# Map 3: NDVI Change
cat("3. Creating NDVI change map...\n")
png(file.path(maps_dir, "ndvi_change_map.png"), 
    width = 12, height = 10, units = "in", res = 300)
plot(ndvi_change,
     main = "NDVI Change\nPositive = vegetation gain, Negative = vegetation loss",
     col = colorRampPalette(c("red", "white", "green"))(255),
     axes = TRUE,
     mar = c(5, 4, 4, 2))
dev.off()
cat("   ✓ Saved: ndvi_change_map.png\n\n")

cat("========================================\n")
cat("STEP 2: CREATING COMPARISON MAPS\n")
cat("========================================\n\n")

# Load NDVI time series for comparison
if (exists("ndvi_stack")) {
  cat("4. Creating NDVI time series comparison...\n")
  png(file.path(maps_dir, "ndvi_timeseries_comparison.png"),
      width = 16, height = 5, units = "in", res = 300)
  
  par(mfrow = c(1, nlyr(ndvi_stack)), mar = c(3, 3, 3, 1))
  for (i in 1:nlyr(ndvi_stack)) {
    plot(ndvi_stack[[i]],
         main = names(ndvi_stack)[i],
         col = colorRampPalette(c("brown", "yellow", "green"))(255),
         axes = TRUE)
  }
  dev.off()
  cat("   ✓ Saved: ndvi_timeseries_comparison.png\n")
}

# Load NBR time series for comparison
if (exists("nbr_stack")) {
  cat("5. Creating NBR time series comparison...\n")
  png(file.path(maps_dir, "nbr_timeseries_comparison.png"),
      width = 16, height = 5, units = "in", res = 300)
  
  par(mfrow = c(1, nlyr(nbr_stack)), mar = c(3, 3, 3, 1))
  for (i in 1:nlyr(nbr_stack)) {
    plot(nbr_stack[[i]],
         main = names(nbr_stack)[i],
         col = colorRampPalette(c("brown", "yellow", "green"))(255),
         axes = TRUE)
  }
  dev.off()
  cat("   ✓ Saved: nbr_timeseries_comparison.png\n\n")
}

cat("========================================\n")
cat("STEP 3: CREATING STATISTICAL PLOTS\n")
cat("========================================\n\n")

# Create figures directory
figures_dir <- file.path(OUTPUT_DIR, "figures")
dir.create(figures_dir, showWarnings = FALSE, recursive = TRUE)

# Plot 1: Deforestation area statistics
cat("6. Creating deforestation statistics plot...\n")
png(file.path(figures_dir, "deforestation_statistics.png"),
    width = 10, height = 6, units = "in", res = 300)

# Read statistics
stats_file <- file.path(OUTPUT_DIR, "change_detection", "deforestation_statistics.csv")
if (file.exists(stats_file)) {
  stats <- read.csv(stats_file)
  
  # Create bar plot of classification
  class_counts <- c(
    sum(values(deforestation_class) == 1, na.rm = TRUE),
    sum(values(deforestation_class) == 2, na.rm = TRUE),
    sum(values(deforestation_class) == 3, na.rm = TRUE),
    sum(values(deforestation_class) == 4, na.rm = TRUE),
    sum(values(deforestation_class) == 5, na.rm = TRUE),
    sum(values(deforestation_class) == 6, na.rm = TRUE)
  )
  
  class_names <- c("Reforestation", "No Change", "Low", "Moderate", "High", "Severe")
  
  barplot(class_counts,
          names.arg = class_names,
          main = "Deforestation Classification Distribution",
          xlab = "Classification",
          ylab = "Number of Pixels",
          col = class_colors,
          las = 2)
}
dev.off()
cat("   ✓ Saved: deforestation_statistics.png\n")

# Plot 2: dNBR histogram
cat("7. Creating dNBR distribution histogram...\n")
png(file.path(figures_dir, "dnbr_histogram.png"),
    width = 10, height = 6, units = "in", res = 300)

dNBR_vals <- values(dNBR)
dNBR_vals <- dNBR_vals[!is.na(dNBR_vals)]

hist(dNBR_vals,
     breaks = 100,
     main = "dNBR Distribution",
     xlab = "dNBR Value",
     ylab = "Frequency",
     col = "lightblue",
     border = "black")
abline(v = 0, col = "red", lwd = 2, lty = 2)
legend("topright", "Zero (no change)", col = "red", lty = 2, lwd = 2)

dev.off()
cat("   ✓ Saved: dnbr_histogram.png\n\n")

cat("========================================\n")
cat("STEP 4: CREATING SUMMARY REPORT\n")
cat("========================================\n\n")

# Create a summary report
report_file <- file.path(OUTPUT_DIR, "deforestation_report.txt")
cat("DEFORESTATION DETECTION REPORT\n", file = report_file)
cat("==============================\n\n", file = report_file, append = TRUE)
cat("Study Area:", STUDY_AREA_NAME, "\n", file = report_file, append = TRUE)
cat("Analysis Date:", Sys.Date(), "\n\n", file = report_file, append = TRUE)

cat("TIME SERIES INFORMATION\n", file = report_file, append = TRUE)
cat("-----------------------\n", file = report_file, append = TRUE)
if (exists("ndvi_stack")) {
  cat("NDVI Dates:", paste(names(ndvi_stack), collapse = ", "), "\n", file = report_file, append = TRUE)
}
if (exists("nbr_stack")) {
  cat("NBR Dates:", paste(names(nbr_stack), collapse = ", "), "\n\n", file = report_file, append = TRUE)
}

cat("DEFORESTATION STATISTICS\n", file = report_file, append = TRUE)
cat("------------------------\n", file = report_file, append = TRUE)
if (file.exists(stats_file)) {
  stats <- read.csv(stats_file)
  for (i in 1:nrow(stats)) {
    cat(stats$Metric[i], ":", stats$Value[i], "\n", file = report_file, append = TRUE)
  }
}

cat("\nCLASSIFICATION SUMMARY\n", file = report_file, append = TRUE)
cat("----------------------\n", file = report_file, append = TRUE)
class_counts <- c(
  sum(values(deforestation_class) == 1, na.rm = TRUE),
  sum(values(deforestation_class) == 2, na.rm = TRUE),
  sum(values(deforestation_class) == 3, na.rm = TRUE),
  sum(values(deforestation_class) == 4, na.rm = TRUE),
  sum(values(deforestation_class) == 5, na.rm = TRUE),
  sum(values(deforestation_class) == 6, na.rm = TRUE)
)

total_pixels <- sum(class_counts)
for (i in 1:6) {
  pct <- round(class_counts[i] / total_pixels * 100, 2)
  cat(class_names[i], ":", class_counts[i], "pixels (", pct, "%)\n", 
      file = report_file, append = TRUE)
}

cat("\n✓ Report saved:", report_file, "\n\n")

cat("========================================\n")
cat("✓ MAP CREATION COMPLETE!\n")
cat("========================================\n\n")

cat("Maps created in:", maps_dir, "\n")
cat("Figures created in:", figures_dir, "\n")
cat("Report saved:", report_file, "\n\n")

cat("Files Created:\n")
cat("  Maps:\n")
cat("    - dnbr_map.png\n")
cat("    - deforestation_classification_map.png\n")
cat("    - ndvi_change_map.png\n")
cat("    - ndvi_timeseries_comparison.png\n")
cat("    - nbr_timeseries_comparison.png\n")
cat("  Figures:\n")
cat("    - deforestation_statistics.png\n")
cat("    - dnbr_histogram.png\n")
cat("  Report:\n")
cat("    - deforestation_report.txt\n\n")

cat("You can view the maps by opening the PNG files in:", maps_dir, "\n\n")

