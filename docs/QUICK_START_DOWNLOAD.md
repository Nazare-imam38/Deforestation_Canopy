# Quick Start: Download Landsat Data Now

## Current Status
- ✅ `getSpatialData` package installed
- ⚠️ Need USGS login
- ⚠️ AOI format fixed

## Quick Steps

### Step 1: Login to USGS

Open R console and run:

```r
library(getSpatialData)
login_USGS('your_username')
# Enter your password when prompted
```

**If you don't have a USGS account:**
1. Visit: https://earthexplorer.usgs.gov/
2. Click "Register" (top right)
3. Create free account
4. Then login in R

### Step 2: Download Data

After logging in, run:

```r
source("scripts/usgs_login_and_download.R")
```

This will:
- Set your study area (already configured)
- Search for Landsat 8 data
- Download first 3 scenes
- Save to `data/Landsat/`

### Step 3: Run Analysis

Once data is downloaded:

```r
source("scripts/run_immediate_workflow.R")
```

## Alternative: Manual Download

If automated download doesn't work:

```r
source("scripts/download_landsat_manual.R")
```

Follow the instructions to download from USGS EarthExplorer website.

## Your Coordinates

For manual download:
- **North:** 13.0
- **South:** 12.0  
- **East:** 103.5
- **West:** 102.5
- **Date:** 2013-01-01 to 2024-12-31
- **Dataset:** Landsat Collection 2 Level-2
- **Product:** Surface Reflectance

## After Download

Place `.tif` files in:
```
D:/RStudio/Deforestation Project/data/Landsat/
```

Then verify:
```r
source("scripts/verify_downloaded_data.R")
```

Then run analysis:
```r
source("scripts/run_immediate_workflow.R")
```

---

**Quick Command Sequence:**
1. `library(getSpatialData)`
2. `login_USGS('your_username')`
3. `source("scripts/usgs_login_and_download.R")`
4. `source("scripts/run_immediate_workflow.R")`

