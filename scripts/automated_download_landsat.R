# ==============================================================================
# AUTOMATED LANDSAT DOWNLOAD - COMPLETE SOLUTION
# ==============================================================================
# Handles USGS login and downloads Landsat data automatically
# Uses direct USGS API to bypass getSpatialData issues
# ==============================================================================

cat("========================================\n")
cat("AUTOMATED LANDSAT DOWNLOAD\n")
cat("Using Direct USGS API\n")
cat("========================================\n\n")

# Load packages
source("R/00_setup_packages.R")
source("R/01_config.R")
source("R/03_load_study_area.R")

# Install required packages
if (!require(httr, quietly = TRUE)) {
  install.packages("httr", dependencies = TRUE)
  library(httr)
}

if (!require(jsonlite, quietly = TRUE)) {
  install.packages("jsonlite", dependencies = TRUE)
  library(jsonlite)
}

# USGS Credentials
usgs_username <- "your_email@example.com"
usgs_password <- "your_password"

cat("STEP 1: USGS API Login\n")
cat("---------------------\n")
cat("Username:", usgs_username, "\n\n")

# USGS EarthExplorer API
api_base <- "https://earthexplorer.usgs.gov/inventory/json/v/1.4.1"
login_url <- paste0(api_base, "/login")

cat("Logging in to USGS EarthExplorer...\n")

# Login request
login_response <- POST(
  url = login_url,
  body = list(
    username = usgs_username,
    password = usgs_password,
    catalogId = "EE"
  ),
  encode = "json",
  timeout(30)
)

# Check login response
if (status_code(login_response) == 200) {
  response_data <- content(login_response, "parsed")
  
  if (!is.null(response_data$data) && 
      response_data$data != "Invalid User Name or Password" &&
      !grepl("invalid|error", tolower(response_data$data), fixed = TRUE)) {
    
    api_key <- response_data$data
    cat("✓ Login successful!\n")
    cat("  API Key obtained\n\n")
    
    # Store globally
    assign("usgs_api_key", api_key, envir = .GlobalEnv)
    
  } else {
    cat("✗ Login failed: Invalid credentials\n")
    cat("  Response:", response_data$data, "\n\n")
    stop("Invalid USGS credentials. Please check username and password.")
  }
} else {
  cat("✗ Login failed, HTTP status:", status_code(login_response), "\n")
  response_text <- content(login_response, "text")
  cat("  Response:", response_text, "\n\n")
  stop("USGS API login failed")
}

# Step 2: Search for Landsat data
cat("STEP 2: Searching for Landsat Data\n")
cat("----------------------------------\n")

# Load study area
aoi <- load_study_area()
bbox <- st_bbox(aoi)

cat("Study Area Coordinates:\n")
cat("  North:", round(bbox[4], 4), "\n")
cat("  South:", round(bbox[2], 4), "\n")
cat("  East:", round(bbox[3], 4), "\n")
cat("  West:", round(bbox[1], 4), "\n")
cat("  Date Range:", START_DATE, "to", END_DATE, "\n")
cat("  Max Cloud Cover:", MAX_CLOUD_COVER, "%\n\n")

# Search for Landsat 8 data
search_url <- paste0(api_base, "/search")

search_params <- list(
  apiKey = usgs_api_key,
  datasetName = "LANDSAT_8_C1",
  spatialFilter = list(
    filterType = "mbr",
    lowerLeft = list(
      longitude = as.numeric(bbox[1]),
      latitude = as.numeric(bbox[2])
    ),
    upperRight = list(
      longitude = as.numeric(bbox[3]),
      latitude = as.numeric(bbox[4])
    )
  ),
  temporalFilter = list(
    startDate = START_DATE,
    endDate = END_DATE
  ),
  maxCloudCover = MAX_CLOUD_COVER,
  maxResults = 50,
  startingNumber = 1
)

cat("Searching USGS catalog...\n")

search_response <- POST(
  url = search_url,
  body = search_params,
  encode = "json",
  timeout(60)
)

