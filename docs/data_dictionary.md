# 📦 Logistics Operations Database: Comprehensive Data Dictionary

---

## 1. Dataset Overview

### 1.1 Business Context
This dataset simulates the end-to-end operational lifecycle of a mid-to-large-scale **Truckload Freight Carrier** in the United States over a 3-year period (from **January 1, 2022** to **December 31, 2024**).

The system captures a closed-loop business workflow:
1. **Order Booking (`loads`):** Shippers (`customers`) book freight shipments across predefined corridors (`routes`) under different contract models (Dedicated, Contract, Spot).
2. **Dispatch & Execution (`trips`):** Each shipment trip pairs 1 Driver (`drivers`), 1 Tractor (`trucks`), and 1 Trailer (`trailers`) to execute the haul.
3. **Milestone Tracking (`delivery_events`):** Captures timestamped events for Pickup and Delivery at facilities/distribution centers (`facilities`), computing detention time and On-time Delivery (OTD) performance.
4. **Operating Expenses (`fuel_purchases`):** Tracks commercial fuel stops, invoices, fuel card transactions, and diesel prices.
5. **Asset Maintenance (`maintenance_records`):** Logs scheduled maintenance, repairs, parts/labor costs, and fleet downtime.
6. **Safety & Risk Management (`safety_incidents`):** Records DOT reportable accidents, traffic violations, cargo damage, and insurance claims.
7. **Periodic Reporting (`driver_monthly_metrics`, `truck_utilization_metrics`):** Aggregated monthly performance tracking driver productivity, fuel efficiency, and asset utilization.

---

### 1.2 Table Inventory & Volume Summary (All 14 Tables)

| # | Table Name (CSV) | Entity Type | Row Count | Primary Key | Description |
|:---:|:---|:---|:---:|:---|:---|
| 1 | `drivers.csv` | **Dimension** | 150 | `driver_id` | Driver roster, CDL licenses, pay rates, and employment status |
| 2 | `trucks.csv` | **Dimension** | 120 | `truck_id` | Fleet tractors (specs, odometer, domicile base, status) |
| 3 | `trailers.csv` | **Dimension** | 180 | `trailer_id` | Trailing equipment (Dry Van / Reefer, dimensions, status) |
| 4 | `customers.csv` | **Dimension** | 200 | `customer_id` | Shippers directory, contract types, annual revenue potential |
| 5 | `facilities.csv` | **Dimension** | 50 | `facility_id` | Warehouse/terminal network, distribution centers, docks |
| 6 | `routes.csv` | **Dimension** | 58 | `route_id` | Standard freight corridors (mileage, base rate per mile) |
| 7 | `loads.csv` | **Fact (Orders)** | 85,410 | `load_id` | Freight orders, weight, pallet count, revenue & fuel surcharges |
| 8 | `trips.csv` | **Fact (Operations)** | 85,410 | `trip_id` | Executed linehaul trips (assigned assets, odometer, diesel burn) |
| 9 | `fuel_purchases.csv` | **Fact (Expenses)** | 196,442 | `fuel_purchase_id` | Fuel card transactions, gallons pumped, diesel price per gallon |
| 10 | `delivery_events.csv` | **Fact (Milestones)** | 170,820 | `event_id` | Pickup & Delivery actuals, appointment windows, detention |
| 11 | `maintenance_records.csv` | **Fact (Maintenance)** | 2,920 | `maintenance_id` | Repair orders, parts/labor expenses, tractor downtime hours |
| 12 | `safety_incidents.csv` | **Fact (Safety)** | 170 | `incident_id` | DOT accidents, citations, cargo claims, preventative flags |
| 13 | `driver_monthly_metrics.csv` | **Aggregate** | 4,464 | `(driver_id, month)` | Monthly driver KPI scorecards (miles, on-time rate, pay) |
| 14 | `truck_utilization_metrics.csv` | **Aggregate** | 3,312 | `(truck_id, month)` | Monthly equipment utilization, maintenance cost per mile |

