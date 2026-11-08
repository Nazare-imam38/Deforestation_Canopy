# Quick Reference - Command Cheat Sheet

## 🚀 One-Command Execution

Run the complete workflow:
```r
source("scripts/run_complete_workflow.R")
```

---

## 📝 Step-by-Step Commands

### 1. Setup
```r
source("R/00_setup_packages.R")
source("R/01_config.R")
```

### 2. Process Data
```r
source("scripts/process_manual_landsat.R")
```

### 3. Calculate Indices
```r
source("scripts/calculate_indices_from_processed.R")
```

### 4. Detect Changes
```r
source("scripts/detect_deforestation_changes.R")
```

### 5. Create Maps
```r
source("scripts/create_deforestation_maps.R")
```

### 6. Generate Report
```r
source("scripts/generate_html_report.R")
```

---

## 🔧 Troubleshooting Commands

### Fix Package Issues
```r
source("scripts/fix_packages.R")
```

### Verify Setup
```r
source("scripts/verify_setup.R")
```

### Check Data
```r
source("scripts/verify_manual_landsat.R")
```

---

## 📂 Output Locations

- **Indices:** `output/indices/`
- **Change Detection:** `output/change_detection/`
- **Maps:** `output/maps/`
- **Report:** `output/report/deforestation_report.html`

---

## ⏱️ Expected Times

- Setup: 2-5 minutes
- Data Processing: 5-15 minutes
- Indices: 2-5 minutes
- Change Detection: 3-8 minutes
- Maps: 2-5 minutes
- Report: 1-2 minutes

**Total:** 15-30 minutes

---

For detailed instructions, see: `docs/COMPLETE_WORKFLOW_GUIDE.md`

