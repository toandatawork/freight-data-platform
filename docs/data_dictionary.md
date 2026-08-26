# 📦 TÀI LIỆU CHI TIẾT CƠ SỞ DỮ LIỆU VẬN HÀNH LOGISTICS (LOGISTICS OPERATIONS DATABASE)

---

## 1. Tổng Quan Về Bộ Dữ Liệu (Dataset Overview)

### 1.1 Ngữ cảnh nghiệp vụ (Business Context)
Bộ dữ liệu mô phỏng toàn bộ chuỗi vận hành hàng ngày của một **Doanh nghiệp Vận tải Đường bộ / Logistics (Truckload Freight Carrier)** quy mô vừa và lớn tại Mỹ trong vòng 3 năm (từ **01/01/2022** đến **31/12/2024**). 

Hệ thống ghi nhận luồng nghiệp vụ khép kín:
1. **Tiếp nhận đơn hàng (Loads):** Khách hàng (`customers`) đặt vận chuyển hàng hóa trên các tuyến đường (`routes`) theo các hình thức hợp đồng (Dedicated, Contract, Spot).
2. **Điều phối & Thực thi (Trips):** Mỗi chuyến đi ghép 1 Lái xe (`drivers`), 1 Đầu kéo (`trucks`), 1 Rơ-moóc (`trailers`) để chở đơn hàng đó.
3. **Theo dõi sự kiện (Delivery Events):** Ghi nhận chi tiết thời gian, địa điểm, sự kiện Lấy hàng (Pickup) và Giao hàng (Delivery) tại các Kho/Trung tâm phân phối (`facilities`), tính toán thời gian chờ đợi (Detention) và tỷ lệ đúng giờ (On-time).
4. **Chi phí & Nhiên liệu (Fuel Purchases):** Theo dõi việc đổ xăng của tài xế theo từng trạm, hóa đơn và thẻ xăng.
5. **Bảo trì & Thiết bị (Maintenance Records):** Quản lý lịch sử bảo dưỡng xe, chi phí nhân công, phụ tùng và thời gian xe ngừng hoạt động (Downtime).
6. **An toàn & Rủi ro (Safety Incidents):** Ghi nhận tai nạn, vi phạm giao thông DOT, thiệt hại hàng hóa/xe và chi phí khiếu nại bảo hiểm.
7. **Báo cáo định kỳ (Aggregated Metrics):** Tổng hợp hiệu suất theo tháng cho từng lái xe (`driver_monthly_metrics`) và từng xe đầu kéo (`truck_utilization_metrics`).

---

### 1.2 Bảng thống kê tổng hợp (Summary of all 14 tables)

| STT | Tên Bảng (File CSV) | Loại Bảng (Data Model) | Số Dòng (Rows) | Khóa Chính (Primary Key) | Mục Đích Lưu Trữ Chính |
|:---:|:---|:---|:---:|:---|:---|
| 1 | `drivers.csv` | **Dimension** | 150 | `driver_id` | Hồ sơ nhân sự, bằng lái, trạng thái hoạt động của tài xế |
| 2 | `trucks.csv` | **Dimension** | 120 | `truck_id` | Quản lý đội xe đầu kéo (thông số, trạng thái, bến đỗ) |
| 3 | `trailers.csv` | **Dimension** | 180 | `trailer_id` | Quản lý rơ-moóc kéo theo (loại thùng khô / lạnh, kích thước) |
| 4 | `customers.csv` | **Dimension** | 200 | `customer_id` | Danh bạ khách hàng, loại hợp đồng, doanh số kỳ vọng |
| 5 | `facilities.csv` | **Dimension** | 50 | `facility_id` | Mạng lưới kho, bãi, trung tâm phân phối, điểm cross-dock |
| 6 | `routes.csv` | **Dimension** | 58 | `route_id` | Danh mục các tuyến đường vận chuyển (cự ly, đơn giá/mile) |
| 7 | `loads.csv` | **Fact (Đơn hàng)** | 85,410 | `load_id` | Chi tiết lô hàng, trọng lượng, số kiện, doanh thu và phụ phí |
| 8 | `trips.csv` | **Fact (Vận hành)** | 85,410 | `trip_id` | Chi tiết chuyến xe thực tế (tài xế, xe, km chạy, xăng tiêu thụ) |
| 9 | `fuel_purchases.csv` | **Fact (Chi phí)** | 196,442 | `fuel_purchase_id` | Lịch sử các lần nạp nhiên liệu dọc đường |
| 10 | `delivery_events.csv` | **Fact (Sự kiện)** | 170,820 | `event_id` | Mốc thời gian Pickup & Delivery, thời gian chờ bốc dỡ |
| 11 | `maintenance_records.csv` | **Fact (Bảo dưỡng)** | 2,920 | `maintenance_id` | Lịch sử sửa chữa, bảo trì xe, chi phí và downtime |
| 12 | `safety_incidents.csv` | **Fact (Sự cố)** | 170 | `incident_id` | Tai nạn, vi phạm luật giao thông, chi phí thiệt hại |
| 13 | `driver_monthly_metrics.csv` | **Aggregate** | 4,464 | `(driver_id, month)` | Báo cáo KPI hiệu suất làm việc của tài xế theo tháng |
| 14 | `truck_utilization_metrics.csv` | **Aggregate** | 3,312 | `(truck_id, month)` | Báo cáo tỷ lệ khai thác và chi phí bảo dưỡng xe theo tháng |

