# ==============================================================================
# POST-REGISTRATION CHECKLIST
# ==============================================================================
# Run this after your Google Earth Engine project is registered and approved
# ==============================================================================

cat("========================================\n")
cat("POST-REGISTRATION CHECKLIST\n")
cat("========================================\n\n")

cat("This checklist will verify everything is ready after GEE registration.\n\n")

# Step 1: Check GEE status
cat("STEP 1: Checking Google Earth Engine status...\n")
cat("-----------------------------------------------\n")
source("scripts/check_gee_status.R")

# Step 2: Complete setup
cat("\nSTEP 2: Completing GEE setup...\n")
cat("-------------------------------\n")
tryCatch({
  source("scripts/setup_gee.R")
  cat("✓ Setup complete!\n\n")
}, error = function(e) {
  cat("✗ Setup failed:", e$message, "\n")
  cat("  Make sure registration is approved\n\n")
})

# Step 3: Verify study area
cat("\nSTEP 3: Verifying study area...\n")
cat("-------------------------------\n")
source("R/01_config.R")
source("R/03_load_study_area.R")
aoi <- load_study_area()
cat("✓ Study area ready\n")
cat("  Area:", round(as.numeric(st_area(aoi)) / 1e6, 2), "km²\n\n")

# Step 4: Test data download capability
cat("\nSTEP 4: Testing data download capability...\n")
cat("-------------------------------------------\n")
if (exists("aoi_ee")) {
  cat("✓ Study area converted to GEE format\n")
  cat("✓ Ready for data download\n\n")
} else {
  cat("⚠ Study area not in GEE format\n")
  cat("  Run: source('scripts/setup_gee.R')\n\n")
}

# Summary
cat("========================================\n")
cat("CHECKLIST SUMMARY\n")
cat("========================================\n\n")

all_ready <- TRUE
gee_ready <- FALSE

# Check GEE
if (require(rgee, quietly = TRUE)) {
  tryCatch({
    ee_check()
    # Try to actually use GEE
    test <- ee$Image("LANDSAT/LC08/C02/T1_L2/LC08_044034_20140318")
    test_info <- test$getInfo()
    cat("✓ Google Earth Engine: READY\n")
    gee_ready <- TRUE
  }, error = function(e) {
    cat("✗ Google Earth Engine: NOT READY\n")
    if (grepl("not registered|register", e$message, ignore.case = TRUE)) {
      cat("  → Project registration required\n")
      cat("  → Visit: https://earthengine.google.com/\n")
      cat("  → See: GEE_REGISTRATION_GUIDE.md\n")
    } else {
      cat("  Error:", e$message, "\n")
    }
    all_ready <- FALSE
    gee_ready <- FALSE
  })
} else {
  cat("✗ Google Earth Engine: NOT READY\n")
  cat("  → rgee package not loaded\n")
  all_ready <- FALSE
  gee_ready <- FALSE
}

# Check study area
if (exists("aoi")) {
  cat("✓ Study Area: READY\n")
} else {
  cat("✗ Study Area: NOT READY\n")
  all_ready <- FALSE
}

# Check configuration
if (exists("STUDY_BBOX")) {
  cat("✓ Configuration: READY\n")
} else {
  cat("✗ Configuration: NOT READY\n")
  all_ready <- FALSE
}

cat("\n========================================\n")
if (all_ready && gee_ready) {
  cat("✓ ALL SYSTEMS READY!\n")
  cat("========================================\n\n")
  cat("You can now proceed with data download:\n")
  cat("  source('scripts/download_landsat_gee.R')\n\n")
  cat("Next steps:\n")
  cat("  1. Download Landsat data: source('scripts/download_landsat_gee.R')\n")
  cat("  2. Download from Drive: source('scripts/download_from_drive.R')\n")
  cat("  3. Run analysis: source('scripts/main_workflow.R')\n\n")
} else {
  if (!gee_ready) {
    cat("⚠ GOOGLE EARTH ENGINE NOT READY\n")
    cat("========================================\n\n")
    cat("ACTION REQUIRED: Register your Google Earth Engine project\n\n")
    cat("Steps:\n")
    cat("  1. Visit: https://earthengine.google.com/\n")
    cat("  2. Click 'Sign Up' or 'Get Started'\n")
    cat("  3. Choose 'Noncommercial use' (for research)\n")
    cat("  4. Complete registration form\n")
    cat("  5. Wait for approval (24-48 hours)\n")
    cat("  6. Run this checklist again: source('scripts/post_registration_checklist.R')\n\n")
    cat("Your project: ee-imamsyed716\n")
    cat("Direct link: https://console.cloud.google.com/earth-engine/configuration?project=ee-imamsyed716\n\n")
    cat("For detailed instructions, see: GEE_REGISTRATION_GUIDE.md\n\n")
  } else {
    cat("⚠ SOME STEPS NEED ATTENTION\n")
    cat("========================================\n\n")
    cat("Please complete the missing steps above.\n\n")
  }
  
  cat("Once GEE is registered and approved, you can:\n")
  cat("  1. Download Landsat data: source('scripts/download_landsat_gee.R')\n")
  cat("  2. Download from Drive: source('scripts/download_from_drive.R')\n")
  cat("  3. Run analysis: source('scripts/main_workflow.R')\n\n")
}

