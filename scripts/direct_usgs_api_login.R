# ==============================================================================
# DIRECT USGS API LOGIN AND DOWNLOAD
# ==============================================================================
# Bypasses getSpatialData login issues by using USGS API directly
# ==============================================================================

cat("========================================\n")
cat("DIRECT USGS API LOGIN AND DOWNLOAD\n")
cat("========================================\n\n")

# Load packages
source("R/00_setup_packages.R")
source("R/01_config.R")
source("R/03_load_study_area.R")

# Install httr if needed
if (!require(httr, quietly = TRUE)) {
  install.packages("httr", dependencies = TRUE)
  library(httr)
}

if (!require(jsonlite, quietly = TRUE)) {
  install.packages("jsonlite", dependencies = TRUE)
  library(jsonlite)
}

# USGS Credentials (embedded in script for automation)
usgs_username <- "your_email@example.com"
usgs_password <- "your_password"

cat("STEP 1: Direct USGS API Login\n")
cat("----------------------------\n")
cat("Username:", usgs_username, "\n\n")

# USGS EarthExplorer API endpoints
api_base <- "https://earthexplorer.usgs.gov/inventory/json/v/1.4.1"
login_url <- paste0(api_base, "/login")

cat("Logging in via USGS API...\n")

# Login request
login_response <- tryCatch({
  POST(
    url = login_url,
    body = list(
      username = usgs_username,
      password = usgs_password,
      catalogId = "EE"
    ),
    encode = "json"
  )
}, error = function(e) {
  cat("✗ Connection error:", e$message, "\n")
  return(NULL)
})

if (is.null(login_response)) {
  stop("Failed to connect to USGS API")
}

# Check response
if (status_code(login_response) == 200) {
  response_data <- content(login_response, "parsed")
  
  if (!is.null(response_data$data) && 
      response_data$data != "Invalid User Name or Password" &&
      !grepl("error|invalid", tolower(response_data$data))) {
    
    api_key <- response_data$data
    cat("✓ Login successful!\n")
    cat("  API Key obtained\n\n")
    
    # Store API key globally
    assign("usgs_api_key", api_key, envir = .GlobalEnv)
    assign("usgs_username", usgs_username, envir = .GlobalEnv)
    
  } else {
    cat("✗ Login failed: Invalid credentials\n")
    cat("  Response:", response_data$data, "\n\n")
    stop("Invalid USGS credentials")
  }
} else {
  cat("✗ Login failed, HTTP status:", status_code(login_response), "\n")
  cat("  Response:", content(login_response, "text"), "\n\n")
  stop("USGS API login failed")
}

# Step 2: Search for Landsat data
cat("========================================\n")
cat("STEP 2: SEARCHING FOR LANDSAT DATA\n")
cat("========================================\n\n")

# Load study area
aoi <- load_study_area()
bbox <- st_bbox(aoi)

cat("Study Area:\n")
cat("  North:", round(bbox[4], 4), "\n")
cat("  South:", round(bbox[2], 4), "\n")
cat("  East:", round(bbox[3], 4), "\n")
cat("  West:", round(bbox[1], 4), "\n")
cat("  Date Range:", START_DATE, "to", END_DATE, "\n\n")

# Search API endpoint
search_url <- paste0(api_base, "/search")

# Prepare search parameters
search_params <- list(
  apiKey = usgs_api_key,
  datasetName = "LANDSAT_8_C1",
  spatialFilter = list(
    filterType = "mbr",
    lowerLeft = list(
      longitude = bbox[1],
      latitude = bbox[2]
    ),
    upperRight = list(
      longitude = bbox[3],
      latitude = bbox[4]
    )
  ),
  temporalFilter = list(
    startDate = START_DATE,
    endDate = END_DATE
  ),
  maxCloudCover = MAX_CLOUD_COVER,
  maxResults = 100,
  startingNumber = 1
)

cat("Searching for Landsat 8 scenes...\n")

search_response <- POST(
  url = search_url,
  body = search_params,
  encode = "json"
)

