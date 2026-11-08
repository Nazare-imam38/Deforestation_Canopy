# ==============================================================================
# USGS LOGIN AND DOWNLOAD - STEP BY STEP
# ==============================================================================
# Complete workflow for USGS login and Landsat download
# ==============================================================================

cat("========================================\n")
cat("USGS LOGIN AND LANDSAT DOWNLOAD\n")
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
  devtools::install_github("16EAGLE/getSpatialData", dependencies = TRUE)
  library(getSpatialData)
}

# Load study area
aoi <- load_study_area()
bbox <- st_bbox(aoi)

cat("========================================\n")
cat("STEP 1: USGS ACCOUNT SETUP\n")
cat("========================================\n\n")
cat("If you don't have a USGS account:\n")
cat("  1. Visit: https://earthexplorer.usgs.gov/\n")
cat("  2. Click 'Register' (top right)\n")
cat("  3. Create free account\n\n")

cat("========================================\n")
cat("STEP 2: AUTOMATED USGS LOGIN\n")
cat("========================================\n\n")

# USGS Credentials
usgs_username <- "your_email@example.com"
usgs_password <- "your_password"

cat("Attempting automated login...\n")
cat("Username:", usgs_username, "\n\n")

# Try multiple login methods
login_success <- FALSE

# Method 1: Try getSpatialData login with credentials
cat("Method 1: getSpatialData login...\n")
tryCatch({
  # Check function signature first
  login_func <- get("login_USGS", envir = as.environment("package:getSpatialData"))
  args <- formals(login_USGS)
  
  # Try with username and password parameters
  if ("username" %in% names(args) && "password" %in% names(args)) {
    result <- login_USGS(username = usgs_username, password = usgs_password)
  } else if (length(args) >= 2) {
    # Positional parameters
    result <- login_USGS(usgs_username, usgs_password)
  } else {
    # Try with user/pass
    result <- login_USGS(user = usgs_username, pass = usgs_password)
  }
  
  cat("✓ Login successful!\n\n")
  login_success <- TRUE
  
}, error = function(e) {
  cat("✗ Method 1 failed:", e$message, "\n")
  
  # Method 2: Try direct API call
  cat("\nMethod 2: Direct USGS API login...\n")
  if (require(httr, quietly = TRUE) && require(jsonlite, quietly = TRUE)) {
    tryCatch({
      login_url <- "https://earthexplorer.usgs.gov/inventory/json/v/1.4.1/login"
      
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
        response_data <- content(login_response, "parsed")
        if (!is.null(response_data$data) && 
            !grepl("invalid|error", tolower(response_data$data))) {
          api_key <- response_data$data
          assign("usgs_api_key", api_key, envir = .GlobalEnv)
          cat("✓ Direct API login successful!\n")
          cat("  Using direct API method for download\n\n")
          login_success <<- TRUE
          
          # Use direct API method
          source("scripts/direct_usgs_api_login.R")
          return()
        }
      }
    }, error = function(e2) {
      cat("✗ Method 2 failed:", e2$message, "\n\n")
    })
  }
})

if (!login_success) {
  cat("========================================\n")
  cat("⚠ AUTOMATED LOGIN FAILED\n")
  cat("========================================\n\n")
  cat("The getSpatialData package has API endpoint issues.\n")
  cat("Using direct API method instead...\n\n")
  
  # Try direct API method
  tryCatch({
    source("scripts/direct_usgs_api_login.R")
  }, error = function(e) {
    cat("Direct API also failed. Using manual download.\n\n")
    cat("Please download manually:\n")
    cat("  1. Visit: https://earthexplorer.usgs.gov/\n")
    cat("  2. Login with:", usgs_username, "\n")
    cat("  3. Download Landsat data\n")
    cat("  4. Place files in:", LANDSAT_DIR, "\n\n")
  })
  return()
}

# Try to check if we can search (this will fail if not logged in)
cat("========================================\n")
cat("STEP 3: SETTING STUDY AREA\n")
cat("========================================\n\n")

# Convert to sfc format (preferred)
aoi_sfc <- st_geometry(aoi)
set_aoi(aoi_sfc)
cat("✓ Study area set\n")
cat("  Coordinates: North", round(bbox[4], 4), ", South", round(bbox[2], 4), 
    ", East", round(bbox[3], 4), ", West", round(bbox[1], 4), "\n\n")

cat("========================================\n")
cat("STEP 4: SEARCHING FOR DATA\n")
cat("========================================\n\n")
cat("Date range:", START_DATE, "to", END_DATE, "\n\n")

tryCatch({
  records <- getLandsat_records(
    time_range = c(START_DATE, END_DATE),
    products = "LANDSAT_8_C1"
  )
  
  if (nrow(records) > 0) {
    cat("✓ Found", nrow(records), "Landsat scenes\n\n")
    
    # Show records
    cat("Available scenes:\n")
    print(records[, c("entityId", "acquisitionDate", "cloudCover")])
    cat("\n")
    
    # Limit to first 3 for initial download
    max_download <- min(3, nrow(records))
    cat("Downloading first", max_download, "scenes...\n\n")
    records_subset <- records[1:max_download, ]
    
    cat("========================================\n")
    cat("STEP 5: DOWNLOADING DATA\n")
    cat("========================================\n\n")
    cat("This may take 10-30 minutes...\n\n")
    
    files <- getLandsat_data(
      records_subset,
      dir_out = LANDSAT_DIR,
      force = FALSE
    )
    
    cat("\n✓ Download complete!\n\n")
    
    # Verify
    landsat_files <- list.files(LANDSAT_DIR, pattern = "\\.tif$", 
                               full.names = TRUE, recursive = TRUE)
    cat("Downloaded", length(landsat_files), "files\n")
    cat("Location:", LANDSAT_DIR, "\n\n")
    
    cat("========================================\n")
    cat("SUCCESS! DATA READY FOR PROCESSING\n")
    cat("========================================\n\n")
    cat("Next step: Run analysis\n")
    cat("  source('scripts/run_immediate_workflow.R')\n\n")
    
  } else {
    cat("✗ No scenes found\n")
    cat("  Try different date range\n\n")
  }
  
}, error = function(e) {
  cat("✗ Error:", e$message, "\n\n")
  
  if (grepl("login|authentication|credentials|401|403", e$message, ignore.case = TRUE)) {
    cat("========================================\n")
    cat("⚠ USGS LOGIN REQUIRED\n")
    cat("========================================\n\n")
    cat("You need to login first. Run these commands:\n\n")
    cat("  library(getSpatialData)\n")
    cat("  login_USGS('your_username')\n")
    cat("  # Enter password when prompted\n\n")
    cat("Then run this script again:\n")
    cat("  source('scripts/usgs_login_and_download.R')\n\n")
  } else {
    cat("For manual download instructions, run:\n")
    cat("  source('scripts/download_landsat_manual.R')\n\n")
  }
})

