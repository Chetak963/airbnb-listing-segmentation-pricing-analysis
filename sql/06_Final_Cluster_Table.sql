-- 05 - FINAL CLUSTER TABLE

USE airbnb;
GO

-- CREATE FINAL TABLE

IF OBJECT_ID('dbo.AirbnbFinal', 'U') IS NOT NULL
    DROP TABLE dbo.AirbnbFinal;
GO

CREATE TABLE dbo.AirbnbFinal
(
    listing_id BIGINT,
    name NVARCHAR(500),
    city NVARCHAR(100),
    neighbourhood NVARCHAR(200),
    room_type NVARCHAR(100),
    property_type NVARCHAR(200),

    price DECIMAL(18,2),
    price_usd DECIMAL(18,2),
    price_vs_city_median DECIMAL(18,4),

    accommodates INT,
    bedrooms INT,
    minimum_nights INT,

    review_scores_rating DECIMAL(5,2),
    total_reviews INT,

    host_is_superhost CHAR(1),
    host_tenure_years INT,
    host_total_listings_count INT,

    review_status NVARCHAR(50),

    final_cluster INT,
    final_cluster_name NVARCHAR(100)
);
GO

-- IMPORT FINAL PYTHON CLUSTERING RESULTS

BULK INSERT dbo.AirbnbFinal
FROM 'E:\All\Data Analysis\Projects\Airbnb\final_airbnb_clusters.csv'
WITH
(
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDQUOTE = '"',
    CODEPAGE = '65001',
    TABLOCK
);
GO

-- VALIDATION

SELECT COUNT(*) AS total_listings
FROM dbo.AirbnbFinal;

SELECT COUNT(DISTINCT listing_id) AS unique_listings
FROM dbo.AirbnbFinal;

SELECT COUNT(*) AS missing_listing_id
FROM dbo.AirbnbFinal
WHERE listing_id IS NULL;

SELECT COUNT(*) AS missing_cluster
FROM dbo.AirbnbFinal
WHERE final_cluster IS NULL
   OR final_cluster_name IS NULL;

-- CLUSTER DISTRIBUTION

SELECT
    final_cluster,
    final_cluster_name,
    COUNT(*) AS listings,
    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (),
        2
    ) AS listing_percentage
FROM dbo.AirbnbFinal
GROUP BY
    final_cluster,
    final_cluster_name
ORDER BY listings DESC;

-- CLUSTER PROFILE

SELECT
    final_cluster_name,
    COUNT(*) AS listings,
    ROUND(AVG(price_usd), 2) AS avg_price_usd,
    ROUND(AVG(review_scores_rating), 2) AS avg_rating,
    ROUND(AVG(total_reviews), 2) AS avg_reviews,
    ROUND(AVG(accommodates), 2) AS avg_accommodates,
    ROUND(AVG(minimum_nights), 2) AS avg_minimum_nights
FROM dbo.AirbnbFinal
WHERE price_usd > 0
GROUP BY final_cluster_name
ORDER BY listings DESC;