# Instacart Analytics Project

## Overview

This project implements a **complete end-to-end SQL Server analytics pipeline** to explore and understand e-commerce user behavior and product performance using the **Instacart dataset**. It demonstrates advanced analytics, feature engineering, and data mart creation while preparing results for **Tableau visualizations**.

The project highlights:

- **Data ingestion & staging:** Efficiently load raw CSVs into staging tables with quality checks.  
- **Intermediate transformations:** Merge tables and compute aggregate metrics for users, products, and orders.  
- **Feature engineering:** Compute advanced metrics such as:
  - Reorder rates per user and product.  
  - Basket diversity and variety segmentation.  
  - Time-based engagement metrics (e.g., average days between orders).  
  - Product affinity and co-occurrence.  
- **Data marts:** Build dimension and fact tables optimized for reporting, analytics, and dashboarding:
  - `dim_users`, `dim_products`, `fact_orders`, `fact_user_product`, `fact_user_cohorts`.  
- **Advanced analytics & insights:** Cohort analysis, cross-product affinity, Pareto analysis, and identification of highly engaged users.  
- **Visualization-ready outputs:** Export tables as CSV for use in Tableau dashboards.

**Skills demonstrated:** SQL Server ETL, advanced T-SQL (CTEs, window functions), feature engineering, analytical thinking, scalable query optimization, and Tableau-ready data preparation.

## Getting the Raw Instacart Dataset

This project uses the **Instacart Market Basket Analysis** dataset. You can download all raw CSV files from Kaggle:  

