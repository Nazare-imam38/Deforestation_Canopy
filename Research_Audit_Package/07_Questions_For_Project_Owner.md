# 07. QUESTIONS FOR PROJECT OWNER (NAZAR E IMAM)

To ensure complete accuracy during admissions interviews, faculty correspondence, and statement drafting, please clarify the following points regarding project provenance and authorship:

---

### 1. Collaborative Authorship & Team Contributions
- **Evidence in Workspace:** The Google Earth Engine project ID is registered to `ee-imamsyed716` (matching your surname/identity). In `.Rhistory`, an attempt was made to authenticate USGS EarthExplorer with `sh6081080@gmail.com` using the name "Salman Haider". In `dashboard/app/page.js`, an avatar initial reads "JS".
- **Question for You:** Did you collaborate with Salman Haider (or others) on this project, or was this code developed in collaboration with a classmate/colleague? Exactly which components did you author individually (e.g., the R pipeline, spatial analysis, Next.js frontend)?
- **Admissions Guidance:** For admissions committees, clearly stating personal authorship (e.g., *"I was solely responsible for engineering the R data harmonization pipeline, index derivation, and Next.js frontend, while my colleague assisted in acquiring scene downloads"*) projects complete honesty and academic integrity.

---

### 2. Geographic Target Selection
- **Evidence in Workspace:** `R/01_config.R` states that the study area is a "Tropical Forest Area" in Southeast Asia (Thailand/Cambodia bounding box: $102.5^\circ\text{–}103.5^\circ\text{ E}, 12.0^\circ\text{–}13.0^\circ\text{ N}$). However, the actual Landsat scenes processed are WRS-2 Path 150, Row 37, situated over northern Pakistan (Punjab / KP / Potohar region: $71.5^\circ\text{–}74.1^\circ\text{ E}, 32.0^\circ\text{–}34.2^\circ\text{ N}$).
- **Question for You:** Was Path 150, Row 37 chosen deliberately as a local test site due to familiarity with northern Pakistan's terrain, or was it selected because cloud-free scenes were readily available during the December 2024 testing period?
- **Admissions Guidance:** In interviews, frame this as: *"While the pipeline architecture was designed generically for tropical forest monitoring, we tested and validated the data engineering workflow on a cloud-free regional Landsat footprint across northern Pakistan."*

---

### 3. Classification Ground-Truthing & Validation Data
- **Evidence in Workspace:** The training folder `data/training/` contains only an empty template (`training_data_template.csv`) with 5 dummy rows, and `R/10_accuracy_assessment.R` was not executed.
- **Question for You:** Did you at any stage collect GPS field points, high-resolution visual validation samples (via Google Earth / PlanetScope), or land-use shapefiles that were stored elsewhere?
- **Admissions Guidance:** If no reference sample was collected, present this openly as a project boundary: *"In this phase of the work, our focus was establishing the automated ingestion and relative differencing pipeline; formal supervised classification and confusion matrix assessment were reserved for the subsequent multi-year phase."*

---

### 4. Next.js Dashboard Development Context
- **Evidence in Workspace:** The Next.js dashboard is located in `dashboard/` with high-resolution screenshots saved in `OUTPUT Sc/` on February 4, 2026.
- **Question for You:** Was the dashboard developed as part of a GIS application development portfolio piece, a client deliverable, or an academic demonstration? Did you code the React/Next.js frontend yourself?
- **Admissions Guidance:** This is a major competitive advantage for Spatial Data Science / Geoinformatics programs. It highlights your rare dual capability as both a remote sensing computational scientist and a full-stack geospatial software engineer.

---

### 5. Publication and Academic Submission Status
- **Evidence in Workspace:** `docs/README.md` notes: *"Created for Master's research in deforestation detection and monitoring."*
- **Question for You:** Has this work or any extension of it been submitted to a conference, symposium, university capstone presentation, or journal?
- **Current Audit Classification:** **Not Submitted / Unpublished Independent Technical Research Project**.

