# 02. RESEARCH EVIDENCE TABLE

This table provides a line-item verification of every major scientific, methodological, and computational claim across the project.

| Scientific / Technical Claim | Actual Empirical Evidence | Project Relative Path | Function / Cell / Code Section | Evidence Status | Limitations & Context |
|:---|:---|:---|:---|:---|:---|
| **Multi-Sensor Landsat 8/9 Level-2 Ingestion** | GeoTIFF bands for 3 scenes loaded, stacked, and verified | `data/Landsat/imag*`, `scripts/process_manual_landsat.R` | Lines 25–106: `load_landsat_scene` | **VERIFIED** | Scenes acquired on 2024-12-09 (L9), 2024-12-17 (L8), 2024-12-25 (L9). |
| **Grid Harmonization & Resampling** | Extent union computed; resampled to 30m grid via bilinear method | `scripts/process_manual_landsat.R` | Lines 127–152: `resample(..., method = "bilinear")` | **VERIFIED** | Bilinear interpolation slightly smooths sharp edge contrasts. |
| **Spectral Index Derivation (NDVI & NBR)** | Raster arithmetic executed across Red, NIR, and SWIR-2 bands | `scripts/calculate_indices_from_processed.R` | Lines 58–66 (NDVI), Lines 111–125 (NBR) | **VERIFIED** | Successfully written to `output/indices/`. |
| **Bi-temporal Disturbance Differencing (dNBR, RdNBR, ΔNDVI)** | Bi-temporal subtraction executed: $dNBR = NBR_{t1} - NBR_{t2}$ | `scripts/detect_deforestation_changes.R` | Lines 53–76: `ndvi_change`, `dNBR`, `rdNBR` | **VERIFIED** | Positive dNBR indicates canopy loss / moisture drop. |
| **Threshold-Based Disturbance Severity Mapping** | Pixel classification based on USGS / Key & Benson thresholds | `scripts/detect_deforestation_changes.R` | Lines 105–111: `deforestation_vals` | **VERIFIED** | Static thresholds; not calibrated to local ecotype. |
| **Surface Disturbance Quantification (ha / km²)** | Exact tabular area calculations based on 30m pixel size ($0.09\text{ ha/pixel}$) | `output/change_detection/deforestation_statistics.csv` | Lines 1–10; and `scripts/detect_deforestation_changes.R` L125–136 | **VERIFIED** | Yielded 29,698.11 ha (0.82% of area) disturbance. |
| **Automated HTML Synthesis** | Single standalone HTML report with embedded inline base64 graphics | `output/report/deforestation_report.html`, `scripts/generate_html_report.R` | Lines 1–450: `generate_html_report.R` | **VERIFIED** | File size 2.16 MB containing complete analysis report. |
| **Next.js Real-Time Decision-Support Dashboard** | React dashboard with analytics, interactive routing, styled CSS | `dashboard/app/page.js`, `dashboard/package.json` | Full Next.js project structure; screenshots in `OUTPUT Sc/` | **VERIFIED** | Built with Next.js 15.0.3, Geist fonts, and CSS modules. |
| **BFAST Structural Break Analysis** | R script defining time-series decomposition algorithms | `R/08_bfast_analysis.R` | Lines 45–70: `run_bfast` | **PARTIALLY SUPPORTED / PROPOSED** | Code is complete and syntactically valid, but was not executed on real data due to temporal sample size ($n=3$). |
| **Supervised Machine Learning (Random Forest & SVM)** | Training functions and variable importance scripts | `R/09_classification.R` | Lines 58–92 (`train_random_forest`), Lines 95–130 (`train_svm`) | **PARTIALLY SUPPORTED / PROPOSED** | Code is functional, but `data/training/` contains only a 5-row toy template; no model weights exist. |
| **Quantitative Accuracy Assessment (Confusion Matrix / Kappa)** | Error matrix calculation functions scripted in R | `R/10_accuracy_assessment.R` | Lines 10–70: `calculate_confusion_matrix` | **PROPOSED** | Scripted but never executed; no reference validation sample collected. |
| **Long-Term Decadal Analysis (1984–2024)** | Proposed in `docs/README.md` and configuration | `docs/README.md`, `R/01_config.R` | Lines 56–63 | **PROPOSED / NOT VERIFIED** | Only 3 scenes from December 2024 were analyzed. |
| **Google Earth Engine Automated Downloader** | Scripts developed for GEE authentication and ingestion | `R/02_initialize_gee.R`, `scripts/authenticate_gee.R` | GEE OAuth & reticulate integration | **PARTIALLY SUPPORTED** | Blocked during authentication/project configuration (`ee-imamsyed716`), triggering manual workflow fallback. |

---

## EVIDENCE STATUS DEFINITIONS
- **VERIFIED:** Directly supported by executable code, verified inputs, and generated physical outputs (GeoTIFF, CSV, HTML, UI).
- **PARTIALLY SUPPORTED:** Complete, functional scripts exist in the codebase, but were bypassed during actual execution due to external constraints (e.g., API limits, data length).
- **PROPOSED:** Documented as an intended capability in guides and documentation, but unexecuted or lacking input data.
- **NOT VERIFIED:** Mentioned in project text, but without supporting data or code execution records.

