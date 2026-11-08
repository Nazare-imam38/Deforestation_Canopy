# Complete Deforestation Detection Project Workflow

## 📋 Step-by-Step Execution Guide

This guide provides the complete sequence of commands to run the deforestation detection project from start to finish.

---

## Prerequisites

1. **R and RStudio** installed
2. **Project directory** set up correctly
3. **Landsat data** downloaded and placed in `data/Landsat/`

---

## Step 1: Initial Setup and Package Installation

```r
# Load all required packages
source("R/00_setup_packages.R")
```

**What this does:**
- Installs all required R packages
- Loads spatial, analysis, and visualization libraries
- Sets up the R environment

**Expected output:** "✓ All packages loaded successfully!"

---

## Step 2: Load Configuration

```r
# Load project configuration
source("R/01_config.R")
```

**What this does:**
- Loads study area settings
- Sets date ranges
- Configures output directories

**Expected output:** Configuration details displayed

---

## Step 3: Process Manual Landsat Data

```r
# Process your manually downloaded Landsat files
source("scripts/process_manual_landsat.R")
```

**What this does:**
- Scans `data/Landsat/` directory
- Loads all Landsat scenes
- Aligns scenes to common grid
- Creates time series stack
- Saves processed data

**Expected output:**
- "✓ Successfully loaded X scenes"
- "✓ Time series stack created"
- Processed files saved to `data/Landsat/`

**Time:** 5-15 minutes depending on data size

---

## Step 4: Calculate Spectral Indices

```r
# Calculate NDVI and NBR for all dates
source("scripts/calculate_indices_from_processed.R")
```

**What this does:**
- Calculates NDVI for each date
- Calculates NBR for each date
- Creates time series stacks
- Saves indices to `output/indices/`

**Expected output:**
- "✓ NDVI time series created: X layers"
- "✓ NBR time series created: X layers"
- Individual index maps saved

**Time:** 2-5 minutes

---

## Step 5: Detect Deforestation Changes

```r
# Detect deforestation using change detection
source("scripts/detect_deforestation_changes.R")
```

**What this does:**
- Calculates NDVI change
- Calculates dNBR (deforestation indicator)
- Classifies deforestation severity (6 classes)
- Calculates deforestation area
- Generates statistics

**Expected output:**
- Deforestation statistics
- Classification breakdown
- Files saved to `output/change_detection/`

**Time:** 3-8 minutes

---

## Step 6: Create Visualization Maps

```r
# Generate publication-quality maps
source("scripts/create_deforestation_maps.R")
```

**What this does:**
- Creates dNBR map
- Creates deforestation classification map
- Creates NDVI change map
- Creates time series comparisons
- Generates statistical plots

**Expected output:**
- PNG maps saved to `output/maps/`
- Statistical plots saved to `output/figures/`

**Time:** 2-5 minutes

---

## Step 7: Generate HTML Report

```r
# Generate comprehensive HTML report
source("scripts/generate_html_report.R")
```

**What this does:**
- Creates modern HTML report
- Embeds all maps and statistics
- Includes methodology and findings
- **Automatically opens in browser**

**Expected output:**
- HTML report saved to `output/report/deforestation_report.html`
- Browser opens automatically

**Time:** 1-2 minutes

---

## 🚀 Complete Workflow (Run All at Once)

If you want to run everything in sequence:

