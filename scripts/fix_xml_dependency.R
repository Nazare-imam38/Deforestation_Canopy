# ==============================================================================
# FIX XML DEPENDENCY FOR TMAP
# ==============================================================================
# Install XML package required by tmap
# ==============================================================================

cat("========================================\n")
cat("FIXING XML DEPENDENCY\n")
cat("========================================\n\n")

# Install XML package
cat("Installing XML package (required by tmap)...\n")
if (!require(XML, quietly = TRUE)) {
  install.packages("XML", dependencies = TRUE)
  library(XML)
  cat("✓ XML installed and loaded\n\n")
} else {
  cat("✓ XML already installed\n\n")
}

# Verify tmap can now load
cat("Testing tmap loading...\n")
if (require(tmap, quietly = TRUE)) {
  cat("✓ tmap can now be loaded!\n\n")
} else {
  cat("✗ tmap still has issues\n")
  cat("  Try: install.packages('tmap', dependencies = TRUE)\n\n")
}

cat("========================================\n")
cat("XML DEPENDENCY FIXED\n")
cat("========================================\n\n")

