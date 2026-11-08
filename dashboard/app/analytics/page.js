import Image from "next/image";
import styles from "../page.module.css";

export default function AnalyticsPage() {
    const comparisons = [
        { title: "NDVI Time-Series Comparison", src: "/ndvi_timeseries_comparison.png" },
        { title: "NBR Time-Series Comparison", src: "/nbr_timeseries_comparison.png" },
    ];

    return (
        <div className={styles.main}>
            <header className={styles.header}>
                <div>
                    <h1>Temporal Analytics</h1>
                    <p className={styles.subtitle}>Time-series comparison of forest health indices</p>
                </div>
            </header>

            <section className={styles.statsGrid}>
                <div className="card">
                    <span className={styles.statLabel}>Avg NDVI Recovery</span>
                    <div className={styles.statValue}>+0.12</div>
                    <span className={styles.statTrend} style={{ color: '#10b981' }}>Improving Trend</span>
                </div>
                <div className={styles.card}>
                    <span className={styles.statLabel}>Biomass Loss Index</span>
                    <div className={styles.statValue}>Low</div>
                    <span className={styles.statTrend} style={{ color: '#3b82f6' }}>Stable</span>
                </div>
            </section>

            <section className={styles.secondaryGrid} style={{ gridTemplateColumns: '1fr' }}>
                {comparisons.map((item, i) => (
                    <div key={i} className="card">
                        <div className={styles.cardHeader}>
                            <h3>{item.title}</h3>
                        </div>
                        <div className={styles.chartPlaceholder} style={{ height: '600px' }}>
                            <Image
                                src={item.src}
                                alt={item.title}
                                fill
                                style={{ objectFit: 'contain' }}
                            />
                        </div>
                    </div>
                ))}
            </section>
        </div>
    );
}