> **Total Dataset Volume:** 14 tables, **549,536 records** spanning 3 years.

---

## 2. Entity Relationship Diagram (ERD)

```
                       ┌───────────────────────┐
                       │       CUSTOMERS       │
                       └───────────┬───────────┘
                                   │ 1
                                   │ N
┌──────────────┐       N         1 ├─────────────────────────┐
│    ROUTES    ├───────────────────┤          LOADS          │
└──────────────┘                   └────────────┬────────────┘
                                                │ 1
                                                │ 1 (One-to-One)
┌──────────────┐                   N          1 │
│   DRIVERS    ├───────────────────┬────────────┴────────────┐
└──────┬───────┘                   │                         │
       │ 1                         │          TRIPS          │
       │                           │                         │
       │ N                         └────────────┬────────────┘
┌──────┴───────────────────┐                    │ 1
│  DRIVER_MONTHLY_METRICS  │                    │
└──────────────────────────┘                    │ N
                                                ├──────────────────────────┐
┌──────────────┐                   N          1 │                          │
│    TRUCKS    ├───────────────────┬────────────┴────────────┐             │
└──────┬───────┘                   │                         │             │
       │ 1                         │     DELIVERY_EVENTS     │             │
       │ N                         │                         │             │
┌──────┴──────────────────────┐    └────────────┬────────────┘             │
│  TRUCK_UTILIZATION_METRICS  │                 │ N                        │
└─────────────────────────────┘                 │                          │
                                                │ 1                        │
┌──────────────────────────┐       N          1 │                          │
│   MAINTENANCE_RECORDS    ├────────────────────┤        FACILITIES        │
└──────────────────────────┘                    └──────────────────────────┘
                                                             ▲
┌──────────────────────────┐       N                       1 │
│     SAFETY_INCIDENTS     ├─────────────────────────────────┘
└──────────────────────────┘

┌──────────────────────────┐
│      FUEL_PURCHASES      │───► (Related to Trucks/Drivers via truck_id, driver_id)
└──────────────────────────┘
```

---

## 3. Detailed Schema & Data Dictionary

### 3.1 `drivers.csv` (Dimension)
* **Grain:** 1 row per professional commercial driver.
* **Volume:** 150 rows.

| Column | Type | Nullable | Description | Sample Values |
|:---|:---|:---:|:---|:---|
| `driver_id` | STRING | No | Primary Key: Unique driver identifier | `DRV00000001` |
| `first_name` | STRING | No | Driver first name | `John`, `David` |
| `last_name` | STRING | No | Driver last name | `Smith`, `Johnson` |
| `date_of_birth` | DATE | No | Birth date (Age 21-65) | `1985-04-12` |
| `hire_date` | DATE | No | Employment hire date | `2021-03-15` |
| `license_number` | STRING | No | Commercial Driver's License (CDL) number | `CDL12345678` |
| `license_state` | STRING | No | State issuing the CDL license | `TX`, `IL`, `CA` |
| `home_terminal_id` | STRING | No | Home domicile facility (`facilities.facility_id`) | `FAC00000001` |
| `driver_type` | STRING | No | Employment classification (`Company`, `Owner-Operator`) | `Company` |
| `pay_rate_per_mile` | DECIMAL(5,2) | No | Base pay rate in USD per linehaul mile | `0.55`, `0.68` |
| `status` | STRING | No | Current operational status (`Active`, `Terminated`, `Leave`) | `Active` |

---

### 3.2 `trucks.csv` (Dimension)
* **Grain:** 1 row per Class-8 tractor asset.
* **Volume:** 120 rows.

