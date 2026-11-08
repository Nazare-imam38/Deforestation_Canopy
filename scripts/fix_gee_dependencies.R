# ==============================================================================
# FIX GEE DEPENDENCIES
# ==============================================================================
# Install missing dependencies for Google Earth Engine
# ==============================================================================

cat("========================================\n")
cat("FIXING GEE DEPENDENCIES\n")
cat("========================================\n\n")

# Step 1: Install geojsonio (R package)
cat("STEP 1: Installing geojsonio package...\n")
cat("--------------------------------------\n")
if (!require(geojsonio, quietly = TRUE)) {
  install.packages("geojsonio", dependencies = TRUE)
  library(geojsonio)
  cat("✓ geojsonio installed\n\n")
} else {
  cat("✓ geojsonio already installed\n\n")
}

# Step 2: Install earthengine-api (Python package)
cat("STEP 2: Installing earthengine-api (Python)...\n")
cat("----------------------------------------------\n")

# Check if rgee is loaded
if (!require(rgee, quietly = TRUE)) {
  install.packages("rgee", dependencies = TRUE)
  library(rgee)
}

# Install Python earthengine-api
cat("Installing earthengine-api (Python package)...\n")
tryCatch({
  # Use reticulate to install Python package
  if (require(reticulate, quietly = TRUE)) {
    cat("Installing earthengine-api via pip...\n")
    py_install("earthengine-api", pip = TRUE)
    cat("✓ earthengine-api installed\n\n")
  } else {
    cat("reticulate not available. Installing...\n")
    install.packages("reticulate", dependencies = TRUE)
    library(reticulate)
    py_install("earthengine-api", pip = TRUE)
    cat("✓ earthengine-api installed\n\n")
  }
}, error = function(e) {
  cat("✗ Automatic installation failed:", e$message, "\n")
  cat("  Please install manually:\n")
  cat("    1. Open Command Prompt\n")
  cat("    2. Run: pip install earthengine-api\n")
  cat("  Or run: source('scripts/install_earthengine_api.R')\n\n")
})

# Step 3: Verify installation
cat("STEP 3: Verifying installation...\n")
cat("--------------------------------\n")

# Check R package
if (require(geojsonio, quietly = TRUE)) {
  cat("✓ geojsonio (R) - OK\n")
} else {
  cat("✗ geojsonio (R) - FAILED\n")
}

# Check Python package
if (require(rgee, quietly = TRUE)) {
  tryCatch({
    ee_check()
    cat("✓ earthengine-api (Python) - OK\n")
    cat("✓ GEE is ready to use!\n\n")
  }, error = function(e) {
    cat("✗ earthengine-api (Python) - NOT FOUND\n")
    cat("  Error:", e$message, "\n")
    cat("  Try running: ee_install()\n\n")
  })
}

cat("========================================\n")
cat("DEPENDENCY FIX COMPLETE\n")
cat("========================================\n\n")

cat("If earthengine-api is still missing, try:\n")
cat("  1. Run: source('scripts/install_earthengine_api.R')\n")
cat("  2. Or manually in Command Prompt: pip install earthengine-api\n")
cat("  3. Then restart R and try again\n\n")

