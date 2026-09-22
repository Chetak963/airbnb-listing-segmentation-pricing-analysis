-- 06 - DASHBOARD VIEWS
-- Purpose: Create SQL views used by Power BI

USE airbnb;
GO

-- 1. LISTING-LEVEL DASHBOARD VIEW

CREATE OR ALTER VIEW dbo.vw_AirbnbDashboard AS
SELECT
    listing_id,
    name,
    city,
    neighbourhood,
    room_type,
    property_type,

    price,
    price_usd,
    price_vs_city_median,

    accommodates,
    bedrooms,
    minimum_nights,

    review_scores_rating,
    total_reviews,

    host_is_superhost,
    host_tenure_years,
    host_total_listings_count,

    review_status,

    final_cluster,
    final_cluster_name

FROM dbo.AirbnbFinal;
GO


-- 2. CLUSTER-LEVEL SUMMARY

CREATE OR ALTER VIEW dbo.vw_ClusterSummary AS
SELECT
    final_cluster,
    final_cluster_name,

    COUNT(*) AS listings,

    ROUND(AVG(price_usd), 2) AS avg_price_usd,

    ROUND(AVG(review_scores_rating), 2) AS avg_rating,

    ROUND(AVG(total_reviews), 2) AS avg_reviews,

    ROUND(AVG(accommodates), 2) AS avg_accommodates,

    ROUND(AVG(minimum_nights), 2) AS avg_minimum_nights

FROM dbo.AirbnbFinal

WHERE price_usd > 0

GROUP BY
    final_cluster,
    final_cluster_name;
GO


-- 3. CITY-LEVEL SUMMARY

CREATE OR ALTER VIEW dbo.vw_CitySummary AS
SELECT
    city,

    COUNT(*) AS listings,

    ROUND(AVG(price_usd), 2) AS avg_price_usd,

    ROUND(AVG(review_scores_rating), 2) AS avg_rating,

    ROUND(AVG(total_reviews), 2) AS avg_reviews

FROM dbo.AirbnbFinal

WHERE price_usd > 0

GROUP BY city;
GO