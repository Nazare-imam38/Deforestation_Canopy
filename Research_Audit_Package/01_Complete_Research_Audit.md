# 01. COMPLETE SCIENTIFIC RESEARCH AUDIT REPORT

**Project Title:** Multi-Temporal Satellite Image Processing and Bi-Temporal Spectral Differencing for Forest Disturbance Mapping  
**Workspace Name:** Deforestation Project  
**Lead Investigator / Project Owner:** Nazar E Imam  
**Academic Background:** B.E. Geoinformatics Engineering, National University of Sciences and Technology (NUST), CGPA 3.52/4.00  
**Auditor:** Senior Research Supervisor, Scientific Auditor & GeoAI Specialist  
**Audit Date:** November 2026 (Reflecting codebase states from Nov 2025 – Feb 2026)  

---

## 1. EXECUTIVE SUMMARY & RESEARCH IDENTITY

This document presents a rigorous, evidence-based academic audit of the codebase located in `D:\RStudio\Deforestation Project`. Every statement, technical mechanism, numerical finding, and limitation outlined in this dossier is derived directly from empirical inspection of source scripts, metadata files, execution outputs, and application components.

### 1.1 Actual Research Topic vs. Documented Ambitions
- **Documented Ambitions (in `docs/README.md`):** Long-term multi-decadal time-series analysis (1984–2024) across Landsat 5/7/8/9 utilizing BFAST (Breaks For Additive Seasonal and Trend) structural break detection, machine-learning land-cover classifications (Random Forest and Support Vector Machines), and field-validated accuracy assessment.
- **Actual Implemented Research:** An operational, automated satellite image processing pipeline executing Level-2 Surface Reflectance calibration, spatial harmonization, bi-temporal spectral differencing (dNBR, RdNBR, and $\Delta\text{NDVI}$) across a 16-day observation window (December 9, 2024 to December 25, 2024), fixed-threshold disturbance severity categorization, statistical quantification, report compilation, and a full-stack Next.js analytical monitoring dashboard.

### 1.2 Core Finding
Over the 16-day window across Landsat Path 150, Row 37, the Differenced Normalized Burn Ratio ($\text{dNBR} = \text{NBR}_{t_1} - \text{NBR}_{t_2}$) detected forest disturbance / canopy loss across **29,698.11 hectares ($296.98\text{ km}^2$)**, corresponding to **0.82%** of the valid analyzed scene footprint. The majority of the scene (98.73%, 39,646,120 pixels) exhibited stability ("No Change"), while 0.44% (178,147 pixels) exhibited spectral greening/gain.

---

## 2. RESEARCH BACKGROUND & SCIENTIFIC MOTIVATION

### 2.1 The Environmental Problem
Tropical and subtropical forest ecosystems face severe degradation driven by legal/illegal logging, agricultural encroachment, wildfire, and infrastructure development. Timely, repeatable, and scalable Earth Observation (EO) pipelines are essential for near-real-time monitoring, supporting international carbon accounting frameworks (e.g., REDD+), and aiding environmental law enforcement.

### 2.2 Computational & Methodological Challenges Addressed
1. **Multi-Sensor Harmonization:** Ingesting and aligning scenes from differing sensors (Landsat 8 OLI and Landsat 9 OLI-2) acquired at separate timestamps.
2. **Atmospheric and Surface Calibration:** Ingesting Level-2 Surface Reflectance (L2SP) data to bypass raw digital number (DN) distortions.
3. **Automated Pipeline Execution:** Developing modular R scripts capable of scanning directory structures, grouping multi-band GeoTIFFs by scene identifier, aligning rasters to a unified grid via bilinear interpolation, calculating biophysical indices, categorizing change magnitude, and synthesizing multi-format reports without manual GIS intervention.

---

## 3. COMPREHENSIVE DATASET INVESTIGATION