if (status_code(search_response) == 200) {
  search_data <- content(search_response, "parsed")
  
  if (!is.null(search_data$data) && length(search_data$data$results) > 0) {
    records <- search_data$data$results
    cat("✓ Found", length(records), "Landsat scenes\n\n")
    
    # Show sample records
    cat("Sample scenes:\n")
    for (i in 1:min(3, length(records))) {
      cat("  ", i, ":", records[[i]]$displayId, 
          "- Date:", records[[i]]$acquisitionDate,
          "- Cloud:", records[[i]]$cloudCover, "%\n")
    }
    cat("\n")
    
    # Limit to first 3 for download
    max_download <- min(3, length(records))
    records_subset <- records[1:max_download]
    
    cat("========================================\n")
    cat("STEP 3: DOWNLOADING DATA\n")
    cat("========================================\n\n")
    cat("Downloading", max_download, "scenes...\n")
    cat("This may take 10-30 minutes...\n\n")
    
    # Download each scene
    download_url <- paste0(api_base, "/download")
    downloaded_files <- c()
    
    for (i in 1:length(records_subset)) {
      scene <- records_subset[[i]]
      cat("Downloading scene", i, "of", length(records_subset), ":", 
          scene$displayId, "\n")
      
      # Get download options
      download_options_params <- list(
        apiKey = usgs_api_key,
        datasetName = "LANDSAT_8_C1",
        entityIds = scene$entityId
      )
      
      options_response <- POST(
        url = paste0(api_base, "/downloadOptions"),
        body = download_options_params,
        encode = "json"
      )
      
      if (status_code(options_response) == 200) {
        options_data <- content(options_response, "parsed")
        
        # Find Surface Reflectance download option
        if (!is.null(options_data$data) && length(options_data$data) > 0) {
          # Get the first available download option
          download_option <- options_data$data[[1]]
          
          # Request download
          download_request_params <- list(
            apiKey = usgs_api_key,
            datasetName = "LANDSAT_8_C1",
            entityIds = scene$entityId,
            products = download_option$productName
          )
          
          download_request <- POST(
            url = download_url,
            body = download_request_params,
            encode = "json"
          )
          
          if (status_code(download_request) == 200) {
            download_data <- content(download_request, "parsed")
            cat("  ✓ Download requested\n")
            cat("  URL:", download_data$data[[1]]$url, "\n\n")
            
            # Note: USGS provides download URLs, actual download happens via browser
            # or we can use download.file() for direct download
            downloaded_files <- c(downloaded_files, download_data$data[[1]]$url)
          }
        }
      }
    }
    
    cat("========================================\n")
    cat("DOWNLOAD REQUESTS COMPLETE\n")
    cat("========================================\n\n")
    cat("Note: USGS provides download URLs.\n")
    cat("For automated download, we'll use download.file()\n\n")
    
    # Download files
    if (length(downloaded_files) > 0) {
      cat("Downloading files...\n")
      for (i in 1:length(downloaded_files)) {
        url <- downloaded_files[i]
        filename <- basename(url)
        filepath <- file.path(LANDSAT_DIR, filename)
        
        cat("  Downloading", i, "of", length(downloaded_files), ":", filename, "\n")
        tryCatch({
          download.file(url, filepath, mode = "wb", quiet = FALSE)
          cat("    ✓ Downloaded\n")
        }, error = function(e) {
          cat("    ✗ Failed:", e$message, "\n")
        })
      }
    }
    
  } else {
    cat("✗ No scenes found\n")
    cat("  Try adjusting date range or search criteria\n\n")
  }
} else {
  cat("✗ Search failed, HTTP status:", status_code(search_response), "\n")
  cat("  Response:", content(search_response, "text"), "\n\n")
}

# Verify downloaded files
cat("\n========================================\n")
cat("VERIFICATION\n")
cat("========================================\n\n")

landsat_files <- list.files(LANDSAT_DIR, pattern = "\\.(tif|tar|gz)$", 
                           full.names = TRUE, recursive = TRUE)

if (length(landsat_files) > 0) {
  cat("✓ Found", length(landsat_files), "downloaded files\n")
  cat("  Location:", LANDSAT_DIR, "\n\n")
  
  cat("Next step: Run analysis\n")
  cat("  source('scripts/run_immediate_workflow.R')\n\n")
} else {
  cat("⚠ No files downloaded yet\n")
  cat("  Files may need to be extracted from .tar.gz archives\n")
  cat("  Or download URLs need to be accessed manually\n\n")
}

cat("========================================\n")
cat("PROCESS COMPLETE\n")
cat("========================================\n\n")

