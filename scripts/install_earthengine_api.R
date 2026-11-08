# ==============================================================================
# INSTALL EARTHENGINE-API (PYTHON PACKAGE)
# ==============================================================================
# Install the Python earthengine-api package required by rgee
# ==============================================================================

cat("========================================\n")
cat("INSTALLING EARTHENGINE-API (PYTHON)\n")
cat("========================================\n\n")

# Load rgee
if (!require(rgee, quietly = TRUE)) {
  cat("Installing rgee package first...\n")
  install.packages("rgee", dependencies = TRUE)
  library(rgee)
}

# Method 1: Try using reticulate directly
cat("METHOD 1: Installing via reticulate...\n")
cat("--------------------------------------\n")

if (require(reticulate, quietly = TRUE)) {
  tryCatch({
    cat("Installing earthengine-api using pip...\n")
    py_install("earthengine-api", pip = TRUE)
    cat("✓ earthengine-api installed via pip\n\n")
    
    # Verify installation
    cat("Verifying installation...\n")
    py_module_available("ee")
    if (py_module_available("ee")) {
      cat("✓ earthengine-api is available!\n\n")
    } else {
      cat("✗ earthengine-api not found after installation\n\n")
    }
  }, error = function(e) {
    cat("✗ Installation via reticulate failed:", e$message, "\n\n")
    cat("Trying alternative method...\n\n")
  })
} else {
  cat("reticulate not available, trying alternative method...\n\n")
}

# Method 2: Try using system command
cat("METHOD 2: Installing via system pip...\n")
cat("-------------------------------------\n")

# Find Python executable
python_path <- tryCatch({
  py_config()$python
}, error = function(e) {
  NULL
})

if (!is.null(python_path)) {
  cat("Found Python at:", python_path, "\n")
  cat("Installing earthengine-api...\n")
  
  # Try to install using system command
  install_cmd <- paste0('"', python_path, '" -m pip install earthengine-api')
  result <- system(install_cmd, intern = TRUE)
  
  if (length(result) > 0) {
    cat("Installation output:\n")
    cat(paste(result, collapse = "\n"), "\n\n")
  }
} else {
  cat("Python path not found\n\n")
}

# Method 3: Manual instructions
cat("METHOD 3: Manual installation instructions\n")
cat("------------------------------------------\n")
cat("If automatic installation failed, try manually:\n\n")
cat("1. Open Command Prompt or PowerShell\n")
cat("2. Run: pip install earthengine-api\n")
cat("   Or: python -m pip install earthengine-api\n\n")
cat("3. If pip is not found, install Python from python.org\n")
cat("   Make sure to check 'Add Python to PATH' during installation\n\n")

# Final verification
cat("========================================\n")
cat("VERIFICATION\n")
cat("========================================\n\n")

if (require(rgee, quietly = TRUE)) {
  tryCatch({
    # Try to check if ee module is available
    if (require(reticulate, quietly = TRUE)) {
      if (py_module_available("ee")) {
        cat("✓ earthengine-api is installed and available!\n\n")
        cat("You can now run:\n")
        cat("  source('scripts/setup_gee.R')\n\n")
      } else {
        cat("✗ earthengine-api is not available\n")
        cat("  Please install manually using pip\n\n")
      }
    } else {
      cat("reticulate not available for verification\n")
      cat("Try running: source('scripts/setup_gee.R')\n")
      cat("If it fails, install manually: pip install earthengine-api\n\n")
    }
  }, error = function(e) {
    cat("Verification error:", e$message, "\n")
    cat("Try installing manually: pip install earthengine-api\n\n")
  })
}

cat("========================================\n")
cat("INSTALLATION COMPLETE\n")
cat("========================================\n\n")