| Column | Type | Nullable | Description | Sample Values |
|:---|:---|:---:|:---|:---|
| `truck_id` | STRING | No | Primary Key: Unique tractor unit number | `TRK00000001` |
| `vin` | STRING | No | 17-character Vehicle Identification Number | `1FTFW1ED4MF...` |
| `make` | STRING | No | Tractor manufacturer brand | `Freightliner`, `Peterbilt` |
| `model` | STRING | No | Tractor model name | `Cascadia`, `579` |
| `year` | INT | No | Manufacture model year (2018-2023) | `2021` |
| `license_plate` | STRING | No | Registered vehicle license plate | `TX-9876-AB` |
| `fuel_type` | STRING | No | Engine fuel type | `Diesel` |
| `assigned_terminal_id` | STRING | No | Home domicile facility (`facilities.facility_id`) | `FAC00000002` |
| `status` | STRING | No | Operational status (`Active`, `Maintenance`, `Retired`) | `Active` |

---

### 3.3 `trailers.csv` (Dimension)
* **Grain:** 1 row per trailing equipment asset.
* **Volume:** 180 rows.

| Column | Type | Nullable | Description | Sample Values |
|:---|:---|:---:|:---|:---|
| `trailer_id` | STRING | No | Primary Key: Unique trailer asset code | `TRL00000001` |
| `trailer_type` | STRING | No | Equipment body type (`Dry Van`, `Reefer`) | `Dry Van`, `Reefer` |
| `length_ft` | INT | No | Exterior trailer length in feet (48 or 53) | `53` |
| `max_weight_lbs` | INT | No | Legal maximum payload weight rating | `45000` |
| `assigned_terminal_id` | STRING | No | Domicile facility (`facilities.facility_id`) | `FAC00000003` |
| `status` | STRING | No | Operational status (`Active`, `Repair`, `Decommissioned`) | `Active` |

---

### 3.4 `customers.csv` (Dimension)
* **Grain:** 1 row per commercial shipper account.
* **Volume:** 200 rows.

| Column | Type | Nullable | Description | Sample Values |
|:---|:---|:---:|:---|:---|
| `customer_id` | STRING | No | Primary Key: Customer account identifier | `CUST00000001` |
| `customer_name` | STRING | No | Legal commercial business entity name | `Acme Logistics Corp` |
| `customer_type` | STRING | No | Contract classification (`Enterprise`, `Mid-Market`, `Broker`) | `Enterprise` |
| `credit_terms_days` | INT | No | Standard net payment terms (15, 30, 45, 60 days) | `30` |
| `primary_freight_type`| STRING | No | Primary commodity handled (`General`, `Retail`, `Refrigerated`) | `General` |
| `account_status` | STRING | No | Current account standing (`Active`, `Suspended`, `Closed`) | `Active` |
| `contract_start_date` | DATE | No | Date commercial relationship commenced | `2021-06-01` |
| `annual_revenue_potential`| DECIMAL(12,2)| No | Annual customer contract forecast in USD | `1500000.00` |

---

### 3.5 `facilities.csv` (Dimension)
* **Grain:** 1 row per logistics facility, terminal, or shipper dock.
* **Volume:** 50 rows.

| Column | Type | Nullable | Description | Sample Values |
|:---|:---|:---:|:---|:---|
| `facility_id` | STRING | No | Primary Key: Facility location code | `FAC00000001` |
| `facility_name` | STRING | No | Operating name of the facility | `Dallas Distribution Hub`|
| `facility_type` | STRING | No | Classification (`Terminal`, `Shipper Dock`, `Cross-Dock`) | `Terminal` |
| `address` | STRING | No | Physical street address | `123 Freight Rd` |
| `city` | STRING | No | Metropolitan city | `Dallas`, `Chicago` |
| `state` | STRING | No | 2-character US state abbreviation | `TX`, `IL`, `GA` |
| `zip_code` | STRING | No | Postal code | `75201` |
| `latitude` | DECIMAL(9,6) | No | GPS latitude coordinate | `32.776664` |
| `longitude` | DECIMAL(9,6) | No | GPS longitude coordinate | `-96.796988` |
| `operating_hours` | STRING | No | Terminal gate operating window | `24/7`, `06:00-22:00` |

---

