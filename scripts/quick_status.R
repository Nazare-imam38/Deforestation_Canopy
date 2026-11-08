# ==============================================================================
# QUICK STATUS CHECK
# ==============================================================================
# Quick overview of project readiness
# ==============================================================================

cat("========================================\n")
cat("QUICK STATUS CHECK\n")
cat("========================================\n\n")

# Check packages
cat("1. R Packages: ")
if (require(sf, quietly = TRUE) && require(terra, quietly = TRUE) && 
    require(rgee, quietly = TRUE)) {
  cat("✓ READY\n")
} else {
  cat("✗ NOT READY\n")
}

# Check configuration
cat("2. Configuration: ")
tryCatch({
  source("R/01_config.R")
  cat("✓ READY\n")
}, error = function(e) {
  cat("✗ NOT READY\n")
})

# Check study area
cat("3. Study Area: ")
tryCatch({
  source("R/03_load_study_area.R")
  aoi <- load_study_area()
  cat("✓ READY (", round(as.numeric(st_area(aoi)) / 1e6, 2), " km²)\n", sep = "")
}, error = function(e) {
  cat("✗ NOT READY\n")
})

# Check GEE
cat("4. Google Earth Engine: ")
if (require(rgee, quietly = TRUE)) {
  tryCatch({
    ee_check()
    test <- ee$Image("LANDSAT/LC08/C02/T1_L2/LC08_044034_20140318")
    test$getInfo()
    cat("✓ READY\n")
  }, error = function(e) {
    if (grepl("not registered", e$message, ignore.case = TRUE)) {
      cat("⏳ WAITING FOR REGISTRATION\n")
    } else {
      cat("✗ NOT READY\n")
    }
  })
} else {
  cat("✗ NOT READY\n")
}

# Check data
cat("5. Landsat Data: ")
landsat_files <- list.files("data/Landsat", pattern = "\\.tif$", 
                            full.names = TRUE, recursive = TRUE)
if (length(landsat_files) > 0) {
  cat("✓ READY (", length(landsat_files), " files)\n", sep = "")
} else {
  cat("✗ NOT AVAILABLE\n")
}

cat("\n========================================\n")
cat("SUMMARY\n")
cat("========================================\n\n")

if (length(landsat_files) > 0) {
  cat("✓ You have Landsat data! You can run analysis now:\n")
  cat("  source('scripts/main_workflow.R')\n\n")
} else {
  cat("⚠ No Landsat data found.\n\n")
  
  # Check GEE status
  if (require(rgee, quietly = TRUE)) {
    tryCatch({
      ee_check()
      test <- ee$Image("LANDSAT/LC08/C02/T1_L2/LC08_044034_20140318")
      test$getInfo()
      cat("✓ GEE is ready! Download data:\n")
      cat("  source('scripts/download_landsat_gee.R')\n\n")
    }, error = function(e) {
      if (grepl("not registered", e$message, ignore.case = TRUE)) {
        cat("⏳ GEE registration pending. Options:\n")
        cat("  1. Wait for approval (24-48 hours)\n")
        cat("  2. Manual download: source('scripts/download_landsat_manual.R')\n\n")
      }
    })
  }
}

cat("For detailed status: source('scripts/check_gee_status.R')\n")
cat("For full summary: See PROJECT_READY_SUMMARY.md\n\n")

