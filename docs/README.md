# Deforestation Detection Using Landsat Time-Series in R

A comprehensive R project for detecting, mapping, and quantifying deforestation using multi-temporal Landsat imagery (Landsat 5, 7, 8, 9).

## 📋 Table of Contents

- [Project Overview](#project-overview)
- [Methodology](#methodology)
- [Installation](#installation)
- [Project Structure](#project-structure)
- [Usage](#usage)
- [Workflow Steps](#workflow-steps)
- [Outputs](#outputs)
- [References](#references)

## 🎯 Project Overview

### Objective

Detect, map, and quantify deforestation using multi-temporal Landsat imagery using R language.

### Techniques Used

- **Time-series analysis** - BFAST (Breaks For Additive Seasonal & Trend)
- **Spectral index extraction** - NDVI, NBR
- **Change detection** - NBR differencing, thresholding
- **Land cover classification** - Random Forest, SVM
- **Accuracy assessment** - Confusion matrix, Kappa coefficient

### Applications

- Forest policy and management
- Environmental monitoring
- REDD+ (Reducing Emissions from Deforestation and Forest Degradation)
- Carbon loss estimation
- Conservation planning

## 📚 Methodology

### 1. Study Area Identification

Define your study area using:
- Shapefile (`.shp`) in `data/shapefiles/`
- Bounding box coordinates (modify in `R/01_config.R`)

### 2. Data Acquisition

Download Landsat imagery from:
- **Google Earth Engine** (recommended) - via `rgee` package
- **USGS EarthExplorer** - via `getSpatialData` package

Supported sensors:
- Landsat 5 TM (1984–2012)
- Landsat 7 ETM+ (1999–present)
- Landsat 8 OLI (2013–present)
- Landsat 9 (2021–present)

### 3. Pre-processing

- Cloud masking (QA bands)
- Atmospheric correction (Surface Reflectance)
- Mosaicking (if multiple scenes)
- Clipping to study area
- Resampling and alignment

### 4. Spectral Indices

**NDVI (Normalized Difference Vegetation Index)**
```
NDVI = (NIR - Red) / (NIR + Red)
```

**NBR (Normalized Burn Ratio)**
```
NBR = (NIR - SWIR2) / (NIR + SWIR2)
```

**dNBR (Differenced NBR)**
```
dNBR = NBR_t1 - NBR_t2
```
Negative values indicate forest loss.

### 5. Change Detection

**Approach A: NBR Differencing**
- Compute NBR for two time periods
- Calculate difference (dNBR)
- Apply threshold to classify deforestation

**Approach B: BFAST Time-Series Analysis**
- Use 20–30 years of NDVI data
- Detect structural breaks in vegetation
- Identify sudden drops (deforestation events)

### 6. Land Cover Classification

- **Random Forest** - Ensemble learning
- **SVM** - Support Vector Machine
- Classes: Forest, Agriculture, Built-up, Water, Barren

### 7. Accuracy Assessment

- Confusion matrix
- Overall accuracy
- Kappa coefficient
- Producer's accuracy
- User's accuracy

## 🚀 Installation

### Prerequisites

- R (version 4.0 or higher)
- RStudio (recommended)

### Step 1: Install R Packages

Run the setup script to install all required packages:

```r
source("R/00_setup_packages.R")
```

### Step 2: Configure Project

Edit `R/01_config.R` to set:
- Study area coordinates or shapefile path
- Time period for analysis
- Output directories
- Analysis parameters

### Step 3: Initialize Google Earth Engine (Optional)

If using Google Earth Engine for data download:

```r
source("R/02_initialize_gee.R")
initialize_gee()
```

This requires Google account authentication (first time only).

## 📁 Project Structure

```
Deforestation Project/
├── data/
│   ├── Landsat/          # Landsat imagery files
│   ├── shapefiles/       # Study area shapefiles
│   └── training/         # Training/validation data
├── R/                    # R script modules
│   ├── 00_setup_packages.R
│   ├── 01_config.R
│   ├── 02_initialize_gee.R
│   ├── 03_load_study_area.R
│   ├── 04_download_landsat.R
│   ├── 05_preprocessing.R
│   ├── 06_spectral_indices.R
│   ├── 07_change_detection.R
│   ├── 08_bfast_analysis.R
│   ├── 09_classification.R
│   ├── 10_accuracy_assessment.R
│   └── 11_visualization.R
├── scripts/
│   └── main_workflow.R   # Main workflow script
├── output/
│   ├── maps/             # Output maps (GeoTIFF)
│   ├── statistics/       # Statistics (CSV, TXT)
│   └── figures/          # Plots and visualizations (PNG)
└── README.md
```

## 💻 Usage

### Quick Start

1. **Setup**: Run package installation and configuration
   ```r
   source("R/00_setup_packages.R")
   source("R/01_config.R")
   ```

2. **Load Study Area**: Define your study area
   ```r
   source("R/03_load_study_area.R")
   aoi <- load_study_area()
   ```

3. **Run Main Workflow**: Execute complete analysis
   ```r
   source("scripts/main_workflow.R")
   ```

### Step-by-Step Execution

For more control, run individual modules:

```r
# 1. Preprocessing
source("R/05_preprocessing.R")
landsat <- preprocess_landsat(data_dir = "data/Landsat/", aoi = aoi)

# 2. Calculate indices
source("R/06_spectral_indices.R")
indices <- calculate_spectral_indices(landsat, indices = c("NDVI", "NBR"))

# 3. Change detection
source("R/07_change_detection.R")
results <- detect_deforestation(nbr_2015, nbr_2024)

# 4. Visualization
source("R/11_visualization.R")
create_all_visualizations(results)
```

## 📊 Workflow Steps

### Complete Workflow

1. **Setup and Configuration** - Install packages, load configuration
2. **Initialize GEE** - Connect to Google Earth Engine (optional)
3. **Load Study Area** - Define analysis area
4. **Download Landsat Data** - Acquire satellite imagery
5. **Preprocessing** - Cloud masking, mosaicking, clipping
6. **Calculate Spectral Indices** - NDVI, NBR computation
7. **Change Detection** - Identify deforestation using dNBR
8. **BFAST Analysis** - Time-series break detection (optional)
9. **Land Cover Classification** - Map land cover types (optional)
10. **Accuracy Assessment** - Validate results (optional)
11. **Visualization** - Create maps and plots

## 📈 Outputs

### Maps

- `deforestation_map.tif` - Binary deforestation map
- `dnbr_forest_loss.tif` - dNBR difference map
- `deforestation_severity.tif` - Severity classification
- `landcover_classification.tif` - Land cover map
- `bfast_breakpoints.tif` - BFAST breakpoint locations

### Statistics

- `deforestation_statistics.csv` - Area and percentage statistics
- `landcover_statistics.csv` - Class area statistics
- `accuracy_assessment.txt` - Accuracy metrics report

### Figures

- `deforestation_map.png` - Deforestation visualization
- `ndvi_timeseries.png` - NDVI trend over time
- `nbr_timeseries.png` - NBR trend over time
- `confusion_matrix.png` - Classification accuracy
- `bfast_analysis.png` - BFAST results plot

## 🔧 Configuration

Edit `R/01_config.R` to customize:

- **Study Area**: Coordinates or shapefile path
- **Time Period**: Start and end dates
- **Thresholds**: dNBR threshold for deforestation
- **Resolution**: Pixel size (default: 30m)
- **Cloud Cover**: Maximum cloud cover percentage
- **Output Paths**: Directory locations

## 📝 Notes

### Data Requirements

- Landsat Surface Reflectance data (recommended)
- Cloud-free or cloud-masked imagery
- Minimum 2 time periods for change detection
- 20+ years of data for BFAST analysis

### Performance Tips

- Use smaller study areas for faster processing
- Sample pixels for pixel-wise BFAST (time-consuming)
- Use Google Drive export for large GEE downloads
- Process time series in batches

### Troubleshooting

**GEE Authentication Issues**
- Run `ee_Initialize()` manually
- Check Google account permissions
- Clear GEE cache if needed

**Memory Issues**
- Process smaller areas
- Use `terra` package (more memory efficient)
- Increase R memory limit

**Missing Data**
- Check cloud cover thresholds
- Verify date ranges
- Ensure study area is within Landsat coverage

## 📚 References

### Key Packages

- `rgee` - Google Earth Engine integration
- `terra` - Modern raster processing
- `sf` - Spatial data handling
- `bfast` - Time-series break detection
- `randomForest` - Machine learning classification
- `tmap` - Thematic mapping

### Methodology References

- Verbesselt, J., et al. (2010). Detecting trend and seasonal changes in satellite image time series. *Remote Sensing of Environment*, 114(1), 106-115.
- Key, C. H., & Benson, N. C. (2006). Landscape assessment: Remote sensing of severity, the Normalized Burn Ratio. *FIREMON: Fire Effects Monitoring and Inventory System*.
- Hansen, M. C., et al. (2013). High-resolution global maps of 21st-century forest cover change. *Science*, 342(6160), 850-853.

## 📄 License

This project is provided for research and educational purposes.

## 👤 Author

Created for Master's research in deforestation detection and monitoring.

## 🤝 Contributing

This is a research project. For questions or improvements, please refer to the methodology documentation.

---

**Last Updated**: 2024

**Version**: 1.0

