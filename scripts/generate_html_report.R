# ==============================================================================
# GENERATE AUTOMATED HTML REPORT
# ==============================================================================
# Creates a comprehensive, modern HTML report of all deforestation analysis
# Automatically opens in browser
# ==============================================================================

cat("========================================\n")
cat("GENERATING HTML REPORT\n")
cat("========================================\n\n")

# Load packages
source("R/00_setup_packages.R")
source("R/01_config.R")

# Ensure maps are created first
if (!dir.exists(file.path(OUTPUT_DIR, "maps")) ||
    length(list.files(file.path(OUTPUT_DIR, "maps"), pattern = "\\.png$")) == 0) {
    cat("Maps not found. Creating maps first...\n")
    source("scripts/create_deforestation_maps.R")
    cat("\n")
}

# Check if required packages are available
if (!require(knitr, quietly = TRUE)) {
    install.packages("knitr")
    library(knitr)
}

# Load all analysis results
cat("Loading analysis results...\n")

# Load statistics
stats_file <- file.path(OUTPUT_DIR, "change_detection", "deforestation_statistics.csv")
if (file.exists(stats_file)) {
    stats <- read.csv(stats_file)
    cat("✓ Loaded statistics\n")
} else {
    stop("Statistics file not found. Run change detection first.")
}

# Load rasters (for embedding)
change_dir <- file.path(OUTPUT_DIR, "change_detection")
maps_dir <- file.path(OUTPUT_DIR, "maps")
indices_dir <- file.path(OUTPUT_DIR, "indices")

# Install base64enc if needed
if (!require(base64enc, quietly = TRUE)) {
    install.packages("base64enc")
    library(base64enc)
}

# Function to embed image as base64
embed_image_base64 <- function(image_path) {
    if (file.exists(image_path)) {
        img_data <- readBin(image_path, "raw", file.info(image_path)$size)
        base64 <- base64enc::base64encode(img_data)
        return(paste0("data:image/png;base64,", base64))
    }
    return(NULL)
}

cat("Preparing report content...\n")

# Get current date
report_date <- format(Sys.Date(), "%B %d, %Y")
report_time <- format(Sys.time(), "%H:%M:%S")

# Load deforestation classification for statistics
deforestation_class_file <- file.path(change_dir, "deforestation_classification.tif")
if (file.exists(deforestation_class_file)) {
    deforestation_class <- rast(deforestation_class_file)

    # Calculate classification statistics
    class_counts <- c(
        sum(values(deforestation_class) == 1, na.rm = TRUE),
        sum(values(deforestation_class) == 2, na.rm = TRUE),
        sum(values(deforestation_class) == 3, na.rm = TRUE),
        sum(values(deforestation_class) == 4, na.rm = TRUE),
        sum(values(deforestation_class) == 5, na.rm = TRUE),
        sum(values(deforestation_class) == 6, na.rm = TRUE)
    )

    total_pixels <- sum(class_counts)
    class_percentages <- round(class_counts / total_pixels * 100, 2)

    class_names <- c(
        "Reforestation", "No Change", "Low Deforestation",
        "Moderate Deforestation", "High Deforestation", "Severe Deforestation"
    )

    cat("✓ Calculated classification statistics\n")
}

# Load NDVI and NBR stacks if available
ndvi_file <- file.path(indices_dir, "ndvi_timeseries.tif")
nbr_file <- file.path(indices_dir, "nbr_timeseries.tif")

if (file.exists(ndvi_file)) {
    ndvi_stack <- rast(ndvi_file)
    ndvi_dates <- names(ndvi_stack)
    cat("✓ Loaded NDVI time series\n")
}

if (file.exists(nbr_file)) {
    nbr_stack <- rast(nbr_file)
    nbr_dates <- names(nbr_stack)
    cat("✓ Loaded NBR time series\n")
}

# Load change detection rasters
dNBR_file <- file.path(change_dir, "dnbr.tif")
ndvi_change_file <- file.path(change_dir, "ndvi_change.tif")

if (file.exists(dNBR_file)) {
    dNBR <- rast(dNBR_file)
    cat("✓ Loaded dNBR\n")
}

if (file.exists(ndvi_change_file)) {
    ndvi_change <- rast(ndvi_change_file)
    cat("✓ Loaded NDVI change\n")
}

cat("\nGenerating HTML report...\n")