**Kaggle Dataset:** [Instacart Market Basket Analysis](https://www.kaggle.com/datasets/psparks/instacart-market-basket-analysis?select=order_products__prior.csv)

### Included Files

| Filename | Description |
|----------|-------------|
| `orders.csv` | Order-level information, including user ID, order sequence, and days since prior order. |
| `order_products__prior.csv` | Products in users’ prior orders (main historical data for analysis). |
| `order_products__train.csv` | Products in the training set (used for validation or modeling). |
| `products.csv` | Product metadata (IDs, names, and categories). |
| `aisles.csv` | Product aisle information. |
| `departments.csv` | Product department information. |

### Steps to Download

1. **Create a Kaggle account** if you don’t already have one.  
2. Visit the dataset page: [Kaggle Dataset Link](https://www.kaggle.com/datasets/psparks/instacart-market-basket-analysis/data)  
3. Click **Download** to get a ZIP of all CSV files.  
4. Unzip the archive and place all CSV files in your project’s `data/raw/` folder.
5. **Reminder:** `order_products__prior.csv` is the largest file (~30M rows) and forms the foundation for most analytics in this project.

### ETL & Analytics Pipeline Flow

Raw CSVs

│

▼

+---------------------+

| 01_staging/ | -- Load raw CSVs into staging tables

| orders, products, |

| aisles, depts |

+---------------------+

│

▼

+---------------------+

| 02_intermediate/ | -- Merge, clean, and summarize data

| user & product |

| order summaries |

+---------------------+

│

▼

+---------------------+

| 03_feature_engineering/ | -- Compute metrics & features

| user features, |

| product features, |

| cohort & engagement |

+---------------------+

│

▼

+---------------------+

| 04_marts/ | -- Build analytical tables

| dim_users |

| dim_products |

| fact_orders |

| fact_user_product |

| fact_user_cohorts |

+---------------------+

│

▼

+---------------------+

| 05_analysis/ | -- Advanced analytics & insights

| order patterns |

| basket analysis |

| product popularity |

| reorder analysis |

| user behaviour |

| advanced insights |

+---------------------+

│

▼

Visualization-ready CSVs → Tableau Dashboards


## Folder Structure & Detailed Contents

instacart_analytics/

│

├── data/ # Raw and processed CSV files

│ ├── raw/ # Original dataset CSVs

│ │ ├── orders.csv

│ │ ├── order_products__prior.csv

│ │ ├── order_products__train.csv

│ │ ├── products.csv

│ │ ├── aisles.csv

│ │ └── departments.csv

│ │

│ ├── processed/ # Exported tables ready for analysis/Tableau

│ │ ├── dim_users.csv

│ │ ├── dim_products.csv

│ │ ├── fact_orders.csv

│ │ ├── fact_orders_tableau.csv

│ │ ├── fact_user_product.csv

│ │ ├── fact_user_product_tableau.csv

│ │ └── fact_user_cohorts.csv

│

├── sql/ # SQL scripts organized by stage

│ ├── 01_staging/ # Load raw CSVs into staging tables

│ │ ├── 01_stg_orders.sql

│ │ ├── 02_stg_order_products.sql

│ │ ├── 03_stg_products.sql

│ │ ├── 04_stg_aisles.sql

│ │ ├── 05_stg_departments.sql

│ │ └── 06_stg_quality_checks.sql

│ │

│ ├── 02_intermediate/ # Transformations & aggregations

│ │ ├── 01_int_orders.sql

│ │ ├── 02_int_user_orders.sql

│ │ ├── 03_int_product_orders.sql

│ │ ├── 04_int_user_product_summary.sql

│ │ ├── 05_int_product_metrics.sql

│ │ ├── 06_int_user_metrics.sql

│ │ └── 07_int_user_cohorts.sql

│ │

│ ├── 03_feature_engineering/ # Compute advanced features

│ │ ├── 01_user_features.sql

│ │ ├── 02_product_features.sql

│ │ ├── 03_user_product_features.sql

│ │ ├── 04_cohort_features.sql

│ │ ├── 05_time_based_features.sql

│ │ ├── 06_product_diversity_features.sql

│ │ └── 07_advanced_engagement_features.sql

│ │

│ ├── 04_marts/ # Build dimension and fact tables

│ │ ├── 01_dim_users.sql

│ │ ├── 02_dim_products.sql

│ │ ├── 03_fact_orders.sql

│ │ ├── 04_fact_user_product.sql

│ │ ├── 05_fact_user_cohorts.sql

│ │ └── 06_export_files.sql # Export processed tables to CSV

│ │

│ ├── 05_analysis/ # Advanced analytics & insights

│ │ ├── 01_data_overview.sql

│ │ ├── 02_order_patterns.sql

│ │ ├── 03_basket_analysis.sql

│ │ ├── 04_product_analysis.sql

│ │ ├── 05_reorder_analysis.sql

│ │ ├── 06_user_behaviour.sql

│ │ └── 07_advanced_insights.sql

│

├── docs/ # Documentation & visualizations

│ ├── visuals/ # Exported charts/screenshots from Tableau

│ │ ├── basket_analysis.png

│ │ ├── order_patterns.png

│ │ ├── orders_heatmap.png

│ │ ├── reorder_analysis.png

│ │ └── user_behaviour.png

│

├── full_script/ # Single file version of the full pipeline

│   └── full_script.sql

│

├── README.md # Project overview, instructions

├── .gitignore # Ignore raw data, temp files, system files

└── structure.txt # File tree structure


## Notes & Considerations

- **Raw CSVs are excluded from GitHub** due to file size; placeholders exist in `data/raw/`.  
- Scripts must be run sequentially:  
  `01_staging → 02_intermediate → 03_feature_engineering → 04_marts → 05_analysis`.  
- **Temporary tables and CTEs** are used extensively to optimize performance on large datasets.  
- **Exports to CSV** allow Tableau dashboards without additional transformations.  
- All scripts are **SQL Server-optimized**, using window functions, `COUNT_BIG`, and filtered aggregations.  

## Getting Started

1. Clone the repository:  
   ```bash
   git clone <repo_url>
   cd instacart_analytics
   
2. Place raw CSVs into `data/raw/`.

3. Open SQL Server Management Studio (SSMS) and connect to your database.

4. Execute scripts in order:
`sql/01_staging → sql/02_intermediate → sql/03_feature_engineering → sql/04_marts → sql/05_analysis`

5. Export tables from `04_marts` or `05_analysis` to `data/processed/` for Tableau.

6. Use `docs/visuals/` for dashboard screenshots for your portfolio.

## Skills Demonstrated

**SQL Server ETL & Data Engineering:** Efficient staging, cleaning, and mart creation.

**Analytical SQL:** CTEs, window functions, aggregations, cohort analysis, cross-product affinity.

**Feature Engineering:** Reorder rates, basket diversity, product co-occurrence, engagement metrics.

**Visualization Preparation:** Tableau-ready datasets with minimal processing.

**Pipeline Design:** Reproducible, modular, and scalable workflow.

**Portfolio Presentation:** Well-structured repository with documentation, visuals, and diagrams.