### 3.6 `routes.csv` (Dimension)
* **Grain:** 1 row per standard linehaul corridor.
* **Volume:** 58 rows.

| Column | Type | Nullable | Description | Sample Values |
|:---|:---|:---:|:---|:---|
| `route_id` | STRING | No | Primary Key: Standardized corridor code | `RTE00000001` |
| `origin_facility_id` | STRING | No | Starting facility (`facilities.facility_id`) | `FAC00000001` |
| `destination_facility_id`| STRING | No | Ending facility (`facilities.facility_id`) | `FAC00000005` |
| `distance_miles` | DECIMAL(7,2) | No | Standard transit distance in miles | `785.40` |
| `estimated_transit_hours`| DECIMAL(5,2)| No | Theoretical linehaul driving duration | `14.50` |
| `base_rate_per_mile` | DECIMAL(5,2) | No | Contract baseline pricing per mile in USD | `2.45` |
| `toll_estimate` | DECIMAL(7,2) | No | Expected turnpike/toll costs in USD | `45.00` |

---

### 3.7 `loads.csv` (Fact - Orders)
* **Grain:** 1 row per booked shipment order.
* **Volume:** 85,410 rows.

| Column | Type | Nullable | Description | Sample Values |
|:---|:---|:---:|:---|:---|
| `load_id` | STRING | No | Primary Key: Shipment order number | `LOAD00000001` |
| `customer_id` | STRING | No | Bill-to shipper account (`customers.customer_id`) | `CUST00000012` |
| `route_id` | STRING | No | Assigned corridor (`routes.route_id`) | `RTE00000003` |
| `load_date` | DATE | No | Date order was placed in system | `2022-01-02` |
| `load_status` | STRING | No | Execution state (`Booked`, `Completed`, `Cancelled`) | `Completed` |
| `weight_lbs` | INT | No | Cargo gross weight in pounds | `38500` |
| `pallet_count` | INT | No | Total palletized freight units | `24` |
| `temperature_controlled`| BOOLEAN | No | Temperature control requirement flag | `false`, `true` |
| `target_temperature_f`| DECIMAL(4,1)| Yes| Target temperature setpoint if reefer | `34.0`, `null` |
| `revenue` | DECIMAL(10,2)| No | Base freight billing charge in USD | `2150.00` |
| `fuel_surcharge` | DECIMAL(8,2) | No | Fuel surcharge adjustment billed in USD | `340.50` |
| `accessorial_charges`| DECIMAL(8,2) | No | Additional accessorial billing (lumper/detention) | `75.00` |

---

### 3.8 `trips.csv` (Fact - Operations)
* **Grain:** 1 row per physical trip dispatch executing a load (1:1 with `loads`).
* **Volume:** 85,410 rows.

| Column | Type | Nullable | Description | Sample Values |
|:---|:---|:---:|:---|:---|
| `trip_id` | STRING | No | Primary Key: Physical trip dispatch code | `TRIP00000001` |
| `load_id` | STRING | No | Associated shipment order (`loads.load_id`) | `LOAD00000001` |
| `driver_id` | STRING | No | Primary assigned driver (`drivers.driver_id`) | `DRV00000045` |
| `truck_id` | STRING | No | Assigned tractor unit (`trucks.truck_id`) | `TRK00000012` |
| `trailer_id` | STRING | No | Assigned trailer unit (`trailers.trailer_id`) | `TRL00000078` |
| `dispatch_date` | DATE | No | Operational dispatch date | `2022-01-03` |
| `start_odometer` | INT | No | Hubodometer reading at trip origin | `145200` |
| `end_odometer` | INT | No | Hubodometer reading at trip destination | `146010` |
| `actual_miles` | DECIMAL(7,2) | No | Total recorded road miles (`end - start`) | `810.00` |
| `empty_miles` | DECIMAL(6,2) | No | Unbilled deadhead repositioning miles | `25.00` |
| `fuel_gallons` | DECIMAL(6,2) | No | Total diesel gallons consumed during trip | `124.50` |
| `driver_pay` | DECIMAL(8,2) | No | Total driver payroll compensation for trip | `445.50` |
| `toll_expenses` | DECIMAL(7,2) | No | Actual incurred electronic toll expense | `42.00` |

