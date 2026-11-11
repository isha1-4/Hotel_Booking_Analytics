
CREATE OR REFRESH MATERIALIZED VIEW gold_data_quality AS

WITH bronze_metrics AS (
    SELECT
        COUNT(*) AS bronze_rows,
        COUNT(DISTINCT booking_id) AS unique_booking_ids,

        SUM(CASE
            WHEN check_out_date <= check_in_date THEN 1
            ELSE 0
        END) AS invalid_date_rows,

        SUM(CASE
            WHEN room_rate < 0 THEN 1
            ELSE 0
        END) AS negative_rate_rows,

        SUM(CASE
            WHEN city IS NULL OR TRIM(city) = '' THEN 1
            ELSE 0
        END) AS missing_city_rows,

        SUM(CASE
            WHEN booking_channel IS NULL OR TRIM(booking_channel) = '' THEN 1
            ELSE 0
        END) AS missing_channel_rows,

        SUM(CASE
            WHEN total_amount IS NULL THEN 1
            ELSE 0
        END) AS missing_amount_rows,

        SUM(CASE
            WHEN nights IS NULL THEN 1
            ELSE 0
        END) AS missing_nights_rows

    FROM bronze_hotel_bookings
),

clean_metrics AS (
    SELECT COUNT(*) AS clean_rows
    FROM silver_bookings_clean
),

rejected_metrics AS (
    SELECT COUNT(*) AS rejected_rows
    FROM silver_bookings_rejected
)

SELECT
    b.bronze_rows,
    b.bronze_rows - b.unique_booking_ids AS duplicate_rows,
    b.invalid_date_rows,
    b.negative_rate_rows,
    b.missing_city_rows,
    b.missing_channel_rows,
    b.missing_amount_rows,
    b.missing_nights_rows,
    c.clean_rows,
    r.rejected_rows,

    b.bronze_rows -
    (c.clean_rows + r.rejected_rows +
     (b.bronze_rows - b.unique_booking_ids))
    AS reconciliation_difference

FROM bronze_metrics b
CROSS JOIN clean_metrics c
CROSS JOIN rejected_metrics r;