> **Tổng quy mô dữ liệu:** 14 bảng, xấp xỉ **549,536 dòng**.

---

## 2. Sơ Đồ Mối Quan Hệ Giữa Các Bảng (Entity Relationship Diagram - ERD)

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
       │ N                         │                         │
┌──────┴──────────────────────┐    ├────────────┬────────────┤
│   DRIVER_MONTHLY_METRICS    │    │ 1          │ 1          │ 1
└─────────────────────────────┘    │            │            │
                                   │ N          │ N          │ N
┌──────────────┐       N         1 │ ┌──────────┴──────────┐ │ ┌───────────────────┐
│    TRUCKS    ├───────────────────┤ │   FUEL_PURCHASES    │ │ │  SAFETY_INCIDENTS │
└──────┬───────┘                   │ └─────────────────────┘ │ └───────────────────┘
       │ 1                         │                         │
       │ N                         │ 1                       │ 1
┌──────┴──────────────────────┐    │ N                       │ N
│  TRUCK_UTILIZATION_METRICS  │    │ ┌─────────────────────┐ │
└─────────────────────────────┘    └─┤   DELIVERY_EVENTS   ├─┘
                                     └──────────┬──────────┘
┌──────────────┐       N         1              │ N
│   TRAILERS   ├────────────────────────────────┤ 
└──────────────┘                                │ 1
                                     ┌──────────┴──────────┐
                                     │     FACILITIES      │
                                     └─────────────────────┘
