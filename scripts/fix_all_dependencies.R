# ==============================================================================
# FIX ALL MISSING DEPENDENCIES
# ==============================================================================
# Install all missing dependencies for the project
# ==============================================================================

cat("========================================\n")
cat("FIXING ALL MISSING DEPENDENCIES\n")
cat("========================================\n\n")

# All critical dependencies
all_deps <- list(
  tmap = c("XML", "lwgeom", "stars", "geojsonsf"),
  caret = c("lava", "doBy", "RcppEigen", "styler"),
  general = c("viridis", "gridExtra")
)

cat("Installing all missing dependencies...\n\n")

installed_all <- TRUE

# Install tmap dependencies
cat("TMAP dependencies:\n")
for (pkg in all_deps$tmap) {
  if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
    cat("  Installing", pkg, "...\n")
    tryCatch({
      install.packages(pkg, dependencies = TRUE)
      library(pkg, character.only = TRUE)
      cat("    ✓", pkg, "installed\n")
    }, error = function(e) {
      cat("    ✗ Failed:", pkg, "\n")
      installed_all <- FALSE
    })
  } else {
    cat("  ✓", pkg, "already installed\n")
  }
}

# Install caret dependencies
cat("\nCARET dependencies:\n")
for (pkg in all_deps$caret) {
  if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
    cat("  Installing", pkg, "...\n")
    tryCatch({
      install.packages(pkg, dependencies = TRUE)
      library(pkg, character.only = TRUE)
      cat("    ✓", pkg, "installed\n")
    }, error = function(e) {
      cat("    ✗ Failed:", pkg, "\n")
      installed_all <- FALSE
    })
  } else {
    cat("  ✓", pkg, "already installed\n")
  }
}

# Install general dependencies
cat("\nGeneral dependencies:\n")
for (pkg in all_deps$general) {
  if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
    cat("  Installing", pkg, "...\n")
    tryCatch({
      install.packages(pkg, dependencies = TRUE)
      library(pkg, character.only = TRUE)
      cat("    ✓", pkg, "installed\n")
    }, error = function(e) {
      cat("    ✗ Failed:", pkg, "\n")
      installed_all <- FALSE
    })
  } else {
    cat("  ✓", pkg, "already installed\n")
  }
}

# Test critical packages
cat("\nTesting critical packages...\n")
test_packages <- c("tmap", "caret", "bfast", "randomForest")
all_loaded <- TRUE

for (pkg in test_packages) {
  if (require(pkg, character.only = TRUE, quietly = TRUE)) {
    cat("  ✓", pkg, "loaded successfully\n")
  } else {
    cat("  ✗", pkg, "failed to load\n")
    all_loaded <- FALSE
  }
}

cat("\n========================================\n")
if (all_loaded) {
  cat("✓ ALL DEPENDENCIES INSTALLED!\n")
  cat("========================================\n\n")
  cat("You can now run:\n")
  cat("  source('R/00_setup_packages.R')\n")
  cat("  source('R/01_config.R')\n\n")
} else {
  cat("⚠ SOME DEPENDENCIES MAY BE MISSING\n")
  cat("========================================\n\n")
  cat("If packages still don't load, you may need Rtools:\n")
  cat("  https://cran.rstudio.com/bin/windows/Rtools/\n\n")
}

