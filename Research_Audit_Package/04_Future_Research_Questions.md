# 04. FUTURE RESEARCH QUESTIONS

The following three research questions directly extend the empirical findings, algorithmic implementations, and technical limitations discovered during this project audit.

---

### RESEARCH QUESTION 1 (Methodological & Time-Series Modeling)
> **"How can harmonic seasonal decomposition and adaptive Kalman filtering be coupled with multi-sensor Earth observation time series to distinguish transient phenological variations from true anthropogenic canopy degradation?"**

1. **Specific Scientific/Computational Problem:** Bi-temporal spectral differencing (such as dNBR and $\Delta\text{NDVI}$) cannot differentiate between seasonal vegetative dormancy, crop harvesting, and true deforestation when observing short temporal windows.
2. **Project Finding/Limitation Motivating It:** The project analyzed a 16-day winter window where 29,675 ha were flagged as "low-severity disturbance," a signal vulnerable to phenological confounding and winter senescence.
3. **Why the Problem Matters:** False positives in satellite deforestation alerting degrade public trust, overwhelm forest enforcement patrols, and distort national carbon accounting under REDD+.
4. **Proposed Scientific/Computational Approach:** Construct a multi-year, multi-harmonic regression model (extending BFAST / LandTrendr principles) implemented on daily Harmonized Landsat-Sentinel (HLS) surface reflectance, utilizing Kalman filtering to dynamically update expected seasonal trajectories and flag statistical deviations exceeding dynamic confidence intervals.
5. **Possible Datasets:** NASA HLS (HLSL30 and HLSS30, 30m resolution, 2–3 day temporal revisit) combined with daily PlanetScope NICFI baselines (4.77m resolution).
6. **Testable Hypothesis:** Adaptive harmonic filtering reduces phenology-induced false-positive disturbance alerts by $\ge 35\%$ compared to static bi-temporal thresholding.
7. **Evaluation Strategy:** Stratified spatial validation against reference high-resolution visual imagery (PlanetScope/WorldView) and historical forest inventory plots, evaluated via precision, recall, and temporal latency (days to detection).
8. **Master's Thesis Suitability:** Feasible within 12–18 months; leverages the candidate's existing R/Python raster processing and time-series foundations.
9. **PhD Extension:** Developing neural ordinary differential equations (Neural ODEs) to continuously model continuous-time irregular satellite observations.

---

### RESEARCH QUESTION 2 (GeoAI & Spatiotemporal Deep Learning)
> **"Can spatiotemporal deep learning architectures (e.g., ConvLSTM, Temporal UNet) trained on multi-modal optical and Synthetic Aperture Radar (SAR) time series accurately detect forest degradation beneath cloud cover with quantified predictive uncertainty?"**

1. **Specific Scientific/Computational Problem:** Optical remote sensing (Landsat/Sentinel-2) suffers from cloud gaps and spectral saturation in dense canopies, while C-band SAR (Sentinel-1) provides all-weather structure sensing but suffers from speckle noise and topographical distortion.
2. **Project Finding/Limitation Motivating It:** Cloud cover in Scene 2 forced reliance on optical-only processing and caused friction during automated API downloading.
3. **Why the Problem Matters:** The highest deforestation rates globally occur in tropical regions characterized by near-constant cloud cover during critical logging seasons.
4. **Proposed Approach:** Design a multi-modal fusion deep network (Swin-UNet with temporal cross-attention) that ingests interleaved Sentinel-1 SAR (VV/VH backscatter, interferometric coherence) and Landsat 8/9 Level-2 reflectance. Integrate Monte Carlo Dropout or Evidential Deep Learning for pixel-level uncertainty estimation.
5. **Possible Datasets:** Sentinel-1 RTC backscatter paired with Landsat 8/9 Level-2 reflectance; GFW (Global Forest Watch) annual loss layers and Hansen Forest Loss polygons for training labels.
6. **Testable Hypothesis:** Multi-modal optical-SAR cross-attention achieves higher Intersection-over-Union ($\text{IoU} \ge 0.82$) in cloud-affected landscapes than either single-modality baseline.
7. **Evaluation Strategy:** Spatial-temporal cross-validation across three distinct biomes (tropical moist, subtropical dry, temperate mountain), evaluated on F1-score, IoU, and calibration error.
8. **Master's Thesis Suitability:** Highly suitable for a graduate student with a Geoinformatics background looking to bridge GIS and deep learning.
9. **PhD Extension:** Formulation of self-supervised spatiotemporal foundation models pretrained on multi-petabyte multimodal Earth observation archives.

---

### RESEARCH QUESTION 3 (Geospatial Systems & Foundation Models)
> **"How can geospatial foundation models be parameter-efficiently adapted (via LoRA and spatial adapter heads) to enable zero-shot and few-shot cross-regional forest disturbance mapping across diverse biogeographical biomes?"**

1. **Specific Scientific/Computational Problem:** Supervised land-cover and disturbance models (such as Random Forest and standard CNNs) fail when transferred across geographic domains due to severe distribution shift in soil background, atmospheric conditions, and tree species composition.
2. **Project Finding/Limitation Motivating It:** The project’s static USGS fire-severity thresholds were developed for North American conifers, yet applied here to a subtropical environment in Pakistan without regional recalibration.
3. **Why the Problem Matters:** Training region-specific models requires millions of hand-labeled reference pixels, creating severe bottlenecks for developing nations.
4. **Proposed Approach:** Utilize pretrained geospatial foundation backbones (e.g., NASA/IBM Prithvi, Clay, or SatMAE). Implement Low-Rank Adaptation (LoRA) and lightweight classification heads to evaluate transferability across continents with minimal labeled samples.
5. **Possible Datasets:** Prithvi-100M foundation model weights, paired with USGS Landsat-9, ESA WorldCover, and open-source forest inventory benchmarks.
6. **Testable Hypothesis:** LoRA fine-tuning on a foundation model with $< 50$ labeled samples per biome matches the accuracy ($\pm 2\%$ F1) of a fully trained Random Forest model requiring $> 10,000$ regional labels.
7. **Evaluation Strategy:** Out-of-distribution (OOD) testing across distinct ecological regions (Amazonia, Southeast Asia, South Asia, Congo Basin) measuring sample efficiency and accuracy.
8. **Master's Thesis Suitability:** Can be pursued as an exploratory transfer-learning benchmark study.
9. **PhD Extension:** Designing geographic representation learning objectives that embed spatial autocorrelation and physical geographic laws directly into foundation model pretraining.

