-- 02 - DATA QUALITY CHECKS
-- Purpose: Validate duplicates, missing values,
--          invalid values, and table relationships

USE airbnb;
GO


-- 1. Duplicate Listings

SELECT
    listing_id,
    COUNT(*) AS duplicate_count
FROM dbo.Listings
GROUP BY listing_id
HAVING COUNT(*) > 1;


-- 2. Missing Critical Listing Fields

SELECT
    COUNT(*) AS total_rows,

    SUM(CASE
        WHEN listing_id IS NULL THEN 1
        ELSE 0
    END) AS missing_listing_id,

    SUM(CASE
        WHEN host_id IS NULL THEN 1
        ELSE 0
    END) AS missing_host_id,

    SUM(CASE
        WHEN price IS NULL THEN 1
        ELSE 0
    END) AS missing_price,

    SUM(CASE
        WHEN city IS NULL THEN 1
        ELSE 0
    END) AS missing_city

FROM dbo.Listings;


-- 3. Invalid Prices

SELECT
    COUNT(*) AS invalid_price_rows
FROM dbo.Listings
WHERE price <= 0;


-- 4. Invalid Accommodation Values

SELECT
    COUNT(*) AS invalid_accommodates
FROM dbo.Listings
WHERE accommodates <= 0;


-- 5. Invalid Minimum Nights

SELECT
    COUNT(*) AS invalid_minimum_nights
FROM dbo.Listings
WHERE minimum_nights <= 0;


-- 6. Missing Critical Review Fields

SELECT
    COUNT(*) AS total_rows,

    SUM(CASE
        WHEN listing_id IS NULL THEN 1
        ELSE 0
    END) AS missing_listing_id,

    SUM(CASE
        WHEN review_id IS NULL THEN 1
        ELSE 0
    END) AS missing_review_id,

    SUM(CASE
        WHEN date IS NULL THEN 1
        ELSE 0
    END) AS missing_date

FROM dbo.Reviews;


-- 7. Review ID Uniqueness

-- review_id is not globally unique.
-- Validate uniqueness using the composite key:
-- (listing_id, review_id)

SELECT
    listing_id,
    review_id,
    COUNT(*) AS duplicate_count
FROM dbo.Reviews
GROUP BY
    listing_id,
    review_id
HAVING COUNT(*) > 1;


-- 8. Review-to-Listing Relationship

-- Check for reviews referencing a listing
-- that does not exist in Listings.

SELECT
    COUNT(DISTINCT r.listing_id) AS orphan_review_listing_ids
FROM dbo.Reviews AS r
LEFT JOIN dbo.Listings AS l
    ON r.listing_id = l.listing_id
WHERE l.listing_id IS NULL;


-- 9. Review Coverage

SELECT
    COUNT(DISTINCT r.listing_id) AS listings_with_reviews,
    COUNT(DISTINCT l.listing_id) AS total_listings
FROM dbo.Listings AS l
LEFT JOIN dbo.Reviews AS r
    ON l.listing_id = r.listing_id;

    