| Attribute | Verified Empirical Specification |
|:---|:---|
| **Data Provider** | USGS Earth Resources Observation and Science (EROS) Center |
| **Mission / Sensors** | Landsat 8 (Operational Land Imager) & Landsat 9 (OLI-2) |
| **Product Level** | Landsat Collection 2, Tier 1, Level-2 Surface Reflectance (L2SP) |
| **Scenes Analyzed** | 1. `LC09_L2SP_150037_20241209_20241210_02_T1` (Landsat 9, Acquired: 2024-12-09)<br>2. `LC08_L2SP_150037_20241217_20241227_02_T1` (Landsat 8, Acquired: 2024-12-17)<br>3. `LC09_L2SP_150037_20241225_20241226_02_T1` (Landsat 9, Acquired: 2024-12-25) |
| **Worldwide Reference System (WRS-2)** | Path 150, Row 37 |
| **Temporal Coverage** | December 9, 2024 – December 25, 2024 (16 days) |
| **Spatial Resolution** | 30.0 meters per pixel |
| **Coordinate Reference System** | WGS 84 / UTM Zone 43N (EPSG:32643) |
| **Spatial Extent** | Upper-Left: 34.213° N, 71.566° E; Lower-Right: 32.076° N, 74.120° E (Northern Punjab / Khyber Pakhtunkhwa / Potohar boundary, Pakistan) |
| **Cloud Cover per Scene** | Scene 1 (Dec 09): 0.54%; Scene 2 (Dec 17): 8.91%; Scene 3 (Dec 25): 0.29% |
| **Bands Leveraged** | Band 1 (Coastal Aerosol), Band 2 (Blue), Band 3 (Green), Band 4 (Red), Band 5 (NIR, 0.85–0.88 µm), Band 6 (SWIR-1, 1.57–1.65 µm), Band 7 (SWIR-2, 2.11–2.29 µm) |
| **Observed Coordinate Discrepancy** | `R/01_config.R` defines a bounding box for "Southeast Asia / Cambodia" ($102.5^\circ\text{–}103.5^\circ\text{ E}, 12.0^\circ\text{–}13.0^\circ\text{ N}$). When executed, `scripts/process_manual_landsat.R` detects that the manual Landsat download (Path 150, Row 37 in Pakistan) does not intersect this theoretical bounding box. The script falls back to processing the full scene footprint of Path 150, Row 37. |

---

## 4. RECONSTRUCTED RESEARCH METHODOLOGY

```
[Level-2 Surface Reflectance Ingestion (B1-B7)]
                     │
                     ▼
[Multi-Temporal Scene Sorting & Metadata Parsing]
                     │
                     ▼
[Grid Harmonization & Resampling (30m Bilinear to Common Extent)]
                     │
                     ▼
[Spectral Feature Computation (NDVI & NBR per timestamp)]
                     │
                     ▼
[Bi-Temporal Differencing (ΔNDVI, dNBR = NBR_t1 - NBR_t2, RdNBR)]
                     │
                     ▼
[Threshold-Based Severity Stratification (USGS / Key & Benson)]
                     │
                     ▼
[Spatial Area Aggregation & Statistical Summaries (ha / km²)]
                     │
                     ▼
[Cartographic Production & Next.js Analytical Dashboard]
```

### Stage 1: Ingestion & Spatial Harmonization (`scripts/process_manual_landsat.R`)
1. Multi-band GeoTIFFs are scanned across `data/Landsat/imag*`.
2. Seven surface reflectance bands (`SR_B1` to `SR_B7`) per scene are read via `terra::rast`.
3. Extents are unioned into a bounding box, generating a common grid at 30 m resolution in UTM Zone 43N.
4. Rasters are resampled using bilinear interpolation to ensure exact pixel-to-pixel correspondence.
5. Multi-temporal layer stacks are exported (`processed_landsat_stack.tif`, 21 layers).

### Stage 2: Biophysical Spectral Index Derivation (`scripts/calculate_indices_from_processed.R`)
1. **Normalized Difference Vegetation Index (NDVI):**
   $$\text{NDVI} = \frac{\text{NIR (Band 5)} - \text{Red (Band 4)}}{\text{NIR (Band 5)} + \text{Red (Band 4)}}$$
