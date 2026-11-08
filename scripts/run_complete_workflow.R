# ==============================================================================
# COMPLETE DEFORESTATION DETECTION WORKFLOW
# ==============================================================================
# Run this script to execute the entire analysis pipeline from start to finish
# ==============================================================================

cat("========================================\n")
cat("DEFORESTATION DETECTION - COMPLETE WORKFLOW\n")
cat("========================================\n\n")

start_time <- Sys.time()

# Step 1: Setup
cat("STEP 1: Setting up packages and configuration...\n")
cat("-----------------------------------------------\n")
source("R/00_setup_packages.R")
source("R/01_config.R")
cat("✓ Setup complete\n\n")

# Step 2: Process data
cat("STEP 2: Processing Landsat data...\n")
cat("----------------------------------\n")
tryCatch({
  source("scripts/process_manual_landsat.R")
  cat("✓ Data processing complete\n\n")
}, error = function(e) {
  cat("✗ Error in data processing:", e$message, "\n")
  stop("Please check your Landsat data files in data/Landsat/")
})

# Step 3: Calculate indices
cat("STEP 3: Calculating spectral indices...\n")
cat("---------------------------------------\n")
tryCatch({
  source("scripts/calculate_indices_from_processed.R")
  cat("✓ Indices calculated\n\n")
}, error = function(e) {
  cat("✗ Error calculating indices:", e$message, "\n")
  stop("Please ensure data processing completed successfully")
})

# Step 4: Change detection
cat("STEP 4: Detecting deforestation changes...\n")
cat("------------------------------------------\n")
tryCatch({
  source("scripts/detect_deforestation_changes.R")
  cat("✓ Change detection complete\n\n")
}, error = function(e) {
  cat("✗ Error in change detection:", e$message, "\n")
  stop("Please ensure indices were calculated successfully")
})

# Step 5: Create maps
cat("STEP 5: Creating visualization maps...\n")
cat("--------------------------------------\n")
tryCatch({
  source("scripts/create_deforestation_maps.R")
  cat("✓ Maps created\n\n")
}, error = function(e) {
  cat("⚠ Warning: Map creation had issues:", e$message, "\n")
  cat("Continuing with report generation...\n\n")
})

# Step 6: Generate report
cat("STEP 6: Generating HTML report...\n")
cat("---------------------------------\n")
tryCatch({
  source("scripts/generate_html_report.R")
  cat("✓ Report generated\n\n")
}, error = function(e) {
  cat("✗ Error generating report:", e$message, "\n")
  cat("You can manually open: output/report/deforestation_report.html\n\n")
})

# Calculate total time
end_time <- Sys.time()
total_time <- difftime(end_time, start_time, units = "mins")

cat("========================================\n")
cat("✓ COMPLETE WORKFLOW FINISHED!\n")
cat("========================================\n\n")
cat("Total processing time:", round(total_time, 2), "minutes\n\n")
cat("Output files are in the 'output/' directory:\n")
cat("  - Indices: output/indices/\n")
cat("  - Change detection: output/change_detection/\n")
cat("  - Maps: output/maps/\n")
cat("  - Figures: output/figures/\n")
cat("  - Report: output/report/deforestation_report.html\n\n")
cat("HTML report should be open in your browser.\n")
cat("If not, manually open: output/report/deforestation_report.html\n\n")