if (status_code(search_response) == 200) {
  search_data <- content(search_response, "parsed")
  
  if (!is.null(search_data$data) && 
      !is.null(search_data$data$results) && 
      length(search_data$data$results) > 0) {
    
    records <- search_data$data$results
    cat("✓ Found", length(records), "Landsat 8 scenes\n\n")
    
    # Display found scenes
    cat("Available scenes:\n")
    for (i in 1:min(5, length(records))) {
      scene <- records[[i]]
      cat("  ", i, ":", scene$displayId, 
          "-", scene$acquisitionDate,
          "- Cloud:", scene$cloudCover, "%\n")
    }
    if (length(records) > 5) {
      cat("  ... and", length(records) - 5, "more scenes\n")
    }
    cat("\n")
    
    # Limit to first 3 for initial download
    max_download <- min(3, length(records))
    cat("Downloading first", max_download, "scenes...\n\n")
    records_subset <- records[1:max_download]
    
    # Step 3: Get download options and download
    cat("STEP 3: Downloading Data\n")
    cat("------------------------\n")
    cat("This may take 10-30 minutes depending on file sizes...\n\n")
    
    download_url <- paste0(api_base, "/download")
    downloaded_count <- 0
    
    for (i in 1:length(records_subset)) {
      scene <- records_subset[[i]]
      cat("Processing scene", i, "of", length(records_subset), ":", 
          scene$displayId, "\n")
      
      # Get download options
      options_params <- list(
        apiKey = usgs_api_key,
        datasetName = "LANDSAT_8_C1",
        entityIds = scene$entityId
      )
      
      options_response <- POST(
        url = paste0(api_base, "/downloadOptions"),
        body = options_params,
        encode = "json",
        timeout(30)
      )
      
      if (status_code(options_response) == 200) {
        options_data <- content(options_response, "parsed")
        
        if (!is.null(options_data$data) && length(options_data$data) > 0) {
          # Find Surface Reflectance product
          sr_option <- NULL
          for (opt in options_data$data) {
            if (grepl("Surface Reflectance|SR", opt$productName, ignore.case = TRUE)) {
              sr_option <- opt
              break
            }
          }
          
          # Use first available if SR not found
          if (is.null(sr_option)) {
            sr_option <- options_data$data[[1]]
          }
          
          cat("  Product:", sr_option$productName, "\n")
          
          # Request download
          download_params <- list(
            apiKey = usgs_api_key,
            datasetName = "LANDSAT_8_C1",
            entityIds = scene$entityId,
            products = sr_option$productName
          )
          
          download_request <- POST(
            url = download_url,
            body = download_params,
            encode = "json",
            timeout(30)
          )
          
          if (status_code(download_request) == 200) {
            download_data <- content(download_request, "parsed")
            
            if (!is.null(download_data$data) && length(download_data$data) > 0) {
              download_info <- download_data$data[[1]]
              
              if (!is.null(download_info$url)) {
                cat("  ✓ Download URL obtained\n")
                cat("  URL:", download_info$url, "\n")
                
                # Download the file
                filename <- basename(download_info$url)
                # Remove query parameters from filename
                filename <- gsub("\\?.*", "", filename)
                filepath <- file.path(LANDSAT_DIR, filename)
                
                cat("  Downloading file...\n")
                tryCatch({
                  download.file(
                    download_info$url,
                    filepath,
                    mode = "wb",
                    quiet = FALSE
                  )
                  cat("  ✓ File downloaded:", filename, "\n\n")
                  downloaded_count <- downloaded_count + 1
                }, error = function(e) {
                  cat("  ✗ Download failed:", e$message, "\n")
                  cat("  You may need to download manually from the URL above\n\n")
                })
              } else {
                cat("  ⚠ No download URL provided\n")
                cat("  Download may need to be requested manually\n\n")
              }
            }
          } else {
            cat("  ✗ Download request failed\n\n")
          }
        }
      } else {
        cat("  ✗ Failed to get download options\n\n")
      }
    }
    
    cat("========================================\n")
    cat("DOWNLOAD SUMMARY\n")
    cat("========================================\n\n")
    cat("Downloaded", downloaded_count, "of", length(records_subset), "scenes\n\n")
    
    # Verify downloaded files
    landsat_files <- list.files(LANDSAT_DIR, pattern = "\\.(tif|tar|gz)$", 
                               full.names = TRUE, recursive = TRUE)
    
    if (length(landsat_files) > 0) {
      cat("✓ Found", length(landsat_files), "files in", LANDSAT_DIR, "\n\n")
      
      # Check if files need extraction
      tar_files <- list.files(LANDSAT_DIR, pattern = "\\.tar(\\.gz)?$", 
                             full.names = TRUE, recursive = TRUE)
      if (length(tar_files) > 0) {
        cat("Note: Some files are .tar archives and may need extraction.\n")
        cat("Extract them to get .tif files.\n\n")
      }
      
      cat("Next step: Run analysis\n")
      cat("  source('scripts/run_immediate_workflow.R')\n\n")
    } else {
      cat("⚠ No files found. Downloads may have failed.\n")
      cat("  Check the URLs above and download manually if needed.\n\n")
    }
    
  } else {
    cat("✗ No Landsat scenes found\n")
    cat("  Try adjusting:\n")
    cat("    - Date range\n")
    cat("    - Cloud cover threshold\n")
    cat("    - Study area coordinates\n\n")
  }
} else {
  cat("✗ Search failed, HTTP status:", status_code(search_response), "\n")
  response_text <- content(search_response, "text")
  cat("  Response:", response_text, "\n\n")
}

cat("========================================\n")
cat("PROCESS COMPLETE\n")
cat("========================================\n\n")

