CREATE SCHEMA IF NOT EXISTS oltp;

CREATE TABLE oltp.customers (
    customer_id                text PRIMARY KEY,
    customer_name               text,
    customer_type                text,
    credit_terms_days           numeric,
    primary_freight_type        text,
    account_status               text,
    contract_start_date         date,
    annual_revenue_potential     numeric
);

CREATE TABLE oltp.trucks (
    truck_id                    text PRIMARY KEY,
    unit_number                  text,
    make                         text,
    model_year                   numeric,
    vin                          text,
    acquisition_date             date,
    acquisition_mileage          numeric,
    fuel_type                    text,
    tank_capacity_gallons        numeric,
    status                       text,
    home_terminal                text
);

CREATE TABLE oltp.trailers (
    trailer_id                  text PRIMARY KEY,
    trailer_number                text,
    trailer_type                 text,
    length_feet                  numeric,
    model_year                   numeric,
    vin                          text,
    acquisition_date             date,
    status                       text,
    current_location             text
);

CREATE TABLE oltp.facilities (
    facility_id                 text PRIMARY KEY,
    facility_name                 text,
    facility_type                 text,
    city                          text,
    state                         text,
    latitude                      numeric,
    longitude                     numeric,
    dock_doors                    numeric,
    operating_hours               text
);

CREATE TABLE oltp.routes (
    route_id                     text PRIMARY KEY,
    origin_city                    text,
    origin_state                   text,
    destination_city               text,
    destination_state              text,
    typical_distance_miles          numeric,
    base_rate_per_mile               numeric,
    fuel_surcharge_rate               numeric,
    typical_transit_days              numeric
);

CREATE TABLE oltp.drivers (
    driver_id                    text PRIMARY KEY,
    first_name                    text,
    last_name                     text,
    hire_date                     date,
    termination_date              date,   
    license_number                 text,
    license_state                  text,
    date_of_birth                  date,
    home_terminal                  text,
    employment_status              text,
    cdl_class                      text,
    years_experience                numeric
);


CREATE TABLE oltp.loads (
    load_id                       text PRIMARY KEY,
    customer_id                    text,
    route_id                       text,
    load_date                     date,
    load_type                      text,
    weight_lbs                     numeric,
    pieces                         numeric,
    revenue                        numeric,
    fuel_surcharge                  numeric,
    accessorial_charges              numeric,
    load_status                    text,
    booking_type                   text
);


CREATE TABLE oltp.trips (
    trip_id                       text PRIMARY KEY,
    load_id                        text,
    driver_id                      text,
    truck_id                       text,
    trailer_id                     text,
    dispatch_date                  date,
    actual_distance_miles            numeric,
    actual_duration_hours             numeric,
    fuel_gallons_used                numeric,
    average_mpg                     numeric,
    idle_time_hours                  numeric,
    trip_status                    text
);

CREATE TABLE oltp.fuel_purchases (
    fuel_purchase_id               text PRIMARY KEY,
    trip_id                        text,
    truck_id                       text,
    driver_id                      text,
    purchase_date                  timestamp,
    location_city                   text,
    location_state                  text,
    gallons                        numeric,
    price_per_gallon                numeric,
    total_cost                     numeric,
    fuel_card_number                text
);

CREATE TABLE oltp.maintenance_records (
    maintenance_id                 text PRIMARY KEY,
    truck_id                       text,
    maintenance_date                date,
    maintenance_type                text,
    odometer_reading                numeric,
    labor_hours                    numeric,
    labor_cost                     numeric,
    parts_cost                     numeric,
    total_cost                     numeric,
    facility_location                text,
    downtime_hours                  numeric,
    service_description              text
);


CREATE TABLE oltp.delivery_events (
    event_id                       text PRIMARY KEY,
    load_id                        text,
    trip_id                        text,
    event_type                     text,
    facility_id                    text,
    scheduled_datetime               timestamp,
    actual_datetime                 timestamp,
    detention_minutes                numeric,
    on_time_flag                   text,   
    location_city                   text,
    location_state                  text
);

CREATE TABLE oltp.safety_incidents (
    incident_id                    text PRIMARY KEY,
    trip_id                        text,
    truck_id                       text,
    driver_id                      text,
    incident_date                   timestamp,
    incident_type                   text,
    location_city                   text,
    location_state                  text,
    at_fault_flag                   text,
    injury_flag                     text,
    vehicle_damage_cost              numeric,
    cargo_damage_cost                numeric,
    claim_amount                    numeric,
    preventable_flag                 text,
    description                    text
);


CREATE TABLE oltp.driver_monthly_metrics (
    driver_id                    text,
    month                         date,
    trips_completed                numeric,
    total_miles                    numeric,
    total_revenue                  numeric,
    average_mpg                    numeric,
    total_fuel_gallons              numeric,
    on_time_delivery_rate            numeric,
    average_idle_hours              numeric,
    PRIMARY KEY (driver_id, month)
);

CREATE TABLE oltp.truck_utilization_metrics (
    truck_id                     text,
    month                         date,
    trips_completed                numeric,
    total_miles                    numeric,
    total_revenue                  numeric,
    average_mpg                    numeric,
    maintenance_events               numeric,
    maintenance_cost                numeric,
    downtime_hours                  numeric,
    utilization_rate                numeric,
    PRIMARY KEY (truck_id, month)
);

CREATE INDEX IF NOT EXISTS idx_loads_load_date            ON oltp.loads (load_date);
CREATE INDEX IF NOT EXISTS idx_delivery_events_actual_dt   ON oltp.delivery_events (actual_datetime);
CREATE INDEX IF NOT EXISTS idx_fuel_purchases_purchase_dt  ON oltp.fuel_purchases (purchase_date);
CREATE INDEX IF NOT EXISTS idx_trips_dispatch_date         ON oltp.trips (dispatch_date);