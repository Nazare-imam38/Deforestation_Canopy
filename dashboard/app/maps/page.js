import Image from "next/image";
import styles from "../page.module.css";

export default function MapsPage() {
    const maps = [
        { title: "Deforestation Classification", src: "/deforestation_classification_map.png", desc: "Identified deforestation zones based on dNBR severity." },
        { title: "dNBR (Difference Normalized Burn Ratio)", src: "/dnbr_map.png", desc: "Index used to highlight areas of biomass loss." },
        { title: "NDVI Change Map", src: "/ndvi_change_map.png", desc: "Displays the difference in vegetation greenness between two dates." },
    ];

    return (
        <div className={styles.main}>
            <header className={styles.header}>
                <div>
                    <h1>Geospatial Maps</h1>
                    <p className={styles.subtitle}>Detailed satellite imagery analysis layers</p>
                </div>
            </header>

            <section className={styles.secondaryGrid} style={{ gridTemplateColumns: '1fr' }}>
                {maps.map((map, i) => (
                    <div key={i} className="card">
                        <div className={styles.cardHeader}>
                            <h3>{map.title}</h3>
                        </div>
                        <p className={styles.subtitle} style={{ marginBottom: '1.5rem' }}>{map.desc}</p>
                        <div className={styles.chartPlaceholder} style={{ height: '500px' }}>
                            <Image
                                src={map.src}
                                alt={map.title}
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