# Create HTML content
html_content <- paste0('<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Deforestation Detection Analysis Report</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        @import url("https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;600;700;800&display=swap");

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: "Outfit", sans-serif;
            line-height: 1.6;
            color: #f8fafc;
            background: #0f172a;
            padding: 40px 20px;
        }

        .container {
            max-width: 1100px;
            margin: 0 auto;
            background: rgba(30, 41, 59, 0.6);
            backdrop-filter: blur(12px);
            -webkit-backdrop-filter: blur(12px);
            border: 1px solid rgba(255, 255, 255, 0.1);
            border-radius: 24px;
            overflow: hidden;
            box-shadow: 0 20px 50px rgba(0,0,0,0.3);
        }

        .header {
            background: linear-gradient(135deg, rgba(16, 185, 129, 0.15) 0%, rgba(14, 165, 233, 0.15) 100%);
            color: white;
            padding: 60px 40px;
            text-align: center;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
        }

        .header h1 {
            font-size: 2.8em;
            font-weight: 800;
            margin-bottom: 15px;
            letter-spacing: -0.025em;
            color: #10b981;
        }

        .header h1 i {
            margin-right: 15px;
            color: #10b981;
        }

        .header p {
            font-size: 1.1em;
            color: #94a3b8;
            font-weight: 400;
        }

        .content {
            padding: 40px;
        }

        .section {
            margin-bottom: 50px;
            padding: 30px;
            background: rgba(15, 23, 42, 0.4);
            border-radius: 16px;
            border: 1px solid rgba(255, 255, 255, 0.05);
        }

        .section h2 {
            color: #10b981;
            font-size: 1.8em;
            font-weight: 700;
            margin-bottom: 25px;
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .section h2::after {
            content: "";
            flex: 1;
            height: 1px;
            background: rgba(255, 255, 255, 0.1);
        }

        .section h3 {
            color: #38bdf8;
            font-size: 1.3em;
            margin-top: 30px;
            margin-bottom: 15px;
            font-weight: 600;
        }

        .info-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
            gap: 20px;
            margin: 20px 0;
        }

        .info-card {
            background: rgba(30, 41, 59, 0.8);
            padding: 24px;
            border-radius: 12px;
            border: 1px solid rgba(255, 255, 255, 0.08);
            transition: transform 0.2s ease;
        }

        .info-card:hover {
            transform: translateY(-5px);
            border-color: rgba(16, 185, 129, 0.3);
        }

        .info-card h4 {
            color: #94a3b8;
            margin-bottom: 12px;
            font-size: 0.8em;
            text-transform: uppercase;
            letter-spacing: 1.5px;
            font-weight: 700;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .info-card h4 i {
            color: #10b981;
        }

        .info-card .value {
            font-size: 1.8em;
            font-weight: 800;
            color: #f8fafc;
        }

        .info-card .unit {
            font-size: 0.8em;
            color: #64748b;
            margin-left: 6px;
            font-weight: 400;
        }

        .stats-table, .classification-table {
            width: 100%;
            border-collapse: separate;
            border-spacing: 0;
            margin: 20px 0;
            background: transparent;
            border-radius: 12px;
            overflow: hidden;
        }

        .stats-table th, .classification-table th {
            background: rgba(15, 23, 42, 0.8);
            color: #94a3b8;
            padding: 18px;
            text-align: left;
            font-weight: 700;
            font-size: 0.85em;
            text-transform: uppercase;
            letter-spacing: 1px;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
        }

        .stats-table td, .classification-table td {
            padding: 16px 18px;
            border-bottom: 1px solid rgba(255, 255, 255, 0.05);
            color: #cbd5e1;
        }

        .stats-table tr:hover td, .classification-table tr:hover td {
            background: rgba(16, 185, 129, 0.05);
        }

        .class-badge {
            display: inline-block;
            padding: 4px 12px;
            border-radius: 6px;
            font-size: 0.8em;
            font-weight: 700;
            color: white;
        }

        .class-1 { background: #10b981; }
        .class-2 { background: #64748b; }
        .class-3 { background: #f59e0b; }
        .class-4 { background: #d97706; }
        .class-5 { background: #ef4444; }
        .class-6 { background: #b91c1c; }

        .map-container {
            margin: 30px 0;
            padding: 24px;
            background: rgba(15, 23, 42, 0.2);
            border-radius: 16px;
            border: 1px solid rgba(255, 255, 255, 0.05);
        }

        .map-container img {
            max-width: 100%;
            height: auto;
            border-radius: 12px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.4);
        }

        .map-title {
            font-size: 1.1em;
            font-weight: 700;
            color: #10b981;
            margin-bottom: 20px;
            text-align: center;
        }

        .highlight {
            background: linear-gradient(135deg, rgba(16, 185, 129, 0.1) 0%, rgba(14, 165, 233, 0.1) 100%);
            padding: 30px;
            border-radius: 16px;
            margin: 30px 0;
            border: 1px solid rgba(16, 185, 129, 0.2);
        }

        .highlight h3 {
            color: #10b981;
            margin-bottom: 15px;
            margin-top: 0;
        }

        .footer {
            background: rgba(15, 23, 42, 0.8);
            color: #64748b;
            padding: 40px;
            text-align: center;
            border-top: 1px solid rgba(255, 255, 255, 0.1);
        }

        .footer strong {
            color: #10b981;
        }

        .progress-bar {
            width: 100%;
            height: 12px;
            background: rgba(255, 255, 255, 0.1);
            border-radius: 10px;
            overflow: hidden;
            margin: 15px 0;
        }

        .progress-fill {
            height: 100%;
            background: linear-gradient(90deg, #10b981 0%, #3b82f6 100%);
            transition: width 1s ease-in-out;
        }

        ul li {
            position: relative;
            padding-left: 25px;
            margin-bottom: 12px;
            color: #cbd5e1;
        }

        ul li::before {
            content: "→";
            position: absolute;
            left: 0;
            color: #10b981;
            font-weight: bold;
        }

        @media print {
            body { background: white; color: black; padding: 0; }
            .container { box-shadow: none; border: none; width: 100%; max-width: none; }
            .section { background: white; border: 1px solid #eee; }
            .info-card { background: white; border: 1px solid #eee; color: black !important; }
            .header { background: #f8fafc; color: black !important; }
            .header h1, .header p { color: black !important; }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1><i class="fas fa-tree"></i> Deforestation Detection Analysis Report</h1>
            <p><i class="fas fa-satellite"></i> Comprehensive Analysis of Landsat Time-Series Data</p>
            <p style="margin-top: 10px; font-size: 0.9em;"><i class="fas fa-calendar-alt"></i> Generated on ', report_date, " at ", report_time, '</p>
        </div>

        <div class="content">
            <!-- Study Area Information -->
            <div class="section">
                <h2><i class="fas fa-map-marker-alt section-icon"></i> Study Area Information</h2>
                <div class="info-grid">
                    <div class="info-card">
                        <h4><i class="fas fa-globe"></i> Study Area Name</h4>
                        <div class="value">', STUDY_AREA_NAME, '</div>
                    </div>
                    <div class="info-card">
                        <h4><i class="fas fa-calendar"></i> Analysis Period</h4>
                        <div class="value">', START_DATE, '<span class="unit">to</span></div>
                        <div class="value" style="font-size: 1.2em; margin-top: 5px;">', END_DATE, '</div>
                    </div>
                    <div class="info-card">
                        <h4><i class="fas fa-folder-open"></i> Project Location</h4>
                        <div class="value" style="font-size: 1.2em;">', PROJECT_ROOT, '</div>
                    </div>
                </div>
            </div>

            <!-- Key Statistics -->
            <div class="section">
                <h2><i class="fas fa-chart-bar section-icon"></i> Key Statistics</h2>
                <div class="info-grid">
                    <div class="info-card">
                        <h4><i class="fas fa-ruler-combined"></i> Deforestation Area</h4>
                        <div class="value">', round(stats$Value[stats$Metric == "Deforestation Area (km²)"], 2), '<span class="unit">km²</span></div>
                        <div style="margin-top: 5px; font-size: 0.9em; color: #7f8c8d;">
                            (', round(stats$Value[stats$Metric == "Deforestation Area (ha)"], 2), ' hectares)
                        </div>
                    </div>
                    <div class="info-card">
                        <h4><i class="fas fa-percentage"></i> Deforestation Percentage</h4>
                        <div class="value">', round(stats$Value[stats$Metric == "Deforestation %"], 2), '<span class="unit">%</span></div>
                        <div class="progress-bar" style="margin-top: 10px;">
                            <div class="progress-fill" style="width: ', round(stats$Value[stats$Metric == "Deforestation %"], 2), '%;">
                                ', round(stats$Value[stats$Metric == "Deforestation %"], 2), '%
                            </div>
                        </div>
                    </div>
                    <div class="info-card">
                        <h4><i class="fas fa-leaf"></i> Mean NDVI Change</h4>
                        <div class="value">', round(stats$Value[stats$Metric == "NDVI Change (mean)"], 4), '</div>
                    </div>
                    <div class="info-card">
                        <h4><i class="fas fa-fire"></i> Mean dNBR</h4>
                        <div class="value">', round(stats$Value[stats$Metric == "dNBR (mean)"], 4), '</div>
                    </div>
                </div>
            </div>

            <!-- Detailed Statistics Table -->
            <div class="section">
                <h2><i class="fas fa-table section-icon"></i> Detailed Statistics</h2>
                <table class="stats-table">
                    <thead>
                        <tr>
                            <th>Metric</th>
                            <th>Value</th>
                        </tr>
                    </thead>
                    <tbody>')

# Add statistics rows
for (i in 1:nrow(stats)) {
    html_content <- paste0(html_content, "
                        <tr>
                            <td>", stats$Metric[i], "</td>
                            <td><strong>", stats$Value[i], "</strong></td>
                        </tr>")
}

html_content <- paste0(html_content, '
                    </tbody>
                </table>
            </div>

            <!-- Deforestation Classification -->
            <div class="section">
                <h2><i class="fas fa-tags section-icon"></i> Deforestation Classification</h2>
                <table class="classification-table">
                    <thead>
                        <tr>
                            <th>Class</th>
                            <th>Category</th>
                            <th>Pixels</th>
                            <th>Percentage</th>
                        </tr>
                    </thead>
                    <tbody>')

# Add classification rows
for (i in 1:6) {
    html_content <- paste0(html_content, '
                        <tr>
                            <td><span class="class-badge class-', i, '">', i, "</span></td>
                            <td>", class_names[i], "</td>
                            <td>", format(class_counts[i], big.mark = ","), "</td>
                            <td><strong>", class_percentages[i], "%</strong></td>
                        </tr>")
}

html_content <- paste0(html_content, '
                    </tbody>
                </table>
            </div>

            <!-- Time Series Information -->
            <div class="section">
                <h2><i class="fas fa-clock section-icon"></i> Time Series Analysis</h2>')

if (exists("ndvi_dates")) {
    html_content <- paste0(html_content, '
                <h3><i class="fas fa-chart-line" style="margin-right: 8px; color: #667eea;"></i> NDVI Time Series Dates</h3>
                <ul style="list-style: none; padding: 0;">
                    <li style="padding: 10px; background: white; margin: 5px 0; border-radius: 5px;"><i class="fas fa-calendar-check" style="margin-right: 8px; color: #667eea;"></i> ', paste(ndvi_dates, collapse = '</li><li style="padding: 10px; background: white; margin: 5px 0; border-radius: 5px;"><i class="fas fa-calendar-check" style="margin-right: 8px; color: #667eea;"></i> '), "</li>
                </ul>")
}

if (exists("nbr_dates")) {
    html_content <- paste0(html_content, '
                <h3><i class="fas fa-chart-line" style="margin-right: 8px; color: #667eea;"></i> NBR Time Series Dates</h3>
                <ul style="list-style: none; padding: 0;">
                    <li style="padding: 10px; background: white; margin: 5px 0; border-radius: 5px;"><i class="fas fa-calendar-check" style="margin-right: 8px; color: #667eea;"></i> ', paste(nbr_dates, collapse = '</li><li style="padding: 10px; background: white; margin: 5px 0; border-radius: 5px;"><i class="fas fa-calendar-check" style="margin-right: 8px; color: #667eea;"></i> '), "</li>
                </ul>")
}

html_content <- paste0(html_content, '
            </div>

            <!-- Maps Section -->
            <div class="section">
                <h2><i class="fas fa-map section-icon"></i> Analysis Maps</h2>')

# Function to embed image as base64
embed_image_base64 <- function(image_path) {
    if (file.exists(image_path)) {
        img_data <- readBin(image_path, "raw", file.info(image_path)$size)
        base64 <- base64enc::base64encode(img_data)
        return(paste0("data:image/png;base64,", base64))
    }
    return(NULL)
}

# Add map images if they exist (embedded as base64)
if (file.exists(file.path(maps_dir, "dnbr_map.png"))) {
    map_base64 <- embed_image_base64(file.path(maps_dir, "dnbr_map.png"))
    if (!is.null(map_base64)) {
        html_content <- paste0(html_content, '
                <div class="map-container">
                    <div class="map-title">Deforestation Detection Map (dNBR)</div>
                    <img src="', map_base64, '" alt="dNBR Map" />
                </div>')
    }
}

if (file.exists(file.path(maps_dir, "deforestation_classification_map.png"))) {
    map_base64 <- embed_image_base64(file.path(maps_dir, "deforestation_classification_map.png"))
    if (!is.null(map_base64)) {
        html_content <- paste0(html_content, '
                <div class="map-container">
                    <div class="map-title">Deforestation Classification Map</div>
                    <img src="', map_base64, '" alt="Classification Map" />
                </div>')
    }
}

if (file.exists(file.path(maps_dir, "ndvi_change_map.png"))) {
    map_base64 <- embed_image_base64(file.path(maps_dir, "ndvi_change_map.png"))
    if (!is.null(map_base64)) {
        html_content <- paste0(html_content, '
                <div class="map-container">
                    <div class="map-title">NDVI Change Map</div>
                    <img src="', map_base64, '" alt="NDVI Change Map" />
                </div>')
    }
}

html_content <- paste0(html_content, '
            </div>

            <!-- Key Findings -->
            <div class="section">
                <h2><i class="fas fa-search section-icon"></i> Key Findings</h2>
                <div class="highlight">
                    <h3><i class="fas fa-clipboard-list" style="margin-right: 8px;"></i> Summary</h3>
                    <p>This analysis detected <strong>', round(stats$Value[stats$Metric == "Deforestation Area (km²)"], 2), " km²</strong> of deforestation in the study area, representing <strong>", round(stats$Value[stats$Metric == "Deforestation %"], 2), '%</strong> of the total area analyzed.</p>
                    <p style="margin-top: 10px;">The analysis was conducted using Landsat time-series data with ', length(ndvi_dates), ' acquisition dates, employing NDVI and NBR indices for change detection.</p>
                </div>
            </div>

            <!-- Methodology -->
            <div class="section">
                <h2><i class="fas fa-flask section-icon"></i> Methodology</h2>
                <h3><i class="fas fa-database" style="margin-right: 8px; color: #667eea;"></i> Data Sources</h3>
                <ul style="margin-left: 20px; line-height: 2;">
                    <li><i class="fas fa-satellite" style="margin-right: 8px; color: #667eea;"></i> Landsat 8/9 Collection 2 Level-2 Surface Reflectance</li>
                    <li><i class="fas fa-clock" style="margin-right: 8px; color: #667eea;"></i> Time series analysis with multiple acquisition dates</li>
                    <li><i class="fas fa-chart-area" style="margin-right: 8px; color: #667eea;"></i> Spectral indices: NDVI and NBR</li>
                </ul>

                <h3><i class="fas fa-cogs" style="margin-right: 8px; color: #667eea;"></i> Analysis Methods</h3>
                <ul style="margin-left: 20px; line-height: 2;">
                    <li><i class="fas fa-leaf" style="margin-right: 8px; color: #27ae60;"></i> <strong>NDVI (Normalized Difference Vegetation Index):</strong> Measures vegetation health and density</li>
                    <li><i class="fas fa-fire" style="margin-right: 8px; color: #e74c3c;"></i> <strong>NBR (Normalized Burn Ratio):</strong> Sensitive to vegetation loss and forest disturbance</li>
                    <li><i class="fas fa-exchange-alt" style="margin-right: 8px; color: #f39c12;"></i> <strong>dNBR (differenced NBR):</strong> Primary indicator for deforestation detection</li>
                    <li><i class="fas fa-layer-group" style="margin-right: 8px; color: #3498db;"></i> <strong>Classification:</strong> 6-class severity system based on dNBR thresholds</li>
                </ul>
            </div>
        </div>

        <div class="footer">
            <p><i class="fas fa-file-alt" style="margin-right: 8px;"></i><strong>Deforestation Detection Analysis Report</strong></p>
            <p><i class="fas fa-code" style="margin-right: 8px;"></i>Generated using R and Landsat satellite imagery</p>
            <p><i class="fas fa-copyright" style="margin-right: 8px;"></i>© ', format(Sys.Date(), "%Y"), " - Automated Analysis System</p>
        </div>
    </div>
</body>
</html>")

# Save HTML file
report_dir <- file.path(OUTPUT_DIR, "report")
dir.create(report_dir, showWarnings = FALSE, recursive = TRUE)

report_file <- file.path(report_dir, "deforestation_report.html")
writeLines(html_content, report_file)

cat("✓ HTML report generated:", report_file, "\n\n")

# Open in browser
cat("Opening report in browser...\n")
browseURL(report_file)

cat("\n========================================\n")
cat("✓ REPORT GENERATION COMPLETE!\n")
cat("========================================\n\n")
cat("Report saved:", report_file, "\n")
cat("Report should open automatically in your default browser.\n\n")
