# 06. PROJECT FILE MANIFEST

This manifest catalogs the critical source code files, documentation, execution scripts, datasets, and output artifacts in the workspace.

---

## 1. RESEARCH PIPELINE SCRIPTS (`scripts/`)

| File Name | Size (Bytes) | Role & Scientific Significance |
|:---|:---|:---|
| [`run_complete_workflow.R`](file:///d:/RStudio/Deforestation%20Project/scripts/run_complete_workflow.R) | 3,411 | Master orchestrator script; executes data processing, index calculation, change detection, cartography, and report generation sequentially with timing and error handling. |
| [`process_manual_landsat.R`](file:///d:/RStudio/Deforestation%20Project/scripts/process_manual_landsat.R) | 9,835 | Core preprocessing engine; scans directory for Level-2 bands, parses scene IDs, aligns rasters to a unified 30m grid via bilinear resampling, handles AOI fallback, and writes `processed_landsat_stack.tif`. |
| [`calculate_indices_from_processed.R`](file:///d:/RStudio/Deforestation%20Project/scripts/calculate_indices_from_processed.R) | 7,076 | Spectral feature extractor; computes NDVI and NBR layers across multi-temporal rasters and exports stacked GeoTIFFs to `output/indices/`. |
| [`detect_deforestation_changes.R`](file:///d:/RStudio/Deforestation%20Project/scripts/detect_deforestation_changes.R) | 9,142 | Disturbance analysis module; computes $\Delta\text{NDVI}$, $\text{dNBR}$, and $\text{RdNBR}$, applies USGS severity thresholds, calculates pixel areas in hectares, and writes summary statistics CSV. |
| [`create_deforestation_maps.R`](file:///d:/RStudio/Deforestation%20Project/scripts/create_deforestation_maps.R) | 10,000 | Spatial cartography script; generates multi-panel PNG maps, legends, histograms, and time-series comparisons in `output/maps/` and `output/figures/`. |
| [`generate_html_report.R`](file:///d:/RStudio/Deforestation%20Project/scripts/generate_html_report.R) | 25,373 | Scientific reporting engine; generates a single self-contained HTML document with inline base64 graphics, statistics tables, and technical methodology descriptions. |
| [`setup_gee.R`](file:///d:/RStudio/Deforestation%20Project/scripts/setup_gee.R) | 5,317 | Google Earth Engine Python API setup and reticulate configuration script. |
| [`authenticate_gee.R`](file:///d:/RStudio/Deforestation%20Project/scripts/authenticate_gee.R) | 3,878 | GEE credential authentication script for `ee-imamsyed716`. |

---

## 2. MODULAR FUNCTION LIBRARIES (`R/`)

| File Name | Size (Bytes) | Role & Scientific Significance |
|:---|:---|:---|
| [`00_setup_packages.R`](file:///d:/RStudio/Deforestation%20Project/R/00_setup_packages.R) | 6,408 | Package manager; verifies and installs required geospatial packages (`terra`, `sf`, `raster`, `randomForest`, `e1071`, `bfast`, `tmap`). |
| [`01_config.R`](file:///d:/RStudio/Deforestation%20Project/R/01_config.R) | 6,857 | Central project configuration file defining directory constants, CRS options, threshold parameters, and band mapping dictionaries. |
| [`02_initialize_gee.R`](file:///d:/RStudio/Deforestation%20Project/R/02_initialize_gee.R) | 1,993 | Wrapper functions for GEE connection checking. |
| [`03_load_study_area.R`](file:///d:/RStudio/Deforestation%20Project/R/03_load_study_area.R) | 3,779 | SpatVector loader for polygon shapefiles or bounding boxes. |
| [`05_preprocessing.R`](file:///d:/RStudio/Deforestation%20Project/R/05_preprocessing.R) | 5,320 | Modular preprocessing functions including cloud masking routines via `QA_PIXEL`. |
| [`06_spectral_indices.R`](file:///d:/RStudio/Deforestation%20Project/R/06_spectral_indices.R) | 7,695 | Function library for mathematical index formulation. |
| [`07_change_detection.R`](file:///d:/RStudio/Deforestation%20Project/R/07_change_detection.R) | 6,746 | Modular library for differencing and threshold categorization. |
| [`08_bfast_analysis.R`](file:///d:/RStudio/Deforestation%20Project/R/08_bfast_analysis.R) | 6,220 | Implementation of Breaks For Additive Seasonal and Trend analysis for multi-year NDVI stacks. |
| [`09_classification.R`](file:///d:/RStudio/Deforestation%20Project/R/09_classification.R) | 6,323 | Supervised machine-learning training routines for Random Forest and SVM. |
| [`10_accuracy_assessment.R`](file:///d:/RStudio/Deforestation%20Project/R/10_accuracy_assessment.R) | 7,066 | Confusion matrix, Overall Accuracy, and Cohen's Kappa assessment functions. |
| [`11_visualization.R`](file:///d:/RStudio/Deforestation%20Project/R/11_visualization.R) | 8,240 | Cartographic plotting functions for multi-band rasters and index layers. |

---

## 3. RESEARCH DATASETS & METADATA (`data/`)

| File / Folder Name | Approximate Size | Role & Scientific Significance |
|:---|:---|:---|
| `data/Landsat/imag1/` | ~936 MB | Complete Level-2 bundle for `LC09_L2SP_150037_20241225_20241226_02_T1` (Landsat 9, Dec 25, 2024). Includes bands 1–7, thermal B10, QA bands, and metadata JSON/XML/TXT. |
| `data/Landsat/imag2/` | ~940 MB | Complete Level-2 bundle for `LC08_L2SP_150037_20241217_20241227_02_T1` (Landsat 8, Dec 17, 2024). |
| `data/Landsat/imag3/` | ~944 MB | Complete Level-2 bundle for `LC09_L2SP_150037_20241209_20241210_02_T1` (Landsat 9, Dec 09, 2024). |
| `data/Landsat/processed_landsat_stack.tif` | 2.33 GB | Multi-temporal 21-layer raster stack representing 7 bands across 3 aligned timestamps. |
| `data/training/training_data_template.csv` | 271 Bytes | 5-row toy training template indicating planned classes (Forest, Agriculture, Built-up, Water, Barren). |

---

## 4. OUTPUTS & EXPERIMENTAL RESULTS (`output/` and `OUTPUT Sc/`)

| File Name | Size | Role & Scientific Significance |
|:---|:---|:---|
| [`output/change_detection/deforestation_statistics.csv`](file:///d:/RStudio/Deforestation%20Project/output/change_detection/deforestation_statistics.csv) | 265 Bytes | Primary quantitative results table documenting disturbance area (29,698.11 ha) and index change ranges. |
| [`output/deforestation_report.txt`](file:///d:/RStudio/Deforestation%20Project/output/deforestation_report.txt) | 728 Bytes | Plaintext summary of disturbance statistics and pixel class distributions. |
| `output/change_detection/dnbr.tif` | 191.9 MB | Full spatial raster of Differenced Normalized Burn Ratio across the study scene. |
| `output/change_detection/rdnbr.tif` | 201.1 MB | Full spatial raster of Relative Differenced NBR. |
| `output/change_detection/deforestation_classification.tif` | 7.3 MB | Discrete categorical raster mapping the 6 disturbance classes. |
| `output/report/deforestation_report.html` | 2.16 MB | Standalone comprehensive scientific report document with embedded figures. |
| `OUTPUT Sc/1.png` to `OUTPUT Sc/9.png` | ~3.5 MB total | High-resolution operational verification screenshots of the interactive dashboard interface and map views. |

---

## 5. DASHBOARD APPLICATION (`dashboard/`)

| Path | Significance |
|:---|:---|
| `dashboard/package.json` | Project dependencies: Next.js 15.0.3, React 19.0.0, ESLint. |
| `dashboard/app/page.js` | Main overview dashboard displaying metric cards (29,698 ha, 0.82%, mean dNBR 0.0071), hero map viewer, and disturbance tables. |
| `dashboard/app/analytics/page.js` | Analytics view displaying disturbance distributions and statistical charts. |
| `dashboard/app/maps/page.js` | Interactive map visualization portal for raster overlays. |
| `dashboard/app/reports/page.js` | Embedded spatial report viewer. |

