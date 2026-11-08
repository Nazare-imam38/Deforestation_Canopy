# 🚀 START HERE - Deforestation Detection Project

## Quick Start Guide

Welcome! This is your complete guide to running the deforestation detection project.

---

## 📖 Documentation

All project documentation is in the **`docs/`** folder:

- **`COMPLETE_WORKFLOW_GUIDE.md`** - Step-by-step execution guide (READ THIS FIRST!)
- **`README.md`** - Project overview and methodology
- **`PROJECT_STRUCTURE.md`** - File organization guide
- **`SETUP_INSTRUCTIONS.md`** - Initial setup guide
- **`GEE_SETUP_GUIDE.md`** - Google Earth Engine setup (optional)
- And more...

---

## ⚡ Quick Start (3 Steps)

### Option 1: Run Complete Workflow (Recommended)

Run everything at once:

```r
source("scripts/run_complete_workflow.R")
```

This will:
1. ✅ Process your Landsat data
2. ✅ Calculate spectral indices
3. ✅ Detect deforestation changes
4. ✅ Create visualization maps
5. ✅ Generate HTML report (opens in browser)

**Time:** 15-30 minutes

---

### Option 2: Step-by-Step Execution

If you prefer to run each step individually:

```r
# Step 1: Process Landsat data
source("scripts/process_manual_landsat.R")

# Step 2: Calculate indices
source("scripts/calculate_indices_from_processed.R")

# Step 3: Detect changes
source("scripts/detect_deforestation_changes.R")

# Step 4: Create maps
source("scripts/create_deforestation_maps.R")

# Step 5: Generate report
source("scripts/generate_html_report.R")
```

---

## 📋 Prerequisites

Before running, ensure:

1. ✅ **Landsat data** is in `data/Landsat/` folder
2. ✅ **R and RStudio** are installed
3. ✅ **Project directory** is set correctly

---

## 📁 Project Structure

```
Deforestation Project/
├── data/
│   └── Landsat/          # Place your Landsat .TIF files here
├── output/               # All results go here
│   ├── indices/          # NDVI and NBR maps
│   ├── change_detection/ # Deforestation detection results
│   ├── maps/             # Visualization maps
│   └── report/           # HTML report
├── R/                    # Core R functions
├── scripts/              # Execution scripts
└── docs/                 # All documentation files
```

---

## 🎯 What You'll Get

After running the complete workflow:

1. **Processed Landsat time series** - Ready for analysis
2. **Spectral indices** - NDVI and NBR for all dates
3. **Deforestation maps** - Visual identification of forest loss
4. **Statistics** - Area calculations and percentages
5. **HTML Report** - Comprehensive analysis report (opens automatically)

---

## 📚 Detailed Guides

For complete instructions, see:

- **`docs/COMPLETE_WORKFLOW_GUIDE.md`** - Full step-by-step guide
- **`docs/README.md`** - Project methodology and background

---

## ❓ Need Help?

1. Check `docs/COMPLETE_WORKFLOW_GUIDE.md` for detailed instructions
2. Verify your Landsat data is in the correct location
3. Ensure all packages are installed (run `source("R/00_setup_packages.R")`)

---

## ✅ Ready to Start?

Run this command in RStudio:

```r
source("scripts/run_complete_workflow.R")
```

The HTML report will open automatically when complete!

---

**Last Updated:** 2024
**Project:** Deforestation Detection Using Landsat Time-Series

