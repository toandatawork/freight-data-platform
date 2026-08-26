# Dataset

**Source:** [Logistics Operations Database](https://www.kaggle.com/datasets/yogape/logistics-operations-database)
by `yogape` on Kaggle.

**Not committed to this repository.** The 14 CSV files total ~57MB and are freely re-downloadable,
so this repository stores the *method of obtaining* the data rather than the data itself.

## Download

```bash
bash scripts/download_data.sh
```

Kaggle allows anonymous downloads through its API, so no account or token is required. The script
writes into `data/raw/` and prints a row count per file so you can verify the download immediately.

## Expected contents

14 CSV files plus `DATABASE_SCHEMA.txt`. Row counts exclude the header row:

| File | Rows | Role |
| --- | ---: | --- |
| `loads.csv` | 85,410 | Shipment orders — central fact |
| `trips.csv` | 85,410 | Trip executing each load |
| `delivery_events.csv` | 170,820 | Pickup and delivery timestamps (2 per load) |
| `fuel_purchases.csv` | 196,442 | Fuel transactions |
| `driver_monthly_metrics.csv` | 4,464 | Pre-aggregated driver performance |
| `truck_utilization_metrics.csv` | 3,312 | Pre-aggregated truck utilization |
| `maintenance_records.csv` | 2,920 | Maintenance history |
| `customers.csv` | 200 | Shipper accounts |
| `trailers.csv` | 180 | Trailer fleet |
| `safety_incidents.csv` | 170 | Safety events |
| `drivers.csv` | 150 | Driver roster |
| `trucks.csv` | 120 | Tractor fleet |
| `routes.csv` | 58 | Lane definitions |
| `facilities.csv` | 50 | Terminals and warehouses |

## Important: this data is synthetic

The dataset is script-generated, not real operational records from any carrier. Two consequences
shape how it is used in this project:

**The defects are material, not findings.** This data contains genuine quality problems — deliveries
timestamped before their pickup, on-time flags that contradict the underlying timestamps, trips
referencing drivers and trucks that do not exist. These are artifacts of the generator. They are
valuable here because they give a quality-control pipeline something real to catch, but they say
nothing about how freight systems behave in practice.

**Its statistical shape does not match reality.** Fuel prices are flat across months and the monthly
seasonality index stays within 0.925–1.031, meaning there is effectively no seasonality. Real freight
operations show pronounced diesel price movement and seasonal demand. This dataset therefore cannot
support forecasting, and no claim in this project depends on it doing so.

See `docs/data_quality_findings.md` for the measured profile of every table.

## License

Refer to the Kaggle dataset page for licensing terms.
