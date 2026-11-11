
-- SILVER CLEAN TABLE

CREATE OR REFRESH MATERIALIZED VIEW silver_bookings_clean AS

SELECT
    booking_id,
    guest_id,
    booking_date,
    check_in_date,
    check_out_date,
    COALESCE(nights, DATEDIFF(check_out_date, check_in_date)) AS nights,
    INITCAP(TRIM(hotel_name)) AS hotel_name,
    COALESCE(NULLIF(INITCAP(TRIM(city)), ''), 'Unknown') AS city,
    INITCAP(TRIM(region)) AS region,
    INITCAP(TRIM(room_type)) AS room_type,
    COALESCE(NULLIF(INITCAP(TRIM(booking_channel)), ''), 'Unknown') AS booking_channel,
    guests,
    room_rate,
    COALESCE(
        total_amount,
        DATEDIFF(check_out_date, check_in_date) * room_rate
    ) AS total_amount,
    discount_amount,
    INITCAP(TRIM(meal_plan)) AS meal_plan,
    INITCAP(TRIM(payment_method)) AS payment_method,
    INITCAP(TRIM(payment_status)) AS payment_status,
    INITCAP(TRIM(booking_status)) AS booking_status,
    guest_rating,
    source_file,
    loaded_at

FROM (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY booking_id
            ORDER BY loaded_at DESC
        ) AS rn
    FROM bronze_hotel_bookings
)

WHERE rn = 1
  AND check_out_date > check_in_date
  AND (room_rate IS NULL OR room_rate >= 0);


-- SILVER REJECTED TABLE

CREATE OR REFRESH MATERIALIZED VIEW silver_bookings_rejected AS

SELECT
    booking_id,
    guest_id,
    booking_date,
    check_in_date,
    check_out_date,
    hotel_name,
    city,
    room_rate,
    booking_status,

    CASE
        WHEN check_out_date <= check_in_date
            THEN 'Invalid check-in/check-out dates'
        WHEN room_rate < 0
            THEN 'Negative room rate'
    END AS reject_reason

FROM (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY booking_id
            ORDER BY loaded_at DESC
        ) AS rn
    FROM bronze_hotel_bookings
)

WHERE rn = 1
  AND (
      check_out_date <= check_in_date
      OR room_rate < 0
  );
  
