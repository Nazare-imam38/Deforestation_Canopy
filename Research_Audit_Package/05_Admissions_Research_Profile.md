# 05. ADMISSIONS-READY RESEARCH PROFILE

**Applicant:** Nazar E Imam  
**Undergraduate Degree:** B.E. Geoinformatics Engineering, National University of Sciences and Technology (NUST), CGPA 3.52/4.00  
**Target Programs:** Fully Funded MS and PhD in GIScience, GeoAI, Remote Sensing, Earth Observation, and Spatial Computing  

---

## 1. THREE-SENTENCE RESEARCH SUMMARY

1. I developed an automated Earth observation processing pipeline in R that ingests, harmonizes, and analyzes multi-temporal Landsat 8 and 9 Level-2 Surface Reflectance imagery across 3.6 million hectares.
2. The system executes automated spatial grid alignment, computes biophysical spectral indices (NDVI and NBR), and evaluates canopy disturbance using differenced Normalized Burn Ratio ($\text{dNBR}$) and relative differencing ($\text{RdNBR}$).
3. The empirical pipeline mapped 29,698.11 ha (0.82%) of localized forest disturbance over a 16-day window and integrated the analytical findings into a standalone interactive HTML reporting pipeline and a responsive Next.js web dashboard.

---

## 2. COMPREHENSIVE RESEARCH SUMMARY (350 WORDS)

To address the computational bottleneck of tracking environmental disturbances across large landscapes, I developed an end-to-end satellite image processing and geospatial analytics pipeline in R and Next.js. The objective was to build an automated, reproducible workflow for multi-sensor satellite data harmonization, biophysical index calculation, canopy disturbance mapping, and interactive spatial reporting. Using USGS Landsat Collection 2 Tier 1 Level-2 Surface Reflectance products, the system harmonized multi-temporal scenes from Landsat 8 (OLI) and Landsat 9 (OLI-2) across WRS-2 Path 150, Row 37 (covering a 3.6-million-hectare area across northern Pakistan) acquired between December 9 and December 25, 2024. 

The analytical workflow systematically parses raw multi-band GeoTIFFs, projects all rasters to UTM Zone 43N (WGS 84), and performs bilinear resampling to a unified 30-meter spatial template. It computes multi-temporal Normalized Difference Vegetation Index (NDVI) and Normalized Burn Ratio (NBR) surfaces, followed by algebraic differencing ($\text{dNBR} = \text{NBR}_{t_1} - \text{NBR}_{t_2}$) and Relative dNBR ($\text{RdNBR}$) to account for baseline vegetation density. Using standardized USGS disturbance severity stratification, the pipeline mapped 29,698.11 hectares ($296.98\text{ km}^2$) of forest disturbance (0.82% of the landscape), with 98.73% of the territory remaining stable and 0.44% showing short-term greening. The outputs were compiled into a standalone base64-embedded HTML report and deployed to a full-stack Next.js dashboard featuring responsive layout architecture, disturbance metric visualizations, and cartographic overlays.

While the pipeline establishes a resilient infrastructure for multi-sensor ingestion, it identified critical scientific limitations: static bi-temporal differencing over short temporal baselines is susceptible to phenological and agricultural variations, and lacks localized ground-truth validation. This experience motivates my prospective graduate research: developing self-calibrating spatiotemporal deep learning models and multi-sensor (optical-SAR) fusion frameworks that dynamically decouple seasonal phenology from anthropogenic deforestation under explicit uncertainty quantification.

---

## 3. ACADEMIC CV BULLET POINTS

- **Engineered an Automated Multi-Sensor Earth Observation Pipeline:** Developed modular R workflows to ingest, project, and bilinearly harmonize multi-temporal Landsat 8/9 Level-2 Surface Reflectance rasters across a 3.6-million-hectare footprint (UTM Zone 43N).
- **Quantified Landscape-Scale Canopy Disturbance:** Derived multi-temporal NDVI, NBR, and RdNBR surfaces; classified disturbance severity using standardized USGS thresholds, mapping 29,698 ha (0.82%) of forest canopy disturbance with full automated metric aggregation.
- **Architected Modern Geospatial Decision-Support Systems:** Built an automated HTML report generator with embedded base64 cartography and implemented a full-stack Next.js interactive analytics dashboard for visualizing spatial metrics and disturbance distributions.

---

## 4. MASTER’S LETTER OF MOTIVATION RESEARCH PARAGRAPH (120 WORDS)

> "During my undergraduate research in Geoinformatics, I engineered an automated Earth observation pipeline in R to quantify forest disturbance from multi-temporal Landsat 8 and 9 Level-2 imagery across a 3.6-million-hectare landscape. I developed automated routines for multi-sensor grid harmonization, calculated bi-temporal Normalized Burn Ratio differencing ($\text{dNBR}$ and $\text{RdNBR}$), and mapped 29,698 hectares of canopy disturbance, which I integrated into a Next.js analytical dashboard. However, the analysis revealed a key limitation: short-term spectral differencing conflates seasonal vegetation senescence with true anthropogenic canopy loss. This finding motivated my desire to pursue Master's research, where I aim to investigate harmonic time-series decomposition and multimodal satellite fusion to distinguish true deforestation from natural phenological dynamics."

---

## 5. PERSONALIZED FACULTY OUTREACH PARAGRAPH (95 WORDS)

> "Dear Professor [Last Name],  
> I have closely followed your laboratory's work on spatiotemporal Earth observation modeling and environmental disturbance alerting. In my recent research, I engineered an automated pipeline in R that processed Landsat 8/9 Level-2 imagery across 3.6 million hectares to quantify canopy loss using dNBR and RdNBR. A key challenge I observed was the vulnerability of fixed-threshold differencing to phenological noise and sensor timing. I am eager to contribute to your research by combining my geoinformatics background and spatial pipeline engineering with your lab's work on self-supervised spatiotemporal representation learning and multimodal optical-SAR fusion for scalable disturbance monitoring."

---

## 6. PROPOSED GRADUATE RESEARCH DIRECTIONS

### Feasible Master’s Research Topic
- **Title:** Adaptive Harmonic Time-Series Modeling for Disentangling Phenological Drift from Forest Disturbance in Harmonized Landsat-Sentinel Data.
- **Approach:** Ingest dense 30m HLS time series, train dynamic harmonic regressors per pixel, and quantify deviations using adaptive Z-score thresholds to provide robust, near-real-time disturbance alerting.

### Ambitious PhD Research Topic
- **Title:** Physics-Informed Spatiotemporal Foundation Models for Multimodal Earth Observation and Uncertainty-Aware Forest Degradation Mapping.
- **Approach:** Pretrain self-supervised vision-language-spatial transformers on petabyte-scale paired optical (Landsat/Sentinel-2) and SAR (Sentinel-1/NISAR) imagery, incorporating physical radiative transfer constraints and Bayesian evidential deep learning to predict canopy structure loss with calibrated spatial uncertainty.

---

## 7. GRADUATE ADMISSION INTERVIEW QUESTIONS & EVIDENCE-GROUNDED ANSWERS

**Q1: Why did you use Landsat Level-2 Surface Reflectance instead of Level-1 Top-of-Atmosphere (TOA) data?**  
*Answer:* Level-2 products have undergone atmospheric correction (using the LaSRC algorithm for Landsat 8/9), converting raw digital numbers into physically meaningful surface reflectance by removing Rayleigh scattering, aerosol absorption, and atmospheric attenuation. For bi-temporal differencing (such as dNBR), using surface reflectance is critical so that differences between dates reflect real ground changes rather than varying atmospheric conditions.

**Q2: What is the difference between dNBR and RdNBR, and why did you calculate both?**  
*Answer:* dNBR is the absolute difference ($\text{NBR}_{t_1} - \text{NBR}_{t_2}$). However, dNBR can be biased in areas with naturally sparse or low pre-disturbance vegetation cover. Relative dNBR ($\text{RdNBR} = \text{dNBR} / \sqrt{|\text{NBR}_{t_1}|}$) divides the difference by the square root of the pre-disturbance NBR, normalizing the metric across heterogeneous canopy densities and isolating disturbance magnitude regardless of baseline cover.

