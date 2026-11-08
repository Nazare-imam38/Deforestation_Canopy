# ==============================================================================
# INSTALL MISSING PACKAGES
# ==============================================================================
# Install any remaining missing packages
# ==============================================================================

cat("========================================\n")
cat("INSTALLING MISSING PACKAGES\n")
cat("========================================\n\n")

# Missing packages
missing <- c("viridis", "gridExtra")

cat("Installing missing packages:", paste(missing, collapse = ", "), "\n\n")

for (pkg in missing) {
  if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
    cat("Installing", pkg, "...\n")
    tryCatch({
      install.packages(pkg, dependencies = TRUE)
      library(pkg, character.only = TRUE)
      cat("✓", pkg, "installed and loaded\n\n")
    }, error = function(e) {
      cat("✗ Failed to install", pkg, ":", e$message, "\n\n")
    })
  } else {
    cat("✓", pkg, "already installed\n\n")
  }
}

# Verify installation
cat("Verifying installation...\n")
all_ok <- TRUE
for (pkg in missing) {
  if (require(pkg, character.only = TRUE, quietly = TRUE)) {
    cat("  ✓", pkg, "\n")
  } else {
    cat("  ✗", pkg, "still missing\n")
    all_ok <- FALSE
  }
}

cat("\n========================================\n")
if (all_ok) {
  cat("✓ ALL PACKAGES INSTALLED!\n")
  cat("========================================\n\n")
  cat("You can now run:\n")
  cat("  source('R/00_setup_packages.R')\n")
  cat("  source('R/01_config.R')\n")
  cat("  source('scripts/main_workflow.R')\n\n")
} else {
  cat("✗ SOME PACKAGES STILL MISSING\n")
  cat("========================================\n\n")
  cat("Try installing manually:\n")
  cat("  install.packages(c('viridis', 'gridExtra'))\n\n")
}

