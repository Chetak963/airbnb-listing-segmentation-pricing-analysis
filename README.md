# Airbnb Listing Segmentation & Pricing Analysis

An end-to-end data analytics and machine learning project that analyzes Airbnb listings and review activity across multiple international cities, standardizes pricing information, segments listings using K-Means clustering, and presents the results through an interactive Power BI dashboard.

The project combines **SQL Server, Python, Scikit-learn, and Power BI** to build a complete analytical workflow from raw data preparation to machine-learning-based segmentation and business reporting.

---

## 📊 Dashboard

![Airbnb Listing Analysis Dashboard](screenshots/Dashboard.png)

The Power BI dashboard provides an interactive view of:

- Listing distribution across segments
- Average price by city in USD
- Median price by listing segment
- Average reviews by segment
- Average rating by segment
- Guest capacity by segment
- Minimum stay requirements
- City-level filtering
- Segment-level comparison

---

## 🎯 Project Overview

Airbnb listings can differ significantly in terms of pricing, property size, guest capacity, minimum stay requirements, review activity, ratings, and host characteristics.

The dataset also contains listings from multiple cities using different local currencies. Therefore, directly comparing raw prices across cities can produce misleading conclusions.

This project addresses these challenges by:

1. Performing data-quality validation.
2. Exploring listing and review characteristics.
3. Standardizing prices into USD for cross-city reporting.
4. Creating a city-relative pricing feature for machine learning.
5. Engineering features related to listings, reviews, properties, and hosts.
6. Applying K-Means clustering to segment Airbnb listings.
7. Profiling and interpreting the resulting segments.
8. Loading the final analytical dataset back into SQL Server.
9. Building an interactive Power BI dashboard.

---

# 🎯 Objectives

The main objectives of this project are:

- Analyze Airbnb listing characteristics across multiple cities.
- Validate and clean the raw listing and review data.
- Identify pricing patterns and extreme-price listings.
- Standardize prices for cross-city comparison.
- Develop a city-relative pricing measure.
- Identify meaningful listing segments using unsupervised machine learning.
- Profile the characteristics of each segment.
- Build a reusable analytical dataset in SQL Server.
- Create an interactive Power BI dashboard for business analysis.

---

# 🗂️ Dataset

The project uses two primary datasets.

## Listings Dataset

The listings dataset contains approximately **279,712 listings** and includes information related to:

- Listing information
- Host information
- Host verification
- Host response and acceptance rates
- Location
- Property type
- Room type
- Guest capacity
- Bedrooms
- Pricing
- Minimum and maximum nights
- Review scores
- Booking characteristics

## Reviews Dataset

The reviews dataset contains approximately **5.37 million review records**.

Relevant fields include:

- Listing ID
- Review ID
- Review date
- Reviewer ID

### Raw Data Availability

The original raw `Listings.csv` and `Reviews.csv` files are not included in this repository because of their large size.

The project does include the final analytical clustering dataset:

```text
Data/final_airbnb_clusters.csv