```

---

## 3. Chi Tiết Từng Bảng (Data Dictionary Chi Tiết)

---

### 3.1 Bảng `drivers` (Thông tin tài xế)
* **Mục đích:** Lưu trữ hồ sơ nhân viên lái xe, bằng lái thương mại (CDL), trạm công tác chính và kinh nghiệm làm việc.
* **Số trường:** 12 trường
* **Số dòng:** 150 dòng

| Tên trường | Kiểu dữ liệu | Mô tả chi tiết & Ý nghĩa nghiệp vụ | Giá trị mẫu / Miền giá trị |
|:---|:---|:---|:---|
| `driver_id` | STRING (PK) | Mã định danh duy nhất của tài xế | `DRV00001`, `DRV00002` |
| `first_name` | STRING | Tên của tài xế | `Jennifer`, `William` |
| `last_name` | STRING | Họ của tài xế | `Hernandez`, `Martin` |
| `hire_date` | DATE | Ngày tuyển dụng vào công ty | `2014-10-31`, `2020-10-02` |
| `termination_date` | DATE | Ngày nghỉ việc (để trống nếu còn làm việc) | `NULL`, `2023-05-15` |
| `license_number` | STRING | Số bằng lái xe thương mại (CDL Number) | `DL673510887` |
| `license_state` | STRING | Bang cấp bằng lái (Mã bang 2 chữ cái) | `WA`, `GA`, `TX`, `OH` |
| `date_of_birth` | DATE | Ngày tháng năm sinh của tài xế | `1973-11-07` |
| `home_terminal` | STRING | Trạm/bến bãi chính của tài xế | `Denver`, `Columbus`, `Seattle` |
| `employment_status` | STRING | Tình trạng công việc | `Active` (124), `Terminated` (26) |
| `cdl_class` | STRING | Phân hạng bằng lái CDL | `A` (100% tài xế hạng A) |
| `years_experience` | INTEGER | Số năm kinh nghiệm lái xe đường dài | `1` đến `25` năm |

---

### 3.2 Bảng `trucks` (Đội xe đầu kéo)
* **Mục đích:** Quản lý thông số kỹ thuật, số khung (VIN), dung tích bình nhiên liệu và tình trạng vận hành của từng đầu kéo.
* **Số trường:** 11 trường
* **Số dòng:** 120 dòng

| Tên trường | Kiểu dữ liệu | Mô tả chi tiết & Ý nghĩa nghiệp vụ | Giá trị mẫu / Miền giá trị |
|:---|:---|:---|:---|
| `truck_id` | STRING (PK) | Mã xe đầu kéo | `TRK00001`, `TRK00002` |
| `unit_number` | STRING | Số hiệu xe nội bộ dán trên thân xe | `3463`, `6461` |
| `make` | STRING | Hãng sản xuất xe tải | `Peterbilt`, `Kenworth`, `Freightliner`, `Volvo` |
| `model_year` | INTEGER | Đời xe / Năm sản xuất | `2014` - `2022` |
| `vin` | STRING | Mã định danh xe quốc tế (17 ký tự) | `1VV205190335317039` |
| `acquisition_date` | DATE | Ngày công ty mua hoặc nhận xe | `2017-04-27` |
| `acquisition_mileage` | INTEGER | Số Odometer lúc mua xe (miles) | `18814`, `26795` |
| `fuel_type` | STRING | Loại nhiên liệu xe sử dụng | `Diesel` (100%) |
| `tank_capacity_gallons`| INTEGER | Sức chứa bình dầu (Gallons) | `150`, `200` |
| `status` | STRING | Trạng thái xe hiện tại | `Active` (92), `Maintenance` (15), `Inactive` (13) |
| `home_terminal` | STRING | Bãi xe đỗ chính | `Omaha`, `Seattle`, `Atlanta` |

---

### 3.3 Bảng `trailers` (Đội rơ-moóc / thùng xe)
* **Mục đích:** Quản lý tài sản rơ-moóc (phần thân chứa hàng tách rời đầu kéo), loại thùng (thùng khô hay thùng lạnh) và vị trí hiện tại.
* **Số trường:** 9 trường
* **Số dòng:** 180 dòng

| Tên trường | Kiểu dữ liệu | Mô tả chi tiết & Ý nghĩa nghiệp vụ | Giá trị mẫu / Miền giá trị |
|:---|:---|:---|:---|
| `trailer_id` | STRING (PK) | Mã rơ-moóc | `TRL00001`, `TRL00002` |
| `trailer_number` | STRING | Số hiệu rơ-moóc dán ngoài thùng | `4290`, `8848` |
| `trailer_type` | STRING | Loại thùng xe chứa hàng | `Dry Van` (94 xe), `Refrigerated` (86 xe) |
| `length_feet` | INTEGER | Chiều dài thùng (feet) | `53` feet (tiêu chuẩn chuẩn Mỹ) |
| `model_year` | INTEGER | Năm sản xuất rơ-moóc | `2015` - `2022` |
| `vin` | STRING | Số khung rơ-moóc | `1AV889081755621178` |
| `acquisition_date` | DATE | Ngày mua thùng xe | `2018-05-11` |
| `status` | STRING | Trạng thái thùng xe | `Active` (100%) |
| `current_location` | STRING | Thành phố nơi thùng xe đang ở | `Kansas City`, `Dallas`, `Chicago` |

---

### 3.4 Bảng `customers` (Khách hàng)
* **Mục đích:** Lưu trữ hồ sơ các công ty chủ hàng, loại hợp đồng, thời hạn công nợ và doanh thu kỳ vọng.
* **Số trường:** 8 trường
* **Số dòng:** 200 dòng

| Tên trường | Kiểu dữ liệu | Mô tả chi tiết & Ý nghĩa nghiệp vụ | Giá trị mẫu / Miền giá trị |
|:---|:---|:---|:---|
| `customer_id` | STRING (PK) | Mã khách hàng | `CUST00001`, `CUST00002` |
| `customer_name` | STRING | Tên doanh nghiệp khách hàng | `Metro Wholesale`, `National Retail` |
| `customer_type` | STRING | Loại hợp đồng khách hàng | `Contract` (75), `Dedicated` (62), `Spot` (63) |
| `credit_terms_days` | INTEGER | Thời hạn tín dụng thanh toán (ngày) | `15`, `30`, `45`, `60` ngày |
| `primary_freight_type` | STRING | Ngành hàng / Loại hàng chính của khách | `General`, `Retail`, `Refrigerated`, `Industrial` |
| `account_status` | STRING | Trạng thái tài khoản khách hàng | `Active` (168), `Inactive` (32) |
| `contract_start_date`| DATE | Ngày ký hợp đồng lần đầu | `2020-02-20` |
| `annual_revenue_potential`| FLOAT | Doanh thu ước tính hàng năm (USD) | `$500,000` - `$5,000,000` |

---

### 3.5 Bảng `facilities` (Kho bãi & Trung tâm phân phối)
* **Mục đích:** Địa điểm cơ sở vật chất nơi tiếp nhận, bốc dỡ hàng, chuyển hàng chéo hoặc trạm trung chuyển.
* **Số trường:** 9 trường
* **Số dòng:** 50 dòng

| Tên trường | Kiểu dữ liệu | Mô tả chi tiết & Ý nghĩa nghiệp vụ | Giá trị mẫu / Miền giá trị |
|:---|:---|:---|:---|
| `facility_id` | STRING (PK) | Mã cơ sở | `FAC00001`, `FAC00002` |
| `facility_name` | STRING | Tên cơ sở kho bãi | `Houston Distribution Center`, `Kansas City Hub` |
| `facility_type` | STRING | Loại hình cơ sở | `Cross-Dock` (20), `Distribution Center` (13), `Terminal` (10), `Warehouse` (7) |
| `city` | STRING | Thành phố | `Houston`, `Kansas City`, `Atlanta` |
| `state` | STRING | Bang | `TX`, `MO`, `GA` |
| `latitude` | FLOAT | Vĩ độ địa lý (GPS) | `29.7604` |
| `longitude` | FLOAT | Kinh độ địa lý (GPS) | `-95.3698` |
| `dock_doors` | INTEGER | Số cửa bốc/dỡ container hàng | `10` đến `150` cửa |
| `operating_hours` | STRING | Thời gian mở cửa phục vụ | `24/7`, `7AM-7PM`, `6AM-10PM` |

---

### 3.6 Bảng `routes` (Tuyến đường vận chuyển)
* **Mục đích:** Danh mục các cặp điểm đi - điểm đến chuẩn, cự ly tiêu chuẩn, đơn giá cước cơ bản và thời gian di chuyển dự kiến.
* **Số trường:** 9 trường
* **Số dòng:** 58 dòng

| Tên trường | Kiểu dữ liệu | Mô tả chi tiết & Ý nghĩa nghiệp vụ | Giá trị mẫu / Miền giá trị |
|:---|:---|:---|:---|
| `route_id` | STRING (PK) | Mã tuyến đường | `RTE00001`, `RTE00002` |
| `origin_city` | STRING | Thành phố xuất phát | `Atlanta`, `Chicago`, `Dallas` |
| `origin_state` | STRING | Bang xuất phát | `GA`, `IL`, `TX` |
| `destination_city` | STRING | Thành phố đích đến | `Chicago`, `Miami`, `Los Angeles` |
| `destination_state`| STRING | Bang đích đến | `IL`, `FL`, `CA` |
| `typical_distance_miles`| INTEGER | Khoảng cách đường bộ tiêu chuẩn (miles)| `300` - `2,800` miles |
| `base_rate_per_mile`| FLOAT | Đơn giá cước vận chuyển chuẩn trên 1 mile ($)| `$1.50` - `$2.50` / mile |
| `fuel_surcharge_rate`| FLOAT | Tỷ lệ phụ phí xăng dầu cộng thêm | `0.15` - `0.30` (15% - 30%) |
| `typical_transit_days`| INTEGER | Số ngày di chuyển trung bình theo tiêu chuẩn | `1` đến `5` ngày |

---

### 3.7 Bảng `loads` (Lô hàng / Đơn hàng vận chuyển)
* **Mục đích:** Bản ghi đơn hàng thực tế do khách đặt, thể hiện trọng lượng, doanh thu cước, phụ phí và loại hợp đồng.
* **Số trường:** 12 trường
* **Số dòng:** 85,410 dòng

| Tên trường | Kiểu dữ liệu | Mô tả chi tiết & Ý nghĩa nghiệp vụ | Giá trị mẫu / Miền giá trị |
|:---|:---|:---|:---|
| `load_id` | STRING (PK) | Mã đơn hàng vận chuyển | `LOAD00000001` |
| `customer_id` | STRING (FK) | Mã khách hàng đặt lô hàng này (→ `customers.customer_id`) | `CUST00183` |
| `route_id` | STRING (FK) | Mã tuyến đường vận chuyển (→ `routes.route_id`) | `RTE00019` |
| `load_date` | DATE | Ngày tiếp nhận đơn hàng | `2022-01-01` → `2024-12-31` |
| `load_type` | STRING | Yêu cầu loại thùng chở hàng | `Dry Van` (42,464), `Refrigerated` (42,946) |
| `weight_lbs` | INTEGER | Tổng trọng lượng lô hàng (Pounds) | `10,000` - `45,000` lbs |
| `pieces` | INTEGER | Số lượng kiện hàng / pallet | `5` - `50` kiện |
| `revenue` | FLOAT | Doanh thu cước vận chuyển cơ bản (USD) | `$500.00` - `$8,000.00` |
| `fuel_surcharge` | FLOAT | Tiền phụ phí xăng dầu thu của khách (USD) | Tính theo tỷ lệ cước & giá xăng |
| `accessorial_charges`| FLOAT | Phụ phí dịch vụ phát sinh (phí bốc dỡ, lưu ca...)| `$0`, `$50`, `$100`, `$250`... |
| `load_status` | STRING | Trạng thái đơn hàng | `Completed` (100%) |
| `booking_type` | STRING | Phương thức đặt chuyến | `Dedicated` (42,337), `Contract` (21,545), `Spot` (21,528) |

---

### 3.8 Bảng `trips` (Hành trình chuyến xe thực tế)
* **Mục đích:** Ghi nhận thực tế quá trình lái xe hoàn thành đơn hàng: ghép tài xế, xe tải, rơ-moóc, đo quãng đường thực tế, thời gian di chuyển, lượng dầu tiêu hao và thời gian nổ máy chờ (idle).
* **Số trường:** 12 trường
* **Số dòng:** 85,410 dòng

| Tên trường | Kiểu dữ liệu | Mô tả chi tiết & Ý nghĩa nghiệp vụ | Giá trị mẫu / Miền giá trị |
|:---|:---|:---|:---|
| `trip_id` | STRING (PK) | Mã định danh chuyến xe | `TRIP00000001` |
| `load_id` | STRING (FK) | Mã đơn hàng tương ứng (→ `loads.load_id`, Quan hệ 1:1) | `LOAD00000001` |
| `driver_id` | STRING (FK) | Mã tài xế thực hiện chuyến (→ `drivers.driver_id`) | `DRV00117` |
| `truck_id` | STRING (FK) | Mã xe đầu kéo sử dụng (→ `trucks.truck_id`) | `TRK00035` |
| `trailer_id` | STRING (FK) | Mã rơ-moóc sử dụng (→ `trailers.trailer_id`) | `TRL00167` |
| `dispatch_date` | DATE | Ngày điều xe xuất bến | `2022-01-01` → `2024-12-31` |
| `actual_distance_miles`| FLOAT | Quãng đường thực tế xe đã chạy (miles) | `150.0` - `3,000.0` miles |
| `actual_duration_hours`| FLOAT | Tổng thời gian chạy thực tế trên đường (giờ) | `5.0` - `70.0` hours |
| `fuel_gallons_used` | FLOAT | Tổng số gallons dầu thực tế tiêu thụ | `30.0` - `500.0` gallons |
| `average_mpg` | FLOAT | Hiệu suất tiêu thụ nhiên liệu (Miles Per Gallon) | `5.0` - `8.5` mpg |
| `idle_time_hours` | FLOAT | Thời gian xe nổ máy nhưng đứng yên (giờ chờ đợi)| `1.0` - `15.0` hours |
| `trip_status` | STRING | Trạng thái chuyến đi | `Completed` (100%) |

---

### 3.9 Bảng `fuel_purchases` (Nhật ký mua nhiên liệu)
* **Mục đích:** Ghi nhận từng giao dịch nạp dầu của tài xế dọc đường tại các cây xăng, phục vụ kiểm toán chi phí và đối soát thẻ nhiên liệu.
* **Số trường:** 11 trường
* **Số dòng:** 196,442 dòng (Trung bình ~2.3 lần đổ xăng/chuyến)

| Tên trường | Kiểu dữ liệu | Mô tả chi tiết & Ý nghĩa nghiệp vụ | Giá trị mẫu / Miền giá trị |
|:---|:---|:---|:---|
| `fuel_purchase_id` | STRING (PK) | Mã giao dịch đổ xăng | `FUEL00000001` |
| `trip_id` | STRING (FK) | Thuộc chuyến xe nào (→ `trips.trip_id`) | `TRIP00051284` |
| `truck_id` | STRING (FK) | Xe đầu kéo nào đổ xăng (→ `trucks.truck_id`) | `TRK00045` |
| `driver_id` | STRING (FK) | Tài xế quẹt thẻ (→ `drivers.driver_id`, có thể null)| `DRV00102`, `NULL` |
| `purchase_date` | DATETIME | Thời điểm đổ xăng chính xác | `2023-10-22 05:00:00` |
| `location_city` | STRING | Thành phố trạm xăng | `Columbus`, `Dallas` |
| `location_state` | STRING | Bang trạm xăng | `MN`, `TX`, `OH` |
| `gallons` | FLOAT | Số gallons dầu đã nạp | `50.0` - `200.0` gallons |
| `price_per_gallon` | FLOAT | Đơn giá dầu tại thời điểm mua (USD/gallon) | `$3.00` - `$5.50` / gallon |
| `total_cost` | FLOAT | Tổng số tiền thanh toán (`gallons * price_per_gallon`)| `$150.00` - `$900.00` |
| `fuel_card_number` | STRING | Mã số thẻ đổ xăng công ty cấp | `FC567161` |

---

### 3.10 `delivery_events` (Sự kiện giao nhận & bốc dỡ hàng)
* **Mục đích:** Ghi lại mốc thời gian cụ thể khi tài xế đến lấy hàng (Pickup) và giao hàng (Delivery), đo độ lệch giờ (On-time) và thời gian chờ đợi bốc xếp (Detention).
* **Số trường:** 11 trường
* **Số dòng:** 170,820 dòng (Mỗi đơn hàng luôn có đúng 2 sự kiện: 85,410 Pickup + 85,410 Delivery)

| Tên trường | Kiểu dữ liệu | Mô tả chi tiết & Ý nghĩa nghiệp vụ | Giá trị mẫu / Miền giá trị |
|:---|:---|:---|:---|
| `event_id` | STRING (PK) | Mã sự kiện | `EVT00000001` |
| `load_id` | STRING (FK) | Thuộc đơn hàng nào (→ `loads.load_id`) | `LOAD00000001` |
| `trip_id` | STRING (FK) | Thuộc chuyến đi nào (→ `trips.trip_id`) | `TRIP00000001` |
| `event_type` | STRING | Loại sự kiện giao nhận | `Pickup` (85,410), `Delivery` (85,410) |
| `facility_id` | STRING (FK) | Địa điểm kho/bãi diễn ra sự kiện (→ `facilities.facility_id`)| `FAC00034` |
| `scheduled_datetime` | DATETIME | Thời gian hẹn trước (theo lịch) | `2022-01-01 18:00:00` |
| `actual_datetime` | DATETIME | Thời gian thực tế tài xế đến/hoàn tất | `2022-01-01 20:58:55` |
| `detention_minutes` | INTEGER | Số phút tài xế bị giữ lại chờ bốc dỡ hàng | `0` đến `300+` phút |
| `on_time_flag` | BOOLEAN | Cờ đánh dấu có đúng giờ theo cam kết không | `True` / `False` |
| `location_city` | STRING | Thành phố nơi diễn ra sự kiện | `Houston`, `Detroit` |
| `location_state` | STRING | Bang nơi diễn ra sự kiện | `TX`, `MI` |

---

### 3.11 `maintenance_records` (Lịch sử bảo dưỡng & sửa chữa xe)
* **Mục đích:** Ghi lại mọi lần bảo trì định kỳ, sửa chữa hỏng hóc đột xuất, chi phí nhân công, phụ tùng và số giờ xe phải nằm bãi (Downtime).
* **Số trường:** 12 trường
* **Số dòng:** 2,920 dòng

| Tên trường | Kiểu dữ liệu | Mô tả chi tiết & Ý nghĩa nghiệp vụ | Giá trị mẫu / Miền giá trị |
|:---|:---|:---|:---|
| `maintenance_id` | STRING (PK) | Mã bảo dưỡng | `MAINT00000001` |
| `truck_id` | STRING (FK) | Xe đầu kéo được bảo dưỡng (→ `trucks.truck_id`) | `TRK00085` |
| `maintenance_date` | DATE | Ngày đưa xe vào xưởng | `2022-01-01` → `2024-12-31` |
| `maintenance_type` | STRING | Hạng mục bảo dưỡng / sửa chữa | `Inspection` (432), `Preventive` (422), `Repair` (422), `Engine` (415), `Tire` (414), `Transmission` (411), `Brake` (402) |
| `odometer_reading` | INTEGER | Số miles trên đồng hồ xe tại thời điểm vào xưởng | `50,000` - `600,000` miles |
| `labor_hours` | FLOAT | Số giờ công của thợ máy | `0.5` - `30.0` hours |
| `labor_cost` | FLOAT | Chi phí tiền công thợ (USD) | `$50.00` - `$3,000.00` |
| `parts_cost` | FLOAT | Chi phí mua linh kiện thay thế (USD) | `$0.00` - `$8,000.00` |
| `total_cost` | FLOAT | Tổng chi phí hóa đơn (`labor_cost + parts_cost`) | `$80.00` - `$10,000.00+` |
| `facility_location`| STRING | Địa điểm xưởng bảo dưỡng | `Kansas City`, `Seattle` |
| `downtime_hours` | FLOAT | Số giờ xe phải ngừng hoạt động để sửa chữa | `2.0` - `72.0` hours |
| `service_description`| STRING | Mô tả ngắn nội dung công việc | `Scheduled Tire`, `Emergency Inspection` |

---

### 3.12 `safety_incidents` (Hồ sơ sự cố & tai nạn an toàn)
* **Mục đích:** Ghi nhận mọi sự cố phát sinh trên đường (tai nạn, phạt vi phạm giao thông DOT, hỏng hàng, khiếu nại), trách nhiệm tài xế và số tiền yêu cầu bảo hiểm bồi thường.
* **Số trường:** 15 trường
* **Số dòng:** 170 dòng

| Tên trường | Kiểu dữ liệu | Mô tả chi tiết & Ý nghĩa nghiệp vụ | Giá trị mẫu / Miền giá trị |
|:---|:---|:---|:---|
| `incident_id` | STRING (PK) | Mã sự cố an toàn | `INC00000001` |
| `trip_id` | STRING (FK) | Chuyến xe xảy ra sự cố (→ `trips.trip_id`) | `TRIP00036079` |
| `truck_id` | STRING (FK) | Xe đầu kéo liên quan (→ `trucks.truck_id`) | `TRK00006` |
| `driver_id` | STRING (FK) | Tài xế liên quan (→ `drivers.driver_id`) | `DRV00006` |
| `incident_date` | DATETIME | Ngày giờ xảy ra sự cố | `2023-04-09 14:00:00` |
| `incident_type` | STRING | Phân loại sự cố | `DOT Violation` (39), `Accident` (35), `Equipment Damage` (35), `Customer Complaint` (34), `Moving Violation` (27) |
| `location_city` | STRING | Thành phố nơi xảy ra | `Columbus`, `Dallas` |
| `location_state` | STRING | Bang nơi xảy ra | `PA`, `NC`, `TX` |
| `at_fault_flag` | BOOLEAN | Lái xe của công ty có phải là bên có lỗi không | `True` / `False` |
| `injury_flag` | BOOLEAN | Sự cố có gây thương tích về người không | `True` / `False` |
| `vehicle_damage_cost`| FLOAT | Chi phí thiệt hại sửa chữa xe tải (USD) | `$0.00` - `$50,000.00` |
| `cargo_damage_cost` | FLOAT | Chi phí bồi thường thiệt hại hàng hóa (USD) | `$0.00` - `$40,000.00` |
| `claim_amount` | FLOAT | Tổng số tiền khiếu nại bảo hiểm (USD) | `vehicle_damage + cargo_damage` |
| `preventable_flag` | BOOLEAN | Sự cố này về mặt kỹ năng có phòng tránh được không | `True` / `False` |
| `description` | STRING | Tóm tắt nguyên nhân và diễn biến sự cố | `Severe incident involving equipment/weather` |

---

### 3.13 `driver_monthly_metrics` (Bảng tổng hợp KPI tài xế theo tháng)
* **Mục đích:** Bảng số liệu tổng hợp (pre-aggregated table) tính sẵn năng suất, tổng doanh thu tạo ra, mức tiết kiệm nhiên liệu và tỷ lệ giao hàng đúng hẹn của từng tài xế qua các tháng.
* **Số trường:** 9 trường
* **Số dòng:** 4,464 dòng
* **Khóa chính kết hợp (Composite PK):** `(driver_id, month)`

| Tên trường | Kiểu dữ liệu | Mô tả chi tiết & Ý nghĩa nghiệp vụ | Giá trị mẫu / Miền giá trị |
|:---|:---|:---|:---|
| `driver_id` | STRING (PK, FK)| Mã tài xế (→ `drivers.driver_id`) | `DRV00001` |
| `month` | DATE (PK) | Ngày đầu tiên của tháng thống kê | `2022-01-01`, `2022-02-01` |
| `trips_completed` | INTEGER | Số chuyến xe đã hoàn thành trong tháng | `5` - `35` chuyến |
| `total_miles` | FLOAT | Tổng số miles đã lái trong tháng | `5,000` - `45,000` miles |
| `total_revenue` | FLOAT | Tổng doanh thu mang lại cho công ty trong tháng ($)| `$15,000` - `$100,000+` |
| `average_mpg` | FLOAT | Hiệu suất tiêu thụ nhiên liệu bình quân của tài xế | `5.5` - `7.8` mpg |
| `total_fuel_gallons`| FLOAT | Tổng số gallons dầu đã tiêu hao trong tháng | `1,000` - `6,500` gallons |
| `on_time_delivery_rate`| FLOAT | Tỷ lệ giao hàng đúng giờ trong tháng (0.0 - 1.0) | `0.30` - `0.98` (30% - 98%) |
| `average_idle_hours`| FLOAT | Số giờ xe nổ máy chờ trung bình mỗi chuyến | `2.0` - `10.0` hours |

---

### 3.14 `truck_utilization_metrics` (Bảng tổng hợp hiệu suất xe theo tháng)
* **Mục đích:** Bảng tổng hợp (pre-aggregated table) đo lường hệ số sử dụng tài sản xe tải, chi phí bảo trì và thời gian dừng máy theo tháng.
* **Số trường:** 10 trường
* **Số dòng:** 3,312 dòng
* **Khóa chính kết hợp (Composite PK):** `(truck_id, month)`

| Tên trường | Kiểu dữ liệu | Mô tả chi tiết & Ý nghĩa nghiệp vụ | Giá trị mẫu / Miền giá trị |
|:---|:---|:---|:---|
| `truck_id` | STRING (PK, FK)| Mã xe đầu kéo (→ `trucks.truck_id`) | `TRK00001` |
| `month` | DATE (PK) | Ngày đầu tiên của tháng thống kê | `2022-01-01` |
| `trips_completed` | INTEGER | Số chuyến đi xe đã chạy trong tháng | `5` - `30` chuyến |
| `total_miles` | FLOAT | Tổng số miles xe đã vận hành trong tháng | `8,000` - `45,000` miles |
| `total_revenue` | FLOAT | Tổng doanh thu tạo ra từ xe này trong tháng ($) | `$20,000` - `$95,000` |
| `average_mpg` | FLOAT | Mức tiêu thụ nhiên liệu trung bình của xe | `5.8` - `7.5` mpg |
| `maintenance_events`| INTEGER | Số lần xe phải vào xưởng sửa chữa trong tháng | `0` - `4` lần |
| `maintenance_cost` | FLOAT | Tổng chi phí sửa chữa bảo dưỡng trong tháng ($) | `$0.0` - `$8,000.00` |
| `downtime_hours` | FLOAT | Tổng số giờ xe phải ngừng hoạt động vì bảo dưỡng | `0.0` - `120.0` hours |
| `utilization_rate` | FLOAT | Tỷ lệ thời gian hoạt động hiệu quả của xe (0.0 - 1.0)| `0.50` - `0.98` (50% - 98%) |

---

## 4. Các Trường Hợp Phân Tích & Bài Toán Nghiệp Vụ (Analytical Use Cases)

Bộ dữ liệu này là nền tảng hoàn hảo để xây dựng **Data Pipeline (ETL/ELT)**, **Data Warehouse (Star Schema/Snowflake Schema)** và các **BI Dashboards**:

1. **Phân tích Hiệu Quả Đội Xe (Fleet Utilization & Maintenance Analysis):**
   * Tính chi phí bảo dưỡng trên mỗi mile (`Maintenance Cost per Mile = maintenance_cost / total_miles`).
   * Tương quan giữa tuổi xe (`model_year`), số km đã chạy (`odometer_reading`) với tần suất hỏng hóc và Downtime.
   * Đánh giá thời điểm tối ưu để thanh lý hoặc thay mới xe đầu kéo.

2. **Tối Ưu Hóa Chi Phí Nhiên Liệu (Fuel Efficiency & Cost Management):**
   * Theo dõi biến động giá dầu trung bình theo từng Bang và vùng địa lý.
   * Phát hiện tài xế hoặc xe có chỉ số MPG bất thường hoặc thời gian nổ máy đứng yên (Idle Time) quá cao để đào tạo lại.
   * So sánh tiền phụ phí nhiên liệu thu từ khách (`fuel_surcharge`) với chi phí đổ xăng thực tế (`fuel_purchases.total_cost`) để đánh giá biên lợi nhuận nhiên liệu.

3. **Phân Tích Lợi Nhuận Tuyến Đường (Lane & Route Profitability):**
   * Tính `Net Profit by Route = Revenue - Fuel Cost - Maintenance Cost - Driver Cost`.
   * Nhận diện các tuyến đường "vàng" có tỷ suất sinh lời cao vs các tuyến vận chuyển bù lỗ.

4. **Đánh Giá Chất Lượng Dịch Vụ & Khách Hàng (SLA & Customer Analytics):**
   * Đo lường tỷ lệ đúng giờ (On-Time Pickup / On-Time Delivery) theo từng khách hàng và từng cơ sở kho bãi (`facilities`).
   * Phân tích các kho bãi thường xuyên có thời gian chờ đợi (Detention) cao nhất để áp dụng phụ phí lưu ca (`accessorial_charges`).

5. **Quản Lý An Toàn & Rủi Ro (Safety & Risk Compliance):**
   * Đếm tần suất vi phạm luật giao thông DOT và tai nạn theo từng tài xế.
   * Tính toán tỷ lệ sự cố có thể phòng tránh được (`preventable_flag = True`) và tổng thiệt hại tài chính do sự cố gây ra.

---

## 5. Lưu Ý Về Chất Lượng Dữ Liệu & Data Cleaning (Data Quality Notes)

1. **Giá trị Null / Missing Data:**
   * `drivers.termination_date`: Null đối với tất cả các tài xế đang còn làm việc (`Active`).
   * `fuel_purchases.driver_id`: Có một số giao dịch đổ xăng bị để trống mã tài xế (cần xử lý `LEFT JOIN` hoặc thay thế bằng giá trị mặc định `'UNKNOWN'`).
2. **Tính chất dữ liệu mô phỏng (Synthetic Data Nature):**
   * Toàn bộ 85,410 đơn hàng (`loads`) và chuyến đi (`trips`) đều ở trạng thái `Completed` (không có đơn bị hủy giữa chừng).
   * 100% xe tải trong dataset sử dụng nhiên liệu `Diesel`.
   * 100% tài xế sở hữu bằng lái hạng `A`.
   * Quan hệ giữa `loads` và `trips` là **1:1** (mỗi load được vận chuyển trọn vẹn trong đúng 1 trip).
   * Bảng `fuel_purchases` có một số giao dịch diễn ra vào 2 ngày đầu tháng 01/2025 (kéo dài nhẹ so với mốc 31/12/2024 của bảng trips).