```r
# ==============================================================================
# COMPLETE DEFORESTATION DETECTION WORKFLOW
# ==============================================================================
# Run this to execute the entire analysis pipeline
# ==============================================================================

cat("========================================\n")
cat("DEFORESTATION DETECTION - COMPLETE WORKFLOW\n")
cat("========================================\n\n")

# Step 1: Setup
cat("STEP 1: Setting up packages...\n")
source("R/00_setup_packages.R")
source("R/01_config.R")
cat("✓ Setup complete\n\n")

# Step 2: Process data
cat("STEP 2: Processing Landsat data...\n")
source("scripts/process_manual_landsat.R")
cat("✓ Data processing complete\n\n")

# Step 3: Calculate indices
cat("STEP 3: Calculating spectral indices...\n")
source("scripts/calculate_indices_from_processed.R")
cat("✓ Indices calculated\n\n")

# Step 4: Change detection
cat("STEP 4: Detecting deforestation changes...\n")
source("scripts/detect_deforestation_changes.R")
cat("✓ Change detection complete\n\n")

# Step 5: Create maps
cat("STEP 5: Creating visualization maps...\n")
source("scripts/create_deforestation_maps.R")
cat("✓ Maps created\n\n")

# Step 6: Generate report
cat("STEP 6: Generating HTML report...\n")
source("scripts/generate_html_report.R")
cat("✓ Report generated\n\n")

cat("========================================\n")
cat("✓ COMPLETE WORKFLOW FINISHED!\n")
cat("========================================\n\n")
cat("Check the 'output/' directory for all results.\n")
cat("HTML report should be open in your browser.\n\n")
```

---

## 📁 Output Directory Structure

After running all scripts, you'll have:

```
output/
├── indices/
│   ├── ndvi_timeseries.tif
│   ├── nbr_timeseries.tif
│   ├── ndvi_YYYY-MM-DD.tif (individual dates)
│   └── nbr_YYYY-MM-DD.tif (individual dates)
│
├── change_detection/
│   ├── ndvi_change.tif
│   ├── dnbr.tif
│   ├── rdnbr.tif
│   ├── deforestation_classification.tif
│   └── deforestation_statistics.csv
│
├── maps/
│   ├── dnbr_map.png
│   ├── deforestation_classification_map.png
│   ├── ndvi_change_map.png
│   ├── ndvi_timeseries_comparison.png
│   └── nbr_timeseries_comparison.png
│
├── figures/
│   ├── deforestation_statistics.png
│   └── dnbr_histogram.png
│
└── report/
    └── deforestation_report.html
```

---

## ⚠️ Troubleshooting

### If packages fail to install:
```r
source("scripts/fix_packages.R")
```

### If data processing fails:
- Check that Landsat files are in `data/Landsat/`
- Verify files are in correct format (.TIF)
- Ensure files are not corrupted

### If maps are missing:
```r
source("scripts/create_deforestation_maps.R")
```

### If report doesn't open:
- Manually open: `output/report/deforestation_report.html`
- Check browser settings

---

## 📊 Expected Results

After completing all steps, you should have:

1. **Processed Landsat data** - Time series stack ready for analysis
2. **Spectral indices** - NDVI and NBR for all dates
3. **Change detection** - Deforestation areas identified
4. **Statistics** - Area calculations and percentages
5. **Visualization maps** - Publication-quality maps
6. **HTML report** - Comprehensive analysis report

---

## 🎯 Quick Start (Minimum Steps)

If you just want the essentials:

```r
# 1. Process data
source("scripts/process_manual_landsat.R")

# 2. Calculate indices
source("scripts/calculate_indices_from_processed.R")

# 3. Detect changes
source("scripts/detect_deforestation_changes.R")

# 4. Generate report
source("scripts/generate_html_report.R")
```

---

## 📝 Notes

- **Processing time:** Total workflow takes 15-30 minutes depending on data size
- **Disk space:** Ensure sufficient space for output files (several GB)
- **Internet:** Required for Font Awesome icons in HTML report
- **Browser:** HTML report opens automatically in default browser

---

## 🔄 Re-running Analysis

To re-run specific steps:

1. **Only reprocess data:** Run Step 3
2. **Only recalculate indices:** Run Step 4
3. **Only regenerate report:** Run Step 7 (uses existing results)

---

## ✅ Verification Checklist

After running the complete workflow, verify:

- [ ] Processed Landsat stack exists: `data/Landsat/processed_landsat_stack.tif`
- [ ] Indices calculated: `output/indices/ndvi_timeseries.tif`
- [ ] Change detection complete: `output/change_detection/dnbr.tif`
- [ ] Maps created: `output/maps/dnbr_map.png`
- [ ] Report generated: `output/report/deforestation_report.html`
- [ ] Report opened in browser

---

**Last Updated:** 2024
**Project:** Deforestation Detection Using Landsat Time-Series

