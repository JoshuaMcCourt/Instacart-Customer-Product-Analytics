# Instacart Analytics Project (SQL Server | Tableau)

## Overview

This project implements a complete end-to-end SQL Server analytics pipeline to explore and understand large-scale e-commerce user behaviour and product performance using the Instacart dataset (~30M+ transaction rows).

It is designed to replicate real-world **analytics engineering workflows**, including data ingestion, transformation, feature engineering, and data mart construction, with outputs prepared for business intelligence tools such as Tableau.

## Business Context & Value

Understanding customer purchasing behaviour is critical in e-commerce for driving growth, retention, and operational efficiency.

This project demonstrates how data can support:

- Customer segmentation and targeting strategies
- Product recommendation and cross-sell opportunities
- Inventory and supply chain optimisation
- Identification of high-value users and repeat purchasing patterns
- Basket composition analysis to improve product placement and bundling

## Key Analytical Insights

The pipeline enables deep behavioural analysis across users and products, including:

- Identification of **high-frequency and high-value customer segments**
- Measurement of **product reorder rates and customer loyalty patterns**
- Analysis of **basket diversity and purchasing variety**
- Detection of **product co-occurrence relationships** (affinity analysis)
- Temporal analysis of ordering behaviour (e.g. time between purchases)
- Cohort-based retention and engagement trends over time

## Pipeline Architecture

The project follows a structured analytics engineering workflow:

Raw CSVs

   ↓

Staging Layer (Data Ingestion & Quality Checks)

   ↓

Intermediate Transformations (Joins & Aggregations)

   ↓

Feature Engineering (User, Product, Behavioural Metrics)

   ↓

Data Marts (Star Schema Design)

   ↓

Analytical Queries

   ↓

Tableau Dashboards

## Data Model Design

A star-schema inspired data model was implemented to optimise analytical querying and BI performance:

- **dim_users** – User-level behavioural aggregates
- **dim_products** – Product metadata and performance metrics
- **fact_orders** – Transaction-level order data
- **fact_user_product** – User-product interaction history
- **fact_user_cohorts** – Cohort-based retention and engagement tracking

This structure enables scalable analysis and efficient dashboard integration.

## What This Project Demonstrates

#### SQL Server Data Engineering
- End-to-end ETL pipeline design using staging, transformation, and mart layers
- Efficient ingestion and processing of large-scale CSV datasets
- Modular and reproducible pipeline architecture

#### Advanced SQL & Analytics
- Extensive use of **CTEs, window functions, and aggregations**
- Cohort analysis and retention modelling
- Cross-product affinity and basket analysis
- Time-based behavioural analytics

#### Feature Engineering
- Reorder rates at user and product level
- Basket diversity and segmentation metrics
- Product co-occurrence and affinity features
- Customer engagement and frequency metrics

#### Business Intelligence Readiness
- Tableau-ready datasets with minimal transformation required
- Structured outputs optimised for dashboard performance
- Clear separation between transformation and presentation layers

## Scale & Performance
- Processed datasets exceeding **30M+ transaction rows**
- Optimised transformations using staging and intermediate layers
- Designed for scalability and efficient query execution on large datasets
- Leveraged SQL Server-specific optimisations (window functions, COUNT_BIG, filtered aggregations)

## SQL Engineering Highlights
- Modular query design using layered SQL scripts
- Efficient handling of large joins across multiple tables
- Use of window functions for ranking, partitioning, and temporal analysis
- Aggregation strategies for performance optimisation
- Structured pipeline mirroring production analytics workflows

## Visualisation Outputs

Processed datasets are exported into Tableau-ready formats, enabling interactive dashboards covering:
- Order trends and temporal patterns
- Customer purchasing behaviour
- Product popularity and ranking
- Basket composition and diversity
- Reorder behaviour and retention analysis

Dashboard outputs are available in:
`docs/visuals/`

## Data Sources

This project uses the **Instacart Market Basket Analysis dataset**.

Due to file size constraints, raw CSV files are not included in this repository.

To reproduce:
1. Download dataset from Kaggle:
**Kaggle Dataset:** [Instacart Market Basket Analysis](https://www.kaggle.com/datasets/psparks/instacart-market-basket-analysis?select=order_products__prior.csv)
2. Extract files into:
`data/raw/`


### Included Files

| Filename | Description |
|----------|-------------|
| `orders.csv` | Order-level information, including user ID, order sequence, and days since prior order. |
| `order_products__prior.csv` | Products in users’ prior orders (main historical data for analysis). |
| `order_products__train.csv` | Products in the training set (used for validation or modeling). |
| `products.csv` | Product metadata (IDs, names, and categories). |
| `aisles.csv` | Product aisle information. |
| `departments.csv` | Product department information. |


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


## Workflow
1. Load raw CSVs into staging tables
2. Perform intermediate transformations and aggregations
3. Engineer behavioural and analytical features
4. Build dimension and fact tables
5. Run analytical queries
6. Export results for Tableau dashboards

## Getting Started

1. Clone the repository:  
   `git clone <repo_url>
   cd instacart_analytics`
   
2. Place raw CSVs into `data/raw/`.

3. Open SQL Server Management Studio (SSMS) and connect to your database.

4. Execute scripts in order:
`sql/01_staging → sql/02_intermediate → sql/03_feature_engineering → sql/04_marts → sql/05_analysis`

5. Export tables from `04_marts` or `05_analysis` to `data/processed/` for Tableau.

6. Use `docs/visuals/` for dashboard screenshots for your portfolio.

## Why This Project Matters

This project demonstrates the ability to design and implement **production-style analytics pipelines**, bridging the gap between raw data and actionable business insight.

It reflects real-world analytics engineering practices, including:

- Structured ETL workflows
- Scalable data modelling
- Feature engineering for behavioural analysis
- Preparation of data for downstream BI and decision-making

## Skills Demonstrated
- SQL Server ETL & Data Engineering
- Advanced T-SQL (CTEs, window functions, aggregations)
- Data modelling (star schema design)
- Feature engineering for analytics
- Large-scale data processing
- Tableau-ready data preparation
- Analytical thinking and business insight generation

## Potential Extensions
- Integration with cloud data warehouses (BigQuery, Snowflake, Azure SQL)
- Incremental data pipeline design for real-time analytics
- Automated dashboard deployment
- Integration with Python for advanced modelling
- Recommendation system development using user-product interactions
  
## Notes & Considerations

- **Raw CSVs are excluded from GitHub** due to file size; placeholders exist in `data/raw/`.  
- Scripts must be run sequentially.
- **Temporary tables and CTEs** are used extensively to optimize performance on large datasets.  
- **Exports to CSV** allow Tableau dashboards without additional transformations.  
- All scripts are **SQL Server-optimized**, using window functions, `COUNT_BIG`, and filtered aggregations.

## Disclaimer

This project is for portfolio purposes only and is not intended for production deployment.
