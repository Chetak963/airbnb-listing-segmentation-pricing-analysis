-- 01 - DATA IMPORT
-- Purpose: Create raw tables and import Airbnb CSV files

USE airbnb;
GO


-- 1. Create Listings table

IF OBJECT_ID('dbo.Listings', 'U') IS NOT NULL
    DROP TABLE dbo.Listings;
GO

CREATE TABLE dbo.Listings
(
    listing_id BIGINT NOT NULL,
    name NVARCHAR(MAX),
    host_id BIGINT NOT NULL,
    host_since DATE,
    host_location NVARCHAR(MAX),

    host_response_time NVARCHAR(100),
    host_response_rate DECIMAL(5,2),
    host_acceptance_rate DECIMAL(5,2),

    host_is_superhost CHAR(1),
    host_total_listings_count INT,

    host_has_profile_pic CHAR(1),
    host_identity_verified CHAR(1),

    neighbourhood NVARCHAR(MAX),
    district NVARCHAR(MAX),
    city NVARCHAR(MAX),

    latitude DECIMAL(10,7),
    longitude DECIMAL(10,7),

    property_type NVARCHAR(MAX),
    room_type NVARCHAR(100),

    accommodates INT,
    bedrooms INT,

    amenities NVARCHAR(MAX),

    price DECIMAL(12,2),

    minimum_nights INT,
    maximum_nights INT,

    review_scores_rating DECIMAL(5,2),
    review_scores_accuracy DECIMAL(5,2),
    review_scores_cleanliness DECIMAL(5,2),
    review_scores_checkin DECIMAL(5,2),
    review_scores_communication DECIMAL(5,2),
    review_scores_location DECIMAL(5,2),
    review_scores_value DECIMAL(5,2),

    instant_bookable CHAR(1)
);
GO


-- 2. Import Listings

BULK INSERT dbo.Listings
FROM 'E:\All\Data Analysis\Projects\Airbnb\Listings.csv'
WITH
(
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDQUOTE = '"',
    CODEPAGE = '65001',
    TABLOCK
);
GO


-- 3. Create Reviews table

IF OBJECT_ID('dbo.Reviews', 'U') IS NOT NULL
    DROP TABLE dbo.Reviews;
GO

CREATE TABLE dbo.Reviews
(
    listing_id BIGINT NOT NULL,
    review_id BIGINT NOT NULL,
    date DATE,
    reviewer_id BIGINT
);
GO


-- 4. Import Reviews

BULK INSERT dbo.Reviews
FROM 'E:\All\Data Analysis\Projects\Airbnb\Reviews.csv'
WITH
(
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDQUOTE = '"',
    CODEPAGE = '65001',
    TABLOCK
);
GO


-- 5. Basic import verification

SELECT COUNT(*) AS total_listings
FROM dbo.Listings;

SELECT COUNT(*) AS total_reviews
FROM dbo.Reviews;