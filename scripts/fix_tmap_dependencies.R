# ==============================================================================
# FIX TMAP DEPENDENCIES
# ==============================================================================
# Install all dependencies required by tmap
# ==============================================================================

cat("========================================\n")
cat("FIXING TMAP DEPENDENCIES\n")
cat("========================================\n\n")

# List of tmap dependencies
tmap_deps <- c("XML", "lwgeom", "stars", "geojsonsf")

cat("Installing tmap dependencies...\n")
cat("Required packages:", paste(tmap_deps, collapse = ", "), "\n\n")

installed_count <- 0
for (pkg in tmap_deps) {
  if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
    cat("Installing", pkg, "...\n")
    tryCatch({
      install.packages(pkg, dependencies = TRUE)
      library(pkg, character.only = TRUE)
      cat("✓", pkg, "installed and loaded\n\n")
      installed_count <- installed_count + 1
    }, error = function(e) {
      cat("✗ Failed to install", pkg, ":", e$message, "\n")
      cat("  You may need to install Rtools for some packages\n")
      cat("  See: https://cran.rstudio.com/bin/windows/Rtools/\n\n")
    })
  } else {
    cat("✓", pkg, "already installed\n\n")
    installed_count <- installed_count + 1
  }
}

# Test tmap loading
cat("Testing tmap loading...\n")
if (require(tmap, quietly = TRUE)) {
  cat("✓ tmap loaded successfully!\n\n")
} else {
  cat("✗ tmap still cannot be loaded\n")
  cat("  Missing dependencies may need manual installation\n\n")
}

cat("========================================\n")
if (installed_count == length(tmap_deps) && require(tmap, quietly = TRUE)) {
  cat("✓ ALL TMAP DEPENDENCIES INSTALLED!\n")
  cat("========================================\n\n")
} else {
  cat("⚠ SOME DEPENDENCIES MAY BE MISSING\n")
  cat("========================================\n\n")
  cat("If tmap still doesn't load, try:\n")
  cat("  install.packages('tmap', dependencies = TRUE)\n\n")
}

