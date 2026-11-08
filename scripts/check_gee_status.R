# ==============================================================================
# CHECK GOOGLE EARTH ENGINE STATUS
# ==============================================================================
# Check if GEE is properly set up and registered
# ==============================================================================

cat("========================================\n")
cat("GOOGLE EARTH ENGINE STATUS CHECK\n")
cat("========================================\n\n")

# Load packages
if (!require(rgee, quietly = TRUE)) {
  cat("✗ rgee package not installed\n")
  cat("  Run: install.packages('rgee')\n\n")
  stop("rgee not available")
}

# Check Python earthengine-api
cat("1. Checking Python earthengine-api...\n")
tryCatch({
  ee_check()
  cat("   ✓ earthengine-api is installed\n\n")
}, error = function(e) {
  cat("   ✗ earthengine-api issue:", e$message, "\n\n")
})

# Check authentication
cat("2. Checking authentication...\n")
tryCatch({
  # Try to initialize
  ee_Initialize(drive = TRUE, quiet = TRUE)
  cat("   ✓ Authentication successful\n\n")
}, error = function(e) {
  if (grepl("not registered|register", e$message, ignore.case = TRUE)) {
    cat("   ✗ Project not registered for Earth Engine\n")
    cat("   → See GEE_REGISTRATION_GUIDE.md for instructions\n\n")
  } else {
    cat("   ✗ Authentication failed:", e$message, "\n\n")
  }
})

# Test connection
cat("3. Testing Earth Engine connection...\n")
tryCatch({
  test_image <- ee$Image("LANDSAT/LC08/C02/T1_L2/LC08_044034_20140318")
  test_info <- test_image$getInfo()
  cat("   ✓ Connection successful!\n")
  cat("   ✓ Test image loaded:", test_info$id, "\n\n")
}, error = function(e) {
  cat("   ✗ Connection failed:", e$message, "\n\n")
  
  if (grepl("not registered|register", e$message, ignore.case = TRUE)) {
    cat("   ACTION REQUIRED: Register your project\n")
    cat("   Visit: https://earthengine.google.com/\n\n")
  }
})

cat("========================================\n")
cat("STATUS CHECK COMPLETE\n")
cat("========================================\n\n")

cat("If you see registration errors:\n")
cat("  1. Read: GEE_REGISTRATION_GUIDE.md\n")
cat("  2. Register at: https://earthengine.google.com/\n")
cat("  3. Wait for approval (24-48 hours)\n")
cat("  4. Run this script again\n\n")

