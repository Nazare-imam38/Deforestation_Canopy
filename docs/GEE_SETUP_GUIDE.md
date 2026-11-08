# Google Earth Engine Setup Guide

Complete guide for setting up and using Google Earth Engine for Landsat data download.

## Prerequisites

1. **Google Account** - Free Google account required
2. **Python** - rgee requires Python (usually auto-installed)
3. **Internet Connection** - For GEE access

## Quick Start

### Step 1: Setup Google Earth Engine

```r
source("scripts/setup_gee.R")
```

This will:
- Check if GEE is initialized
- Prompt for Google account authentication (first time)
- Set up Python environment if needed
- Test connection
- Prepare study area

### Step 2: Download Landsat Data

```r
source("scripts/download_landsat_gee.R")
```

This will:
- Query Landsat collections
- Filter by date and cloud cover
- Export to Google Drive
- Create download tasks

### Step 3: Download from Google Drive

After GEE tasks complete (check Google Drive):

```r
source("scripts/download_from_drive.R")
```

This downloads files from Google Drive to your local machine.

## Detailed Steps

### Initial Setup (First Time Only)

1. **Run Setup Script:**
   ```r
   source("scripts/setup_gee.R")
   ```

2. **Authentication:**
   - First run will open browser for Google authentication
   - Sign in with your Google account
   - Grant permissions to Google Earth Engine
   - Grant permissions to Google Drive (for file export)

3. **Python Setup (if needed):**
   If you see Python errors, run:
   ```r
   ee_install()
   ```
   This sets up the Python environment automatically.

### Downloading Data

#### Option A: Export to Google Drive (Recommended)

```r
# Setup GEE
source("scripts/setup_gee.R")

# Download data
source("scripts/download_landsat_gee.R")
```

Files will be exported to Google Drive folder `rgee_backup`.

**Advantages:**
- More reliable for large areas
- Can download later
- No timeout issues

#### Option B: Direct Download

Modify the download function to use `via = "local"`:

```r
download_landsat_8_9(
  aoi_ee = aoi_ee,
  start_date = START_DATE,
  end_date = END_DATE,
  via = "local"  # Direct download
)
```

**Advantages:**
- Downloads directly to computer
- No manual step needed

**Disadvantages:**
- Slower for large areas
- May timeout for very large regions

### Checking Task Status

```r
# Check GEE task status
tasks <- ee$batch$Task$list()
print(tasks)

# Check specific task
task <- tasks[[1]]
task$status()
```

### Downloading from Google Drive

1. **Wait for tasks to complete** (check Google Drive or task status)

2. **Download files:**
   ```r
   source("scripts/download_from_drive.R")
   ```

3. **Files will be saved to:** `data/Landsat/`

## Configuration

Edit `R/01_config.R` to customize:

- **Date Range:** `START_DATE` and `END_DATE`
- **Cloud Cover:** `MAX_CLOUD_COVER` (default: 20%)
- **Pixel Size:** `PIXEL_SIZE` (default: 30m)
- **Max Images:** Limit number of images downloaded

## Troubleshooting

### Authentication Issues

**Problem:** Can't authenticate with Google
- **Solution:** Make sure you have internet connection
- Clear browser cache and try again
- Check Google account permissions

### Python Errors

**Problem:** Python not found or errors
- **Solution:** Run `ee_install()` to set up Python
- Or install Python manually from python.org

### No Images Found

**Problem:** GEE returns 0 images
- **Solution:** 
  - Check date range (Landsat 8 starts 2013)
  - Increase cloud cover threshold
  - Verify study area coordinates

### Download Timeout

**Problem:** Direct download times out
- **Solution:** Use `via = "drive"` instead
- Download from Google Drive later

### Task Not Completing

**Problem:** GEE tasks stuck
- **Solution:**
  - Check Google Drive for files
  - Cancel and restart tasks
  - Use smaller date range or area

## Tips

1. **Start Small:** Test with a small area or short date range first
2. **Check Cloud Cover:** Lower cloud cover = fewer images but better quality
3. **Monitor Tasks:** Check Google Drive regularly for completed exports
4. **Batch Downloads:** Download multiple years in separate batches
5. **Storage:** Google Drive has 15GB free; large areas may need more

## File Structure

After download:
```
data/Landsat/
├── Landsat_LC08_044034_20140318.tif
├── Landsat_LC08_044034_20140403.tif
└── ...
```

## Next Steps

Once data is downloaded:

```r
source("scripts/main_workflow.R")
```

This will process your Landsat data and perform deforestation analysis.

## Support

- **GEE Documentation:** https://developers.google.com/earth-engine
- **rgee Documentation:** https://github.com/r-spatial/rgee
- **Project README:** See `README.md` for methodology details

---

**Last Updated:** GEE integration complete
**Status:** Ready for data download