2. **Normalized Burn Ratio (NBR):**
   $$\text{NBR} = \frac{\text{NIR (Band 5)} - \text{SWIR-2 (Band 7)}}{\text{NIR (Band 5)} + \text{SWIR-2 (Band 7)}}$$
3. Individual index rasters are written to `output/indices/` for timestamps 2024-12-09, 2024-12-17, and 2024-12-25.

### Stage 3: Disturbance Differencing & Relative Scaling (`scripts/detect_deforestation_changes.R`)
1. **NDVI Difference:**
   $$\Delta\text{NDVI} = \text{NDVI}_{2024-12-25} - \text{NDVI}_{2024-12-09}$$
2. **Differenced NBR (dNBR):**
   $$\text{dNBR} = \text{NBR}_{2024-12-09} - \text{NBR}_{2024-12-25}$$
   *(Note: Subtraction order produces positive dNBR values for canopy loss / moisture reduction, adhering to standard burn severity convention).*
3. **Relative Differenced NBR (RdNBR):**
   $$\text{RdNBR} = \frac{\text{dNBR}}{\sqrt{|\text{NBR}_{2024-12-09}|}}$$
   Corrects for pre-fire/pre-disturbance vegetative density variations.

### Stage 4: Disturbance Severity Stratification (`scripts/detect_deforestation_changes.R`)
Pixel values of dNBR are categorized according to established USGS Fire Severity thresholds (Key & Benson, 2006):
- $\text{dNBR} < -0.10$: Class 1 — Enhanced Regrowth / Reforestation
- $-0.10 \le \text{dNBR} < 0.10$: Class 2 — Unburned / No Disturbance
- $0.10 \le \text{dNBR} < 0.27$: Class 3 — Low-Severity Disturbance
- $0.27 \le \text{dNBR} < 0.44$: Class 4 — Moderate-Low Disturbance
- $0.44 \le \text{dNBR} < 0.66$: Class 5 — Moderate-High Disturbance
- $\text{dNBR} \ge 0.66$: Class 6 — High / Severe Disturbance

### Stage 5: Cartography, Automation & Dashboard
- Maps are rendered using base R plotting pipelines (`scripts/create_deforestation_maps.R`) with custom legends and color ramps.
- An HTML report (`scripts/generate_html_report.R`, 25.3 KB generator) compiles tabular statistics, methodology, and embedded maps.
- A modern Next.js web application (`dashboard/`) was engineered to surface metrics, severity breakdowns, interactive tabs (`/analytics`, `/maps`, `/reports`), and responsive spatial visualizations.

---

## 5. COMPUTATIONAL & METHODOLOGICAL STATUS

### 5.1 Verification of Proposed vs. Executed Algorithms

| Proposed in Documentation (`docs/`) | Status in Codebase | Empirical Evidence |
|:---|:---|:---|
| **BFAST Structural Break Analysis** | **PROPOSED / PARTIALLY SUPPORTED** | Complete script written in `R/08_bfast_analysis.R` with functions for pixel-wise and mean time-series decomposition. **Not executed** in final pipeline due to insufficient temporal depth (3 timestamps cannot support seasonal cycle fitting). |
| **Random Forest Classification** | **PROPOSED / PARTIALLY SUPPORTED** | Complete training logic implemented in `R/09_classification.R` (`randomForest`, variable importance plotting). **Not executed** because `data/training/` only contains an empty 5-row template (`training_data_template.csv`). |
| **Support Vector Machines (SVM)** | **PROPOSED** | Scripted in `R/09_classification.R` (`e1071::svm`). Not executed. |
| **Confusion Matrix / Kappa Accuracy** | **PROPOSED** | Written in `R/10_accuracy_assessment.R`. Not executed due to absence of independent ground truth validation points. |
| **Bi-temporal Spectral Differencing (dNBR, RdNBR, ΔNDVI)** | **VERIFIED & EXECUTED** | Fully executed in `scripts/detect_deforestation_changes.R`. Output GeoTIFFs, CSVs, and PNGs generated. |
| **Interactive Next.js Web Dashboard** | **VERIFIED & EXECUTED** | Fully developed React/Next.js dashboard in `dashboard/` with verified build artifacts and screenshots in `OUTPUT Sc/`. |

