import Image from "next/image";
import styles from "./page.module.css";

export default function Home() {
  const stats = [
    { label: "Deforestated Area", value: "29,698 ha", trend: "0.82% of Total", color: "#ef4444" },
    { label: "NDVI Mean Change", value: "0.0045", trend: "Stable", color: "#10b981" },
    { label: "dNBR Mean", value: "0.0071", trend: "High Confidence", color: "#3b82f6" },
    { label: "Total Study Area", value: "36,217 km²", trend: "+2.4% vs Baseline", color: "#f59e0b" },
  ];

  return (
    <div className={styles.main}>
      <header className={styles.header}>
        <div>
          <h1>Deforestation Monitoring</h1>
          <p className={styles.subtitle}>Landsat 8-9 Time-Series Analysis</p>
        </div>
        <div className={styles.headerActions}>
          <button className={styles.btnPrimary}>Export PDF</button>
          <div className={styles.profile}>
            <div className={styles.avatar}>JS</div>
          </div>
        </div>
      </header>

      {/* Stats Grid */}
      <section className={styles.statsGrid}>
        {stats.map((stat, i) => (
          <div key={i} className="card">
            <span className={styles.statLabel}>{stat.label}</span>
            <div className={styles.statValue}>{stat.value}</div>
            <span className={styles.statTrend} style={{ color: stat.color }}>{stat.trend}</span>
          </div>
        ))}
      </section>

      {/* Primary Map Section */}
      <section className={styles.mapHero}>
        <div className={"card " + styles.heroCard}>
          <div className={styles.cardHeader}>
            <h3>Active Analysis: Deforestation Severity</h3>
            <span className={styles.badge}>Live Update</span>
          </div>
          <div className={styles.mapContainer}>
            <Image
              src="/deforestation_classification_map.png"
              alt="Deforestation Map"
              fill
              className={styles.mapImage}
              style={{ objectFit: 'contain' }}
            />
          </div>
        </div>
      </section>

      {/* secondary Grid */}
      <section className={styles.secondaryGrid}>
        <div className="card">
          <h3>dNBR Variance</h3>
          <div className={styles.chartPlaceholder}>
            <Image
              src="/dnbr_map.png"
              alt="dNBR Map"
              fill
              className={styles.mapImage}
              style={{ objectFit: 'cover' }}
            />
          </div>
        </div>
        <div className="card">
          <h3>NDVI Change Time-series</h3>
          <div className={styles.chartPlaceholder}>
            <Image
              src="/ndvi_timeseries_comparison.png"
              alt="NDVI Comparison"
              fill
              className={styles.mapImage}
              style={{ objectFit: 'contain' }}
            />
          </div>
        </div>
      </section>

      {/* detailed table */}
      <section className={styles.tableSection}>
        <div className="card">
          <h3>Recent Forest Disturbances</h3>
          <table className={styles.table}>
            <thead>
              <tr>
                <th>Location ID</th>
                <th>Detection Date</th>
                <th>Severity</th>
                <th>Area (ha)</th>
                <th>Status</th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td>#LOC-422</td>
                <td>Oct 12, 2024</td>
                <td><span className={styles.severityHigh}>High</span></td>
                <td>12.4</td>
                <td>In Review</td>
              </tr>
              <tr>
                <td>#LOC-421</td>
                <td>Oct 10, 2024</td>
                <td><span className={styles.severityMedium}>Medium</span></td>
                <td>4.8</td>
                <td>Confirmed</td>
              </tr>
              <tr>
                <td>#LOC-420</td>
                <td>Oct 08, 2024</td>
                <td><span className={styles.severityLow}>Low</span></td>
                <td>1.2</td>
                <td>Archived</td>
              </tr>
            </tbody>
          </table>
        </div>
      </section>
    </div>
  );
}