---

### 3.9 `delivery_events.csv` (Fact - Milestones)
* **Grain:** 1 row per milestone stop (Exactly 2 stops per load: Pickup and Delivery).
* **Volume:** 170,820 rows ($85,410 \times 2$).

| Column | Type | Nullable | Description | Sample Values |
|:---|:---|:---:|:---|:---|
| `event_id` | STRING | No | Primary Key: Milestone event identifier | `EVT00000001` |
| `load_id` | STRING | No | Associated shipment (`loads.load_id`) | `LOAD00000001` |
| `trip_id` | STRING | No | Associated linehaul trip (`trips.trip_id`) | `TRIP00000001` |
| `facility_id` | STRING | No | Stop facility location (`facilities.facility_id`) | `FAC00000001` |
| `event_type` | STRING | No | Stop milestone classification (`Pickup`, `Delivery`) | `Pickup`, `Delivery` |
| `scheduled_datetime` | TIMESTAMP | No | Contract appointment time | `2022-01-03 08:00:00` |
| `actual_datetime` | TIMESTAMP | No | Actual gate check-in timestamp | `2022-01-03 07:45:00` |
| `appointment_type` | STRING | No | Delivery appointment window (`Strict`, `Window`) | `Strict` |
| `detention_minutes` | INT | No | Billable dock waiting time beyond 2hr threshold | `0`, `45` |
| `on_time` | BOOLEAN | No | Operational on-time compliance flag | `true`, `false` |

---

### 3.10 `fuel_purchases.csv` (Fact - Expenses)
* **Grain:** 1 row per commercial fuel pump transaction.
* **Volume:** 196,442 rows.

| Column | Type | Nullable | Description | Sample Values |
|:---|:---|:---:|:---|:---|
| `fuel_purchase_id` | STRING | No | Primary Key: Fuel invoice record code | `FP00000001` |
| `trip_id` | STRING | No | Associated active trip (`trips.trip_id`) | `TRIP00000001` |
| `truck_id` | STRING | No | Tractor receiving fuel (`trucks.truck_id`) | `TRK00000012` |
| `driver_id` | STRING | No | Authorized driver fueling (`drivers.driver_id`) | `DRV00000045` |
| `purchase_date` | DATE | No | Transaction posting date | `2022-01-03` |
| `location_city` | STRING | No | Travel plaza city location | `Little Rock` |
| `location_state` | STRING | No | 2-character US state | `AR` |
| `gallons` | DECIMAL(6,2) | No | Diesel fuel gallons pumped | `75.50` |
| `price_per_gallon` | DECIMAL(4,3) | No | Pump retail fuel price per gallon | `3.859` |
| `total_cost` | DECIMAL(8,2) | No | Total purchase amount in USD (`gallons * price`) | `291.35` |

---

### 3.11 `maintenance_records.csv` (Fact - Asset Maintenance)
* **Grain:** 1 row per mechanical repair or service order.
* **Volume:** 2,920 rows.

| Column | Type | Nullable | Description | Sample Values |
|:---|:---|:---:|:---|:---|
| `maintenance_id` | STRING | No | Primary Key: Work order number | `MNT00000001` |
| `truck_id` | STRING | No | Serviced tractor (`trucks.truck_id`) | `TRK00000005` |
| `maintenance_date` | DATE | No | Service date | `2022-01-15` |
| `maintenance_type` | STRING | No | Maintenance category (`Scheduled`, `Breakdown`, `Tires`) | `Scheduled` |
| `description` | STRING | No | Work description / diagnosis summary | `PM-A Service & Oil Change`|
| `parts_cost` | DECIMAL(8,2) | No | Parts and supplies invoice total | `350.00` |
| `labor_cost` | DECIMAL(8,2) | No | Mechanic labor invoice total | `240.00` |
| `total_cost` | DECIMAL(8,2) | No | Total repair cost in USD (`parts + labor`) | `590.00` |
| `downtime_hours` | DECIMAL(5,1) | No | Lost operational availability time in hours | `6.5` |
| `performed_by` | STRING | No | Service provider (`Internal Shop`, `Third-Party Dealership`)| `Internal Shop` |