**Q3: Why was the observed disturbance concentrated almost entirely in the "Low Severity" class?**  
*Answer:* In our dataset, Class 3 ($0.10 \le \text{dNBR} < 0.27$) accounted for 99.9% of all detected disturbance, while moderate-to-severe classes were negligible. Because the observation period was only 16 days in December, there were no catastrophic stand-replacing wildfires or clear-cuts. The subtle spectral drops captured in Class 3 likely represent winter crop clearing, localized grazing, or gradual winter canopy drying.

**Q4: In your documentation, you discuss BFAST time series and Random Forest classification. Were these implemented?**  
*Answer:* Yes, I wrote the complete modular R scripts for both BFAST decomposition (`R/08_bfast_analysis.R`) and Random Forest training (`R/09_classification.R`). However, in the actual experimental run, BFAST was not executed because three temporal observations over 16 days cannot satisfy the mathematical requirements for harmonic seasonal decomposition. Similarly, Random Forest was not run because we lacked field-verified ground truth polygons. The scripts stand ready for multi-year data integration.

**Q5: How did you resolve the discrepancy between your configuration bounding box and the downloaded Landsat data?**  
*Answer:* The initial configuration file contained coordinates for a theoretical study area in Southeast Asia. However, the manually ingested scenes were from Path 150, Row 37 over Pakistan. In `scripts/process_manual_landsat.R`, I implemented an automated spatial bounding check: when the script detected that the AOI and scene extents did not intersect, it caught the exception and defaulted to processing the full unified footprint of the available Landsat scenes.

**Q6: What coordinate reference system did you use and why?**  
*Answer:* We projected the rasters into WGS 84 / UTM Zone 43N (EPSG:32643). Projecting into a conformal, metric Universal Transverse Mercator zone is essential for spatial area calculations because it allows us to convert pixel counts directly into square meters ($30\text{ m} \times 30\text{ m} = 900\text{ m}^2$) and hectares ($0.09\text{ ha/pixel}$) without distortion.

**Q7: How did you handle cloud contamination across your scenes?**  
*Answer:* The three scenes exhibited low cloud cover (0.29%, 0.54%, and 8.91%). While `R/05_preprocessing.R` includes QA band bitmasking logic for the `QA_PIXEL` band to filter cloud and cloud-shadow flags (bits 3 and 4), the manual pipeline bypassed full pixel masking to avoid spatial gaps, relying instead on scenes that were over 91% cloud-free.

**Q8: What distinguishes your work from an ordinary classroom GIS exercise?**  
*Answer:* Rather than relying on interactive desktop software like ArcGIS or QGIS, I engineered an automated, scriptable computational pipeline in R that handles file scanning, multi-scene bilinear grid alignment, index computation, area aggregation, and reporting. Furthermore, I built a modern Next.js web application to make the spatial data accessible to non-technical stakeholders.

**Q9: If you had another six months to work on this project, what would you do?**  
*Answer:* First, I would ingest a 10-year dense time series of Harmonized Landsat-Sentinel (HLS) data to execute my BFAST decomposition scripts and establish baseline seasonal envelopes. Second, I would integrate Sentinel-1 SAR backscatter to enable all-weather disturbance monitoring. Third, I would compile a field-verified reference dataset to train and validate machine learning classifiers with rigorous confusion matrices.

**Q10: How does this project prepare you for a PhD program in GeoAI or Spatial Computing?**  
*Answer:* It provided hands-on experience with the entire Earth observation lifecycle—from raw sensor metadata, projection systems, and raster algebra, to algorithmic limitations and software engineering. Having encountered the real-world challenges of data availability, sensor harmonization, and false-positive spectral signals, I am prepared to conduct research on foundation models, transfer learning, and uncertainty quantification in geospatial AI.

