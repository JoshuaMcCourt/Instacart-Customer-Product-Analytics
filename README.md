# Instacart Analytics Project

## Overview
This project demonstrates a complete end-to-end SQL Server analytics pipeline for understanding e-commerce user behavior and product performance using the Instacart dataset. It includes:

- **Data ingestion & staging:** Loading raw CSVs into SQL Server.
- **Intermediate transformations:** Merging tables and computing user/product metrics.
- **Feature engineering:** Metrics like reorder rates, basket diversity, and user engagement.
- **Data marts:** Dimension and fact tables for BI visualization.
- **Advanced analytics:** Cohort analysis, cross-product affinity, Pareto insights, and predictive signals for high-reorder users.
- **Visualization-ready exports:** Prepared CSVs for Tableau dashboards.

**Skills demonstrated:** SQL Server ETL, feature engineering, analytical thinking, Tableau-ready data modeling, scalable query optimization.

## Folder Structure
- `data/` – Placeholder for raw and processed CSVs (files are too large for GitHub).
- `sql/` – All SQL scripts organized by staging, intermediate, feature engineering, marts, and analysis.
- `docs/visuals/` – Screenshots of Tableau dashboards.
- `docs/instacart_sql_pipeline_diagram.png` – Diagram showing ETL flow.
- `full_script/` – Single script with the entire pipeline.
- `.gitignore` – Configured for Visual Studio, SQL, Tableau, and large CSVs.

## Notes
- **Raw and processed CSVs are excluded** due to GitHub file size limitations.
- Use Tableau Desktop/Prep to connect to your SQL Server instance for visualizations.
- All scripts are optimized for large datasets and minimal repeated scans.

## Getting Started
1. Clone the repository.
2. Run SQL scripts in order: `01_staging → 02_intermediate → 03_feature_engineering → 04_marts → 05_analysis`.
3. Export tables as CSV for Tableau visualization (optional, for local use only).
4. Use `docs/visuals/` to include screenshots of your dashboards for portfolio display.

