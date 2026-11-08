# ==============================================================================
# ACCURACY ASSESSMENT
# ==============================================================================
# Confusion matrix, Kappa coefficient, and accuracy metrics
# ==============================================================================

source("R/01_config.R")

# Create confusion matrix
create_confusion_matrix <- function(predicted, actual) {
  cat("Creating confusion matrix...\n")
  
  # Ensure both are factors with same levels
  all_levels <- unique(c(levels(factor(predicted)), levels(factor(actual))))
  predicted <- factor(predicted, levels = all_levels)
  actual <- factor(actual, levels = all_levels)
  
  # Create confusion matrix
  cm <- table(Predicted = predicted, Actual = actual)
  
  cat("✓ Confusion matrix created!\n\n")
  return(cm)
}

# Calculate accuracy metrics
calculate_accuracy_metrics <- function(predicted, actual) {
  cat("Calculating accuracy metrics...\n")
  
  # Create confusion matrix using caret
  cm <- confusionMatrix(data = factor(predicted), reference = factor(actual))
  
  # Extract metrics
  overall_accuracy <- cm$overall["Accuracy"]
  kappa <- cm$overall["Kappa"]
  
  # Class-wise metrics
  producer_accuracy <- cm$byClass[, "Sensitivity"]  # Producer's accuracy
  user_accuracy <- cm$byClass[, "Pos Pred Value"]    # User's accuracy
  
  # Create summary
  metrics <- list(
    OverallAccuracy = as.numeric(overall_accuracy),
    Kappa = as.numeric(kappa),
    ConfusionMatrix = cm$table,
    ProducerAccuracy = producer_accuracy,
    UserAccuracy = user_accuracy,
    FullReport = cm
  )
  
  cat("✓ Accuracy metrics calculated!\n")
  cat("  Overall Accuracy:", round(as.numeric(overall_accuracy) * 100, 2), "%\n")
  cat("  Kappa Coefficient:", round(as.numeric(kappa), 3), "\n\n")
  
  return(metrics)
}

# Generate accuracy report
generate_accuracy_report <- function(accuracy_metrics, output_file = NULL) {
  if (is.null(output_file)) {
    output_file <- OUTPUT_FILES$accuracy_report
  }
  
  cat("Generating accuracy report...\n")
  
  # Create report text
  report <- paste0(
    "ACCURACY ASSESSMENT REPORT\n",
    "==========================\n\n",
    "Overall Accuracy: ", round(accuracy_metrics$OverallAccuracy * 100, 2), "%\n",
    "Kappa Coefficient: ", round(accuracy_metrics$Kappa, 3), "\n\n",
    "PRODUCER'S ACCURACY (Sensitivity)\n",
    "---------------------------------\n"
  )
  
  # Add class-wise producer accuracy
  for (i in seq_along(accuracy_metrics$ProducerAccuracy)) {
    class_name <- names(accuracy_metrics$ProducerAccuracy)[i]
    pa <- accuracy_metrics$ProducerAccuracy[i]
    report <- paste0(report, class_name, ": ", round(pa * 100, 2), "%\n")
  }
  
  report <- paste0(report, "\nUSER'S ACCURACY (Positive Predictive Value)\n")
  report <- paste0(report, "--------------------------------------------\n")
  
  # Add class-wise user accuracy
  for (i in seq_along(accuracy_metrics$UserAccuracy)) {
    class_name <- names(accuracy_metrics$UserAccuracy)[i]
    ua <- accuracy_metrics$UserAccuracy[i]
    report <- paste0(report, class_name, ": ", round(ua * 100, 2), "%\n")
  }
  
  report <- paste0(report, "\nCONFUSION MATRIX\n")
  report <- paste0(report, "----------------\n")
  report <- paste0(report, capture.output(print(accuracy_metrics$ConfusionMatrix)), collapse = "\n")
  
  # Write to file
  writeLines(report, output_file)
  
  cat("✓ Accuracy report saved:", output_file, "\n\n")
  
  return(report)
}

