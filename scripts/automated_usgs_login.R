# ==============================================================================
# AUTOMATED USGS LOGIN AND DOWNLOAD
# ==============================================================================
# Automated login to USGS EarthExplorer and download Landsat data
# ==============================================================================

cat("========================================\n")
cat("AUTOMATED USGS LOGIN AND DOWNLOAD\n")
cat("========================================\n\n")

# Load packages
source("R/00_setup_packages.R")
source("R/01_config.R")
source("R/03_load_study_area.R")

# Load getSpatialData
if (!require(getSpatialData, quietly = TRUE)) {
  if (!require(devtools, quietly = TRUE)) {
    install.packages("devtools")
    library(devtools)
  }
  cat("Installing getSpatialData...\n")
  devtools::install_github("16EAGLE/getSpatialData", dependencies = TRUE, force = TRUE)
  library(getSpatialData)
}

# USGS Credentials
usgs_username <- "your_email@example.com"
usgs_password <- "your_password"

cat("STEP 1: Attempting USGS Login\n")
cat("-----------------------------\n")
cat("Username:", usgs_username, "\n\n")

# Try different login methods
login_success <- FALSE

# Method 1: Check function signature
cat("Method 1: Standard login...\n")
tryCatch({
  # Try with explicit parameters
  result <- login_USGS(username = usgs_username, password = usgs_password)
  cat("✓ Login successful!\n\n")
  login_success <- TRUE
}, error = function(e) {
  cat("✗ Method 1 failed:", e$message, "\n")
  
  # Method 2: Try positional
  cat("\nMethod 2: Positional parameters...\n")
  tryCatch({
    result <- login_USGS(usgs_username, usgs_password)
    cat("✓ Login successful!\n\n")
    login_success <<- TRUE
  }, error = function(e2) {
    cat("✗ Method 2 failed:", e2$message, "\n")
    
    # Method 3: Check if function needs different approach
    cat("\nMethod 3: Checking function signature...\n")
    tryCatch({
      # Get function arguments
      args <- formals(login_USGS)
      cat("Function parameters:", names(args), "\n")
      
      # Try calling with all possible parameter names
      if ("user" %in% names(args)) {
        result <- login_USGS(user = usgs_username, pass = usgs_password)
      } else if ("usr" %in% names(args)) {
        result <- login_USGS(usr = usgs_username, pwd = usgs_password)
      } else {
        # Try direct call
        result <- do.call(login_USGS, list(usgs_username, usgs_password))
      }
      cat("✓ Login successful!\n\n")
      login_success <<- TRUE
    }, error = function(e3) {
      cat("✗ Method 3 failed:", e3$message, "\n\n")
    })
  })
})

# If all methods fail, try updating package or alternative approach
if (!login_success) {
  cat("========================================\n")
  cat("TROUBLESHOOTING LOGIN ISSUE\n")
  cat("========================================\n\n")
  
  cat("The login function may have API endpoint issues.\n")
  cat("Trying alternative approaches...\n\n")
  
  # Try to update package
  cat("Attempting to update getSpatialData package...\n")
  tryCatch({
    devtools::install_github("16EAGLE/getSpatialData", 
                            dependencies = TRUE, 
                            force = TRUE,
                            ref = "master")
    library(getSpatialData, character.only = TRUE)
    cat("✓ Package updated\n\n")
    
    # Try login again after update
    cat("Retrying login after update...\n")
    tryCatch({
      result <- login_USGS(username = usgs_username, password = usgs_password)
      cat("✓ Login successful after update!\n\n")
      login_success <- TRUE
    }, error = function(e) {
      cat("✗ Still failing:", e$message, "\n\n")
    })
  }, error = function(e) {
    cat("✗ Update failed:", e$message, "\n\n")
  })
}

# If still failing, use direct API approach
if (!login_success) {
  cat("========================================\n")
  cat("USING DIRECT API APPROACH\n")
  cat("========================================\n\n")
  
  cat("Since getSpatialData login is failing, using alternative method...\n\n")
  
  # Try using httr to login directly
  if (require(httr, quietly = TRUE)) {
    cat("Attempting direct API login...\n")
    
    # USGS EarthExplorer API endpoint
    login_url <- "https://earthexplorer.usgs.gov/inventory/json/v/1.4.1/login"
    
    tryCatch({
      # Create login request
      login_response <- POST(
        url = login_url,
        body = list(
          username = usgs_username,
          password = usgs_password,
          catalogId = "EE"
        ),
        encode = "json"
      )
      
      if (status_code(login_response) == 200) {
        response_data <- content(login_response)
        if (!is.null(response_data$data) && response_data$data != "Invalid User Name or Password") {
          cat("✓ Direct API login successful!\n")
          cat("  API Key:", substr(response_data$data, 1, 20), "...\n\n")
          
          # Store API key for use
          assign("usgs_api_key", response_data$data, envir = .GlobalEnv)
          login_success <- TRUE
        } else {
          cat("✗ Invalid credentials\n\n")
        }
      } else {
        cat("✗ API login failed, status:", status_code(login_response), "\n\n")
      }
    }, error = function(e) {
      cat("✗ Direct API login failed:", e$message, "\n\n")
    })
  }
}

# Final check
if (!login_success) {
  cat("========================================\n")
  cat("⚠ AUTOMATED LOGIN NOT WORKING\n")
  cat("========================================\n\n")
  cat("The getSpatialData package appears to have API endpoint issues.\n")
  cat("This is a known issue with the package.\n\n")
  
  cat("RECOMMENDED SOLUTION: Manual Download\n")
  cat("-------------------------------------\n")
  cat("1. Visit: https://earthexplorer.usgs.gov/\n")
  cat("2. Login with:\n")
  cat("   Username: your_email@example.com\n")
  cat("   Password: [your password]\n")
  cat("3. Download Landsat data\n")
  cat("4. Place files in:", LANDSAT_DIR, "\n\n")
  
  cat("Then run: source('scripts/run_immediate_workflow.R')\n\n")
  
  stop("Automated login not available - use manual download")
}

# If login successful, proceed with download
if (login_success) {
  cat("========================================\n")
  cat("STEP 2: SETTING STUDY AREA\n")
  cat("========================================\n\n")
  
  # Load study area
  aoi <- load_study_area()
  bbox <- st_bbox(aoi)
  
  # Convert to proper format
  aoi_sfc <- st_geometry(aoi)
  set_aoi(aoi_sfc)
  cat("✓ Study area set\n")
  cat("  Coordinates:", paste(round(bbox, 4), collapse = ", "), "\n\n")
  
  # Search and download
  cat("========================================\n")
  cat("STEP 3: SEARCHING AND DOWNLOADING\n")
  cat("========================================\n\n")
  
  source("scripts/usgs_login_and_download.R")
}