---

### 3.12 `safety_incidents.csv` (Fact - Safety & Risk)
* **Grain:** 1 row per reportable vehicle accident or citation.
* **Volume:** 170 rows.

| Column | Type | Nullable | Description | Sample Values |
|:---|:---|:---:|:---|:---|
| `incident_id` | STRING | No | Primary Key: Incident case number | `INC00000001` |
| `driver_id` | STRING | No | Operating driver involved (`drivers.driver_id`) | `DRV00000018` |
| `truck_id` | STRING | No | Operating tractor involved (`trucks.truck_id`) | `TRK00000022` |
| `load_id` | STRING | Yes| Shipment hauled during incident (`loads.load_id`) | `LOAD00000115` |
| `incident_date` | DATE | No | Date of occurrence | `2022-02-10` |
| `incident_type` | STRING | No | Incident severity (`Accident`, `DOT Citation`, `Cargo Damage`)| `DOT Citation` |
| `severity` | STRING | No | Risk classification level (`Minor`, `Moderate`, `Severe`) | `Minor` |
| `preventable` | BOOLEAN | No | Safety committee preventability verdict | `false`, `true` |
| `cost` | DECIMAL(10,2)| No | Direct equipment/cargo damage & legal fines in USD | `250.00` |
| `insurance_claim_filed`| BOOLEAN | No | Insurance submission indicator | `false` |

---

### 3.13 `driver_monthly_metrics.csv` (Aggregate)
* **Grain:** 1 row per driver per operating calendar month.
* **Volume:** 4,464 rows.

| Column | Type | Nullable | Description | Sample Values |
|:---|:---|:---:|:---|:---|
| `driver_id` | STRING | No | Driver identifier (`drivers.driver_id`) | `DRV00000001` |
| `month` | DATE | No | Performance reporting month (1st of month) | `2022-01-01` |
| `total_loads` | INT | No | Total completed linehaul loads dispatched | `18` |
| `total_miles` | DECIMAL(8,2) | No | Total compensated mileage logged | `12450.00` |
| `on_time_delivery_pct`| DECIMAL(5,2)| No | Driver on-time milestone arrival percentage | `94.50` |
| `mpg` | DECIMAL(4,2) | No | Average fuel economy (Miles Per Gallon) | `6.75` |
| `safety_incidents` | INT | No | Count of reportable safety citations | `0` |
| `total_pay` | DECIMAL(8,2) | No | Total payroll earnings in USD | `6847.50` |

---

### 3.14 `truck_utilization_metrics.csv` (Aggregate)
* **Grain:** 1 row per tractor unit per operating calendar month.
* **Volume:** 3,312 rows.

| Column | Type | Nullable | Description | Sample Values |
|:---|:---|:---:|:---|:---|
| `truck_id` | STRING | No | Tractor unit identifier (`trucks.truck_id`) | `TRK00000001` |
| `month` | DATE | No | Utilization reporting month (1st of month) | `2022-01-01` |
| `total_miles` | DECIMAL(8,2) | No | Total hubodometer linehaul miles logged | `10520.00` |
| `operating_days` | INT | No | Active revenue service days in month | `24` |
| `utilization_pct` | DECIMAL(5,2) | No | Fleet asset utilization percentage | `80.00` |
| `maintenance_events` | INT | No | Number of shop visits in month | `1` |
| `maintenance_cost` | DECIMAL(8,2) | No | Total equipment upkeep cost in USD | `450.00` |
| `downtime_hours` | DECIMAL(5,1) | No | Total out-of-service repair downtime | `8.0` |
