-- 03 - PRICE NORMALIZATION
-- Purpose:
-- Standardize listing prices to USD for cross-city
-- price comparisons while preserving the original price.
--
-- The original `price` column remains unchanged.
-- `price_usd` is used for cross-city monetary analysis.
--
-- Exchange rates:
-- 2021 annual-average foreign currency -> USD

USE airbnb;
GO


CREATE OR ALTER VIEW dbo.vw_ListingsStandardized AS

SELECT
    l.*,

    CASE l.city
        WHEN 'Paris' THEN l.price * 1.1830
        WHEN 'New York' THEN l.price * 1.0000
        WHEN 'Sydney' THEN l.price * 0.7515
        WHEN 'Rome' THEN l.price * 1.1830
        WHEN 'Rio de Janeiro' THEN l.price / 5.3958
        WHEN 'Istanbul' THEN l.price / 8.904
        WHEN 'Mexico City' THEN l.price / 20.2844
        WHEN 'Bangkok' THEN l.price / 32.0052
        WHEN 'Cape Town' THEN l.price / 14.7751
        WHEN 'Hong Kong' THEN l.price / 7.7727
        ELSE NULL
    END AS price_usd

FROM dbo.Listings AS l;
GO


-- Test the new view
SELECT TOP 20
    listing_id,
    city,
    price,
    price_usd
FROM dbo.vw_ListingsStandardized;



-- Validate that every city has a conversion
SELECT
    city,
    COUNT(*) AS listings,
    COUNT(price_usd) AS converted_prices,
    COUNT(*) - COUNT(price_usd) AS missing_price_usd
FROM dbo.vw_ListingsStandardized
GROUP BY city
ORDER BY city;



-- Check the USD averages
SELECT DISTINCT
    city,
    ROUND(
        AVG(price_usd) OVER (PARTITION BY city),
        2
    ) AS avg_price_usd,
    ROUND(
        PERCENTILE_CONT(0.50)
        WITHIN GROUP (ORDER BY price_usd)
        OVER (PARTITION BY city),
        2
    ) AS median_price_usd
FROM dbo.vw_ListingsStandardized
WHERE price > 0
ORDER BY avg_price_usd DESC;