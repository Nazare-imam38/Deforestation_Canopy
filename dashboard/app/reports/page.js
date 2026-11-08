import styles from "../page.module.css";

export default function ReportsPage() {
    return (
        <div className={styles.main}>
            <header className={styles.header}>
                <div>
                    <h1>Generated Reports</h1>
                    <p className={styles.subtitle}>Comprehensive analysis documents and summaries</p>
                </div>
                <div className={styles.headerActions}>
                    <a href="/report.html" target="_blank" className={styles.btnPrimary}>Open Full Report</a>
                </div>
            </header>

            <section className={styles.mapHero}>
                <div className={"card " + styles.heroCard} style={{ height: '80vh' }}>
                    <div className={styles.cardHeader}>
                        <h3>Project Summary Report</h3>
                        <span className={styles.badge}>HTML Format</span>
                    </div>
                    <div className={styles.mapContainer}>
                        <iframe
                            src="/report.html"
                            style={{ width: '100%', height: '100%', border: 'none', background: 'white' }}
                        />
                    </div>
                </div>
            </section>

            <section className={styles.tableSection}>
                <div className="card">
                    <h3>History of Generated Documents</h3>
                    <table className={styles.table}>
                        <thead>
                            <tr>
                                <th>Report Name</th>
                                <th>Type</th>
                                <th>Date</th>
                                <th>Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td>Deforestation Full Analysis</td>
                                <td>HTML</td>
                                <td>Feb 04, 2026</td>
                                <td><a href="/report.html" target="_blank" style={{ color: 'var(--primary)' }}>View</a></td>
                            </tr>
                            <tr>
                                <td>Statistical Summary</td>
                                <td>CSV</td>
                                <td>Feb 04, 2026</td>
                                <td><span style={{ color: 'var(--muted)' }}>Download</span></td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </section>
        </div>
    );
}
