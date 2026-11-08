# ==============================================================================
# AUTHENTICATE GOOGLE EARTH ENGINE
# ==============================================================================
# Simple script to authenticate with Google Earth Engine
# ==============================================================================

cat("========================================\n")
cat("GOOGLE EARTH ENGINE AUTHENTICATION\n")
cat("========================================\n\n")

# Load required packages
if (!require(rgee, quietly = TRUE)) {
  install.packages("rgee", dependencies = TRUE)
  library(rgee)
}

if (!require(reticulate, quietly = TRUE)) {
  install.packages("reticulate", dependencies = TRUE)
  library(reticulate)
}

# Check if earthengine-api is installed
cat("Checking Python earthengine-api...\n")
tryCatch({
  ee_check()
  cat("✓ earthengine-api is installed\n\n")
}, error = function(e) {
  if (grepl("earthengine-api", e$message, ignore.case = TRUE)) {
    cat("✗ earthengine-api not found\n")
    cat("Installing earthengine-api...\n")
    py_install("earthengine-api", pip = TRUE)
    cat("✓ earthengine-api installed\n\n")
  }
})

# Initialize GEE
cat("Initializing Google Earth Engine...\n")
cat("A browser window will open for authentication.\n")
cat("Please sign in with your Google account and grant permissions.\n\n")

tryCatch({
  ee_Initialize(drive = TRUE)
  cat("✓ Authentication successful!\n\n")
  
  # Test connection
  cat("Testing connection...\n")
  test_image <- ee$Image("LANDSAT/LC08/C02/T1_L2/LC08_044034_20140318")
  test_info <- test_image$getInfo()
  cat("✓ Connection test successful!\n")
  cat("  Test image:", test_info$id, "\n\n")
  
  cat("========================================\n")
  cat("GEE AUTHENTICATION COMPLETE!\n")
  cat("========================================\n\n")
  cat("You can now use Google Earth Engine.\n")
  cat("Run: source('scripts/setup_gee.R')\n\n")
  
}, error = function(e) {
  cat("✗ Authentication failed:", e$message, "\n\n")
  
  # Check if it's a project registration issue
  if (grepl("not registered|register", e$message, ignore.case = TRUE)) {
    cat("========================================\n")
    cat("PROJECT REGISTRATION REQUIRED\n")
    cat("========================================\n\n")
    cat("Your Google account is authenticated, but your project needs to be\n")
    cat("registered for Earth Engine access.\n\n")
    cat("SOLUTION:\n")
    cat("1. Visit: https://earthengine.google.com/\n")
    cat("2. Click 'Sign Up' or 'Get Started'\n")
    cat("3. Register for Earth Engine (choose Noncommercial or Commercial)\n")
    cat("4. Wait for approval (usually 24-48 hours for noncommercial)\n")
    cat("5. Then run this script again\n\n")
    cat("For detailed instructions, see: GEE_REGISTRATION_GUIDE.md\n\n")
    
    # Try to extract project name from error
    project_match <- regmatches(e$message, regexpr("ee-[a-zA-Z0-9]+", e$message))
    if (length(project_match) > 0) {
      cat("Your project:", project_match[1], "\n")
      cat("Direct link: https://console.cloud.google.com/earth-engine/configuration?project=", 
          project_match[1], "\n\n", sep = "")
    }
  } else {
    cat("Troubleshooting:\n")
    cat("  1. Make sure you have a Google account\n")
    cat("  2. Check your internet connection\n")
    cat("  3. If browser doesn't open, check:\n")
    cat("     - Firewall settings\n")
    cat("     - Browser default settings\n")
    cat("  4. Try manually: ee_Initialize(drive = TRUE)\n\n")
  }
  
  # Show detailed error
  if (require(reticulate, quietly = TRUE)) {
    cat("Python error details:\n")
    tryCatch({
      py_last_error()
    }, error = function(e2) {
      cat("  (No additional error details)\n")
    })
  }
})

