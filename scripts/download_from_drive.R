# ==============================================================================
# DOWNLOAD FILES FROM GOOGLE DRIVE TO LOCAL MACHINE
# ==============================================================================
# Downloads Landsat files from Google Drive (rgee_backup folder) to local
# ==============================================================================

cat("========================================\n")
cat("DOWNLOAD FROM GOOGLE DRIVE\n")
cat("========================================\n\n")

# Load configuration
source("R/01_config.R")

# Check if googledrive package is available
if (!require(googledrive, quietly = TRUE)) {
  cat("Installing googledrive package...\n")
  install.packages("googledrive", dependencies = TRUE)
  library(googledrive)
}

# Authenticate with Google Drive
cat("STEP 1: Authenticating with Google Drive...\n")
cat("-------------------------------------------\n")
tryCatch({
  drive_auth()
  cat("✓ Google Drive authenticated\n\n")
}, error = function(e) {
  cat("✗ Authentication failed:", e$message, "\n")
  cat("  Please authenticate manually\n\n")
  stop("Google Drive authentication required")
})

# Find rgee_backup folder
cat("STEP 2: Finding rgee_backup folder...\n")
cat("-------------------------------------\n")
folders <- drive_find(pattern = "rgee_backup", type = "folder")

if (nrow(folders) == 0) {
  cat("✗ rgee_backup folder not found in Google Drive\n")
  cat("  Make sure GEE export tasks have completed\n")
  cat("  Check Google Drive or run GEE download tasks first\n\n")
  stop("rgee_backup folder not found")
}

cat("✓ Found rgee_backup folder\n")
cat("  Folder ID:", folders$id[1], "\n\n")

# List files in the folder
cat("STEP 3: Listing files in rgee_backup...\n")
cat("---------------------------------------\n")
files <- drive_ls(path = as_id(folders$id[1]))

if (nrow(files) == 0) {
  cat("✗ No files found in rgee_backup folder\n")
  cat("  GEE export tasks may still be running\n")
  cat("  Check task status with: ee$batch$Task$list()\n\n")
  stop("No files to download")
}

cat("✓ Found", nrow(files), "files\n")
cat("  Files:\n")
for (i in 1:min(10, nrow(files))) {
  cat("    ", i, ":", files$name[i], "\n")
}
if (nrow(files) > 10) {
  cat("    ... and", nrow(files) - 10, "more files\n")
}
cat("\n")

# Download files
cat("STEP 4: Downloading files...\n")
cat("----------------------------\n")
cat("Destination:", LANDSAT_DIR, "\n")
cat("This may take a while depending on file sizes...\n\n")

# Create output directory if it doesn't exist
dir.create(LANDSAT_DIR, showWarnings = FALSE, recursive = TRUE)

downloaded_count <- 0
for (i in 1:nrow(files)) {
  tryCatch({
    cat("Downloading", i, "of", nrow(files), ":", files$name[i], "\n")
    
    # Download file
    drive_download(
      file = as_id(files$id[i]),
      path = file.path(LANDSAT_DIR, files$name[i]),
      overwrite = TRUE
    )
    
    downloaded_count <- downloaded_count + 1
    cat("  ✓ Downloaded\n")
    
  }, error = function(e) {
    cat("  ✗ Error:", e$message, "\n")
  })
}

cat("\n========================================\n")
cat("DOWNLOAD COMPLETE!\n")
cat("========================================\n\n")
cat("Downloaded", downloaded_count, "of", nrow(files), "files\n")
cat("Files saved to:", LANDSAT_DIR, "\n\n")

# Verify downloaded files
landsat_files <- list.files(LANDSAT_DIR, pattern = "\\.tif$", full.names = TRUE, recursive = TRUE)
cat("Total Landsat files now:", length(landsat_files), "\n\n")

cat("You can now run:\n")
cat("  source('scripts/main_workflow.R')\n\n")