# Plot confusion matrix
plot_confusion_matrix <- function(confusion_matrix, output_file = NULL) {
  if (is.null(output_file)) {
    output_file <- file.path(FIGURES_DIR, "confusion_matrix.png")
  }
  
  cat("Plotting confusion matrix...\n")
  
  # Convert to data frame for ggplot
  cm_df <- as.data.frame(confusion_matrix)
  names(cm_df) <- c("Predicted", "Actual", "Frequency")
  
  # Calculate percentages
  cm_df$Percentage <- (cm_df$Frequency / sum(cm_df$Frequency)) * 100
  
  # Create plot
  p <- ggplot(cm_df, aes(x = Actual, y = Predicted, fill = Frequency)) +
    geom_tile(color = "white") +
    geom_text(aes(label = paste0(Frequency, "\n(", round(Percentage, 1), "%)")), 
              color = "black", size = 3) +
    scale_fill_gradient(low = "white", high = "steelblue") +
    labs(title = "Confusion Matrix",
         x = "Actual Class",
         y = "Predicted Class",
         fill = "Frequency") +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))
  
  ggsave(output_file, p, width = MAP_WIDTH, height = MAP_HEIGHT, dpi = MAP_DPI)
  
  cat("  Saved plot:", output_file, "\n\n")
}

# Cross-validation for model assessment
cross_validate_model <- function(training_data, method = "randomForest", 
                                 k = 5, ntree = RF_NTREE) {
  cat("Performing", k, "-fold cross-validation...\n")
  
  # Create folds
  folds <- createFolds(training_data$class, k = k, list = TRUE, returnTrain = FALSE)
  
  accuracies <- numeric(k)
  
  for (i in 1:k) {
    cat("  Fold", i, "of", k, "\n")
    
    # Split data
    test_indices <- folds[[i]]
    train_data <- training_data[-test_indices, ]
    test_data <- training_data[test_indices, ]
    
    # Train model
    features_train <- train_data[, !names(train_data) %in% "class"]
    classes_train <- as.factor(train_data$class)
    
    if (method == "randomForest") {
      model <- randomForest(x = features_train, y = classes_train, ntree = ntree)
    } else if (method == "svm") {
      model <- svm(x = features_train, y = classes_train)
    }
    
    # Predict
    features_test <- test_data[, !names(test_data) %in% "class"]
    predicted <- predict(model, features_test)
    
    # Calculate accuracy
    actual <- test_data$class
    accuracies[i] <- sum(predicted == actual) / length(actual)
  }
  
  mean_accuracy <- mean(accuracies)
  sd_accuracy <- sd(accuracies)
  
  cat("\n✓ Cross-validation complete!\n")
  cat("  Mean Accuracy:", round(mean_accuracy * 100, 2), "%\n")
  cat("  SD Accuracy:", round(sd_accuracy * 100, 2), "%\n")
  cat("  Accuracy range:", round(range(accuracies) * 100, 2), "%\n\n")
  
  return(list(
    Accuracies = accuracies,
    MeanAccuracy = mean_accuracy,
    SDAccuracy = sd_accuracy
  ))
}

# Main accuracy assessment workflow
assess_accuracy <- function(predicted, actual, output_dir = OUTPUT_DIR) {
  cat("========================================\n")
  cat("ACCURACY ASSESSMENT\n")
  cat("========================================\n\n")
  
  # Calculate metrics
  metrics <- calculate_accuracy_metrics(predicted, actual)
  
  # Generate report
  report <- generate_accuracy_report(metrics)
  
  # Plot confusion matrix
  plot_confusion_matrix(metrics$ConfusionMatrix)
  
  cat("✓ Accuracy assessment complete!\n\n")
  
  return(metrics)
}

cat("✓ Accuracy assessment functions loaded!\n\n")

