
-- 1. MONTHLY BOOKINGS SUMMARY

CREATE OR REFRESH MATERIALIZED VIEW gold_monthly_bookings AS

SELECT
    DATE_FORMAT(booking_date, 'yyyy-MM') AS booking_month,
    COUNT(*) AS total_bookings,

    SUM(CASE
        WHEN booking_status = 'Cancelled' THEN 1
        ELSE 0
    END) AS cancelled_bookings,

    SUM(CASE
        WHEN booking_status = 'Completed' THEN nights
        ELSE 0
    END) AS room_nights,

    SUM(CASE
        WHEN booking_status = 'Completed'
        THEN COALESCE(total_amount, 0) - COALESCE(discount_amount, 0)
        ELSE 0
    END) AS net_revenue

FROM silver_bookings_clean
GROUP BY DATE_FORMAT(booking_date, 'yyyy-MM');


-- 2. HOTEL SUMMARY

CREATE OR REFRESH MATERIALIZED VIEW gold_hotel_summary AS

SELECT
    region,
    city,
    hotel_name,
    COUNT(*) AS total_bookings,

    SUM(CASE
        WHEN booking_status = 'Completed' THEN nights
        ELSE 0
    END) AS room_nights,

    SUM(CASE
        WHEN booking_status = 'Completed'
        THEN COALESCE(total_amount, 0) - COALESCE(discount_amount, 0)
        ELSE 0
    END) AS net_revenue,

    CASE
        WHEN SUM(CASE
            WHEN booking_status = 'Completed' THEN nights
            ELSE 0
        END) = 0 THEN 0
        ELSE
            SUM(CASE
                WHEN booking_status = 'Completed'
                THEN COALESCE(total_amount, 0) - COALESCE(discount_amount, 0)
                ELSE 0
            END)
            /
            SUM(CASE
                WHEN booking_status = 'Completed' THEN nights
                ELSE 0
            END)
    END AS avg_daily_rate

FROM silver_bookings_clean
GROUP BY region, city, hotel_name;


-- 3. ROOM TYPE SUMMARY

CREATE OR REFRESH MATERIALIZED VIEW gold_room_type_summary AS

SELECT
    room_type,
    COUNT(*) AS total_bookings,

    SUM(CASE
        WHEN booking_status = 'Completed' THEN nights
        ELSE 0
    END) AS room_nights,

    SUM(CASE
        WHEN booking_status = 'Completed'
        THEN COALESCE(total_amount, 0) - COALESCE(discount_amount, 0)
        ELSE 0
    END) AS net_revenue,

    AVG(guest_rating) AS avg_rating

FROM silver_bookings_clean
GROUP BY room_type;


-- 4. BOOKING CHANNEL SUMMARY

CREATE OR REFRESH MATERIALIZED VIEW gold_channel_summary AS

SELECT
    booking_channel,
    COUNT(*) AS total_bookings,

    SUM(CASE
        WHEN booking_status = 'Cancelled' THEN 1
        ELSE 0
    END) AS cancelled_bookings,

    ROUND(
        100.0 * SUM(CASE
            WHEN booking_status = 'Cancelled' THEN 1
            ELSE 0
        END) / COUNT(*),
        2
    ) AS cancellation_rate_pct,

    SUM(CASE
        WHEN booking_status = 'Completed'
        THEN COALESCE(total_amount, 0) - COALESCE(discount_amount, 0)
        ELSE 0
    END) AS net_revenue

FROM silver_bookings_clean
GROUP BY booking_channel;
