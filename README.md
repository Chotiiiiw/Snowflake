# Bookstore Analytics

A Snowflake and dbt analytics project that transforms raw bookstore data into
clean silver models, SCD Type 2 dimensions, and a sales fact table.

## Architecture

Bronze sources
→ Silver cleaned and deduplicated models
→ dbt SCD Type 2 snapshots
→ Gold dimensions and fact_sales

## Data Models

### Silver

Silver models clean, cast, standardize, and deduplicate source records.

Invalid foreign keys are preserved and identified using:

- `is_valid_<foreign_key>`
- `is_valid_record`

Known orphan relationships produce warnings instead of stopping the pipeline.

### Gold Dimensions

- `dim_books`
- `dim_customers`
- `dim_promotions`
- `dim_publishers`
- `dim_staff`
- `dim_stores`

The dimensions use SCD Type 2 history from dbt snapshots.

### Fact Table

`fact_sales` has one row per order item.

Measures include:

- Gross sales
- Net sales
- Total cost
- Gross profit

Only valid silver orders, order items, and books are included.

## Running the Project

```bash
uv run dbt build \
  --project-dir bookstore_analytics \
  --full-refresh
