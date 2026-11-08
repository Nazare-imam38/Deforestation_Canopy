# ==============================================================================
# LAND COVER CLASSIFICATION
# ==============================================================================
# Random Forest and SVM classification for land cover mapping
# ==============================================================================

source("R/01_config.R")

# Load training data
load_training_data <- function(training_file = TRAINING_DATA_FILE) {
  cat("Loading training data...\n")
  
  if (!file.exists(training_file)) {
    stop("Training data file not found: ", training_file, 
         "\nPlease create training points first.")
  }
  
  training <- read.csv(training_file)
  
  cat("✓ Training data loaded!\n")
  cat("  Samples:", nrow(training), "\n")
  cat("  Classes:", unique(training$class), "\n")
  cat("  Features:", ncol(training) - 1, "\n\n")
  
  return(training)
}

# Extract training data from raster stack
extract_training_from_raster <- function(raster_stack, training_points) {
  cat("Extracting training data from raster...\n")
  
  # Convert training points to SpatVector
  if (inherits(training_points, "sf")) {
    training_vect <- vect(training_points)
  } else if (inherits(training_points, "data.frame")) {
    # Assume columns are x, y, class
    training_vect <- vect(training_points[, c("x", "y")], 
                         crs = crs(raster_stack))
    training_vect$class <- training_points$class
  } else {
    training_vect <- training_points
  }
  
  # Extract values
  extracted <- extract(raster_stack, training_vect)
  extracted$class <- training_vect$class
  
  # Remove NAs
  extracted <- na.omit(extracted)
  
  cat("✓ Training data extracted!\n")
  cat("  Samples:", nrow(extracted), "\n\n")
  
  return(extracted)
}

# Train Random Forest classifier
train_random_forest <- function(training_data, ntree = RF_NTREE, mtry = RF_MTRY) {
  cat("Training Random Forest classifier...\n")
  cat("  Trees:", ntree, "\n")
  
  # Separate features and class
  features <- training_data[, !names(training_data) %in% "class"]
  classes <- as.factor(training_data$class)
  
  # Set mtry if not specified
  if (is.null(mtry)) {
    mtry <- floor(sqrt(ncol(features)))
  }
  cat("  mtry:", mtry, "\n\n")
  
  # Train model
  rf_model <- randomForest(
    x = features,
    y = classes,
    ntree = ntree,
    mtry = mtry,
    importance = TRUE
  )
  
  cat("✓ Random Forest trained!\n")
  cat("  OOB error rate:", round(rf_model$err.rate[nrow(rf_model$err.rate), 1] * 100, 2), "%\n\n")
  
  # Plot variable importance
  importance_file <- file.path(FIGURES_DIR, "rf_variable_importance.png")
  png(importance_file, width = 8, height = 6, units = "in", res = 300)
  varImpPlot(rf_model, main = "Random Forest Variable Importance")
  dev.off()
  cat("  Saved variable importance plot:", importance_file, "\n\n")
  
  return(rf_model)
}

# Train SVM classifier
train_svm <- function(training_data, kernel = "radial") {
  cat("Training SVM classifier...\n")
  cat("  Kernel:", kernel, "\n\n")
  
  # Separate features and class
  features <- training_data[, !names(training_data) %in% "class"]
  classes <- as.factor(training_data$class)
  
  # Train model
  svm_model <- svm(
    x = features,
    y = classes,
    kernel = kernel,
    probability = TRUE
  )
  
  cat("✓ SVM trained!\n\n")
  return(svm_model)
}

# Predict land cover classification
predict_landcover <- function(raster_stack, model, method = "randomForest") {
  cat("Predicting land cover classification...\n")
  cat("  Method:", method, "\n")
  cat("  This may take a while for large areas...\n\n")
  
  # Predict
  if (method == "randomForest") {
    classified <- predict(raster_stack, model, type = "response")
  } else if (method == "svm") {
    classified <- predict(raster_stack, model, type = "response")
  } else {
    stop("Unknown method. Use 'randomForest' or 'svm'")
  }
  
  # Set layer name
  names(classified) <- "LandCover"
  
  cat("✓ Classification complete!\n\n")
  return(classified)
}

# Calculate class statistics
calculate_class_statistics <- function(classified_map, pixel_size = PIXEL_SIZE) {
  cat("Calculating class statistics...\n")
  
  # Calculate pixel area in hectares
  pixel_area_ha <- (pixel_size^2) / 10000
  
  # Get frequency table
  freq_table <- freq(classified_map)
  
  # Calculate areas
  total_pixels <- sum(freq_table$count)
  total_area_ha <- total_pixels * pixel_area_ha
  
  # Create statistics data frame
  stats <- data.frame(
    Class = freq_table$value,
    Pixels = freq_table$count,
    Area_ha = round(freq_table$count * pixel_area_ha, 2),
    Percentage = round((freq_table$count / total_pixels) * 100, 2)
  )
  
  cat("✓ Statistics calculated!\n")
  print(stats)
  cat("\n")
  
  return(stats)
}

# Main classification workflow
classify_landcover <- function(raster_stack, training_data, 
                              method = "randomForest",
                              save_output = TRUE) {
  cat("========================================\n")
  cat("LAND COVER CLASSIFICATION\n")
  cat("========================================\n\n")
  
  # Train model
  if (method == "randomForest") {
    model <- train_random_forest(training_data)
  } else if (method == "svm") {
    model <- train_svm(training_data)
  } else {
    stop("Unknown method. Use 'randomForest' or 'svm'")
  }
  
  # Predict
  classified <- predict_landcover(raster_stack, model, method)
  
  # Calculate statistics
  stats <- calculate_class_statistics(classified)
  
  # Save outputs
  if (save_output) {
    # Save classified map
    writeRaster(classified, OUTPUT_FILES$landcover_map, overwrite = TRUE)
    cat("  Saved classified map:", OUTPUT_FILES$landcover_map, "\n")
    
    # Save statistics
    stats_file <- file.path(STATS_DIR, "landcover_statistics.csv")
    write.csv(stats, stats_file, row.names = FALSE)
    cat("  Saved statistics:", stats_file, "\n\n")
  }
  
  cat("✓ Classification workflow complete!\n\n")
  
  return(list(
    Model = model,
    Classified = classified,
    Statistics = stats
  ))
}

cat("✓ Classification functions loaded!\n\n")

