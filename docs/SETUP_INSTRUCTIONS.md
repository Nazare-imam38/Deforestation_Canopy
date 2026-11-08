# Setup Instructions

Follow these steps to properly configure and run the Deforestation Detection project.

## Step 1: Configure Study Area

The study area has been configured in `R/01_config.R` with example coordinates:
- **Study Area**: Tropical_Forest_Area
- **Bounding Box**: 102.5°E, 12.0°N to 103.5°E, 13.0°N (Southeast Asia region)

### To Modify Study Area:

**Option A: Use Bounding Box Coordinates**
1. Open `R/01_config.R`
2. Modify the `STUDY_BBOX` line:
   ```r
   STUDY_BBOX <- c(xmin, ymin, xmax, ymax)  # Longitude, Latitude
   ```
3. Examples:
   - Amazon: `c(-60.0, -5.0, -59.0, -4.0)`
   - Central Africa: `c(20.0, 0.0, 21.0, 1.0)`
   - Your coordinates: `c(longitude_min, latitude_min, longitude_max, latitude_max)`

**Option B: Use Shapefile**
1. Place your shapefile in `data/shapefiles/study_area.shp`
2. Set `STUDY_BBOX <- NULL` in `R/01_config.R`
3. The script will automatically load from the shapefile

## Step 2: Install Packages

### In RStudio:

1. Open RStudio
2. Open the project: `Deforestation Project.Rproj`
3. Run the setup script:
   ```r
   source("scripts/run_setup.R")
   ```

Or run manually:
```r
# Install and load packages
source("R/00_setup_packages.R")

# Load configuration
source("R/01_config.R")
```

### What This Does:
- Checks for required R packages
- Installs missing packages automatically
- Loads all necessary libraries
- Loads project configuration

**Expected Output:**
```
Checking and installing required packages...
Loading packages...
✓ All packages loaded successfully!
✓ Configuration loaded successfully!
```

**Note:** Package installation may take 10-30 minutes depending on your internet connection.

## Step 3: Run Main Workflow

### In RStudio:

```r
source("scripts/main_workflow.R")
```

### What This Does:
1. Sets up project environment
2. Loads study area
3. Processes Landsat data (if available)
4. Calculates spectral indices
5. Performs change detection
6. Generates outputs

**Note:** The workflow will skip steps that require data files if they're not present. This is normal for initial setup.

## Troubleshooting

### Package Installation Issues

**Problem:** Packages fail to install
- **Solution:** Install packages manually:
  ```r
  install.packages(c("sf", "terra", "dplyr", "ggplot2", "tmap"))
  ```

**Problem:** rgee package issues
- **Solution:** rgee requires additional setup. See `R/02_initialize_gee.R` for details.

### Study Area Issues

**Problem:** "No study area provided" error
- **Solution:** 
  1. Check `STUDY_BBOX` is set in `R/01_config.R`
  2. Or place shapefile in `data/shapefiles/study_area.shp`

**Problem:** Study area coordinates are wrong
- **Solution:** Verify coordinates are in WGS84 (EPSG:4326) format:
  - Longitude: -180 to 180 (negative = West, positive = East)
  - Latitude: -90 to 90 (negative = South, positive = North)

### Data Issues

**Problem:** "No Landsat files found"
- **Solution:** 
  1. Download Landsat data first (see `R/04_download_landsat.R`)
  2. Or place Landsat .tif files in `data/Landsat/`

**Problem:** Workflow stops at data download
- **Solution:** This is expected if you don't have GEE set up. You can:
  1. Set up Google Earth Engine (see `R/02_initialize_gee.R`)
  2. Or download data manually from USGS EarthExplorer
  3. Place files in `data/Landsat/`

## Quick Test

To verify everything is set up correctly:

```r
# Test configuration
source("R/01_config.R")
cat("Study Area:", STUDY_AREA_NAME, "\n")
cat("Bounding Box:", STUDY_BBOX, "\n")

# Test package loading
source("R/00_setup_packages.R")

# Test study area loading
source("R/03_load_study_area.R")
aoi <- load_study_area()
print(aoi)
```

## Next Steps

After successful setup:
1. Review configuration in `R/01_config.R`
2. Modify study area coordinates if needed
3. Download Landsat data (via GEE or manually)
4. Run complete workflow: `source("scripts/main_workflow.R")`
5. Check outputs in `output/` directory

## Need Help?

- See `README.md` for detailed methodology
- See `PROJECT_STRUCTURE.md` for file descriptions
- Check individual R scripts for function documentation

