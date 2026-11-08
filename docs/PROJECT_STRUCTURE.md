# Project Structure Overview

This document provides a quick reference to all files and directories in the Deforestation Detection project.

## Directory Structure

```
Deforestation Project/
│
├── data/                          # Data storage
│   ├── Landsat/                   # Landsat imagery files (.tif)
│   ├── shapefiles/                # Study area shapefiles (.shp)
│   └── training/                  # Training and validation data
│       └── training_data_template.csv
│
├── R/                             # R script modules (numbered by execution order)
│   ├── 00_setup_packages.R        # Package installation and loading
│   ├── 01_config.R                # Project configuration
│   ├── 02_initialize_gee.R        # Google Earth Engine setup
│   ├── 03_load_study_area.R      # Study area loading
│   ├── 04_download_landsat.R     # Landsat data download
│   ├── 05_preprocessing.R        # Image preprocessing
│   ├── 06_spectral_indices.R     # NDVI, NBR calculation
│   ├── 07_change_detection.R     # Deforestation detection
│   ├── 08_bfast_analysis.R        # Time-series break detection
│   ├── 09_classification.R       # Land cover classification
│   ├── 10_accuracy_assessment.R  # Accuracy metrics
│   └── 11_visualization.R        # Maps and plots
│
├── scripts/                       # Main workflow scripts
│   ├── main_workflow.R            # Complete workflow (run this)
│   └── example_usage.R            # Quick start examples
│
├── output/                        # Analysis outputs
│   ├── maps/                      # GeoTIFF maps
│   ├── statistics/                # CSV and TXT statistics
│   └── figures/                   # PNG plots and visualizations
│
├── README.md                      # Main documentation
├── PROJECT_STRUCTURE.md           # This file
├── .gitignore                     # Git ignore rules
└── Deforestation Project.Rproj    # RStudio project file
```

## File Descriptions

### Configuration Files

- **R/01_config.R**: All project settings (study area, dates, thresholds, paths)
- **.gitignore**: Files to exclude from version control

### Setup Scripts

- **R/00_setup_packages.R**: Installs and loads all required R packages
- **R/02_initialize_gee.R**: Sets up Google Earth Engine connection

### Data Handling

- **R/03_load_study_area.R**: Loads study area from shapefile or coordinates
- **R/04_download_landsat.R**: Downloads Landsat data from GEE or USGS
- **R/05_preprocessing.R**: Cloud masking, mosaicking, clipping, alignment

### Analysis Scripts

- **R/06_spectral_indices.R**: Calculates NDVI, NBR, EVI, SAVI
- **R/07_change_detection.R**: Detects deforestation using dNBR
- **R/08_bfast_analysis.R**: Time-series break detection (BFAST)
- **R/09_classification.R**: Random Forest/SVM land cover classification
- **R/10_accuracy_assessment.R**: Confusion matrix, Kappa, accuracy metrics

### Visualization

- **R/11_visualization.R**: Creates maps and plots using tmap and ggplot2

### Workflow Scripts

- **scripts/main_workflow.R**: Complete end-to-end workflow
- **scripts/example_usage.R**: Quick examples for individual functions

## Execution Order

1. **Setup**: `00_setup_packages.R` → `01_config.R`
2. **Data Acquisition**: `02_initialize_gee.R` → `03_load_study_area.R` → `04_download_landsat.R`
3. **Processing**: `05_preprocessing.R` → `06_spectral_indices.R`
4. **Analysis**: `07_change_detection.R` → `08_bfast_analysis.R` (optional)
5. **Classification**: `09_classification.R` → `10_accuracy_assessment.R` (optional)
6. **Output**: `11_visualization.R`

Or simply run: **scripts/main_workflow.R**

## Output Files

### Maps (GeoTIFF)
- `deforestation_map.tif` - Binary deforestation map
- `dnbr_forest_loss.tif` - dNBR difference map
- `deforestation_severity.tif` - Severity classes
- `landcover_classification.tif` - Land cover map
- `bfast_breakpoints.tif` - BFAST breakpoint locations

### Statistics (CSV/TXT)
- `deforestation_statistics.csv` - Area statistics
- `landcover_statistics.csv` - Class statistics
- `accuracy_assessment.txt` - Accuracy report
- `study_area_info.txt` - Study area details

### Figures (PNG)
- `deforestation_map.png` - Deforestation visualization
- `ndvi_timeseries.png` - NDVI trend
- `nbr_timeseries.png` - NBR trend
- `confusion_matrix.png` - Classification accuracy
- `bfast_analysis.png` - BFAST results

## Data Requirements

### Input Data
- Landsat Surface Reflectance imagery (`.tif` files)
- Study area shapefile (`.shp`) or coordinates
- Training data (`.csv`) for classification (optional)

### Output Data
All outputs are saved in `output/` subdirectories:
- Maps → `output/maps/`
- Statistics → `output/statistics/`
- Figures → `output/figures/`

## Quick Reference

**First time setup:**
```r
source("R/00_setup_packages.R")
source("R/01_config.R")
```

**Run complete workflow:**
```r
source("scripts/main_workflow.R")
```

**Run individual steps:**
```r
source("R/03_load_study_area.R")
aoi <- load_study_area()
```

For detailed usage, see **README.md**.