---

## 6. RESULTS AND EMPIRICAL FINDINGS

### 6.1 Quantitative Disturbance Findings (`output/change_detection/deforestation_statistics.csv`)

| Disturbance Class | dNBR Range | Pixel Count | Percentage (%) | Surface Area (ha) | Surface Area ($\text{km}^2$) |
|:---|:---|:---|:---|:---|:---|
| **Class 1: Regrowth / Reforestation** | $\text{dNBR} < -0.10$ | 178,147 | 0.44% | 16,033.23 | 160.33 |
| **Class 2: No Disturbance (Stable)** | $-0.10 \le \text{dNBR} < 0.10$ | 39,646,120 | 98.73% | 3,568,150.80 | 35,681.51 |
| **Class 3: Low Disturbance** | $0.10 \le \text{dNBR} < 0.27$ | 329,727 | 0.82% | 29,675.43 | 296.75 |
| **Class 4: Moderate Disturbance** | $0.27 \le \text{dNBR} < 0.44$ | 152 | < 0.001% | 13.68 | 0.14 |
| **Class 5: High Disturbance** | $0.44 \le \text{dNBR} < 0.66$ | 75 | < 0.001% | 6.75 | 0.07 |
| **Class 6: Severe Disturbance** | $\text{dNBR} \ge 0.66$ | 25 | < 0.001% | 2.25 | 0.02 |
| **Total Disturbance (Classes 3–6)** | $\text{dNBR} \ge 0.10$ | **329,979** | **0.82%** | **29,698.11** | **296.98** |

### 6.2 Spectral Dynamics Summary
- **Mean $\Delta\text{NDVI}$:** $+0.0045$ (Min: $-0.3859$, Max: $+0.5209$)
- **Mean dNBR:** $+0.0071$ (Min: $-0.9004$, Max: $+0.8107$)
- **Interpretation:** Across the total landscape of 3.6 million hectares, vegetation condition remained broadly stable over the 16-day winter window. Detected disturbance is heavily concentrated in Class 3 (Low Severity, 99.9% of all detected change), indicative of selective logging, agricultural clearing, seasonal drying, or localized brush clearing, rather than catastrophic stand-replacing canopy collapse.

---

## 7. SCIENTIFIC CONTRIBUTION & RESEARCH MATURITY

### 7.1 Classification of Contribution
- **Scientific Contribution:** Empirical quantification of short-term vegetative canopy perturbation across Landsat Path 150, Row 37 during December 2024.
- **Methodological Contribution:** Implementation of a resilient data processing workflow that automatically harmonizes heterogeneous Landsat 8 and 9 sensors, applies relative index scaling (RdNBR) alongside standard differencing, and handles spatial bounding mismatches gracefully.
- **Technical & Systems Contribution:** High-performance geospatial data pipeline in R coupled with a modern Next.js decision-support interface.
- **Research Maturity Level:** **Completed Applied Technical Workflow / Exploratory Scientific Prototype**.

---

## 8. REPRODUCIBILITY ASSESSMENT & LIMITATIONS

1. **Short Temporal Baseline (16 Days):** The three available scenes cover only Dec 9, Dec 17, and Dec 25, 2024. This short baseline measures immediate spectral change rather than chronic multi-year deforestation or phenological cycles.
2. **Phenological vs. Anthropogenic Confounding:** Without multi-year seasonal baselines, deciduous leaf-off, agricultural harvesting, and soil moisture shifts can produce false-positive disturbance signals in Class 3.
3. **Absence of Quantitative Validation:** No ground-truth reference dataset, UAV surveys, or high-resolution validation was paired with the raster outputs.
4. **Data Acquisition Obstacles:** Detailed logs demonstrate substantial friction with automated GEE and USGS API credentialing, necessitating manual scene ingestion.

