CREATE DATABASE customerdata;
USE customerdata;

SELECT * FROM finaldataset;

-- QUESTION 1: Who are the genuinely loyal customers vs. those who only buy when there is a discount? What separates high-value customers from low-value customers?

SELECT COUNT(*) AS total_rows
FROM finaldataset;

SELECT `Customer Segment`,
    COUNT(*) AS total_customers,
    ROUND(AVG(`CLV Proxy`),2) AS avg_clv,
    ROUND(AVG(`Purchase Amount (USD)`),2) AS avg_purchase_amount,
    ROUND(AVG(`Previous Purchases`),2) AS avg_previous_purchases,
    ROUND(AVG(`Frequency of Purchases`),2) AS avg_purchase_frequency,
    ROUND(AVG(`Loyalty Score`),2) AS avg_loyalty_score,
    ROUND(AVG(`Promo Dependency`),2) AS avg_promo_dependency,
    ROUND(AVG(`Review Rating`),2) AS avg_review_rating,
    ROUND(AVG(`Age`),2) AS avg_age,
	ROUND(SUM(CASE WHEN `Gender` = 'Female' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),1) AS female_percentage
FROM finaldataset
GROUP BY `Customer Segment`
ORDER BY avg_clv DESC;

-- QUESTION 1 (PART B): Which profiles show the strongest repeat purchase behaviour?
-- Previous Purchases >= Third Quantile (38)
-- Frequency >= Third Quantile (6)
-- Promo Dependency = 0

SELECT f1.`Customer Segment`,
    (SELECT COUNT(*)FROM finaldataset f2 WHERE f2.`Customer Segment` = f1.`Customer Segment`) AS total_customers,
    COUNT(*) AS strong_repeat_customers,
    ROUND(COUNT(*) * 100.0 /(SELECT COUNT(*) FROM finaldataset f2 WHERE f2.`Customer Segment` = f1.`Customer Segment`),2) AS strong_repeat_rate
FROM finaldataset f1
WHERE `Previous Purchases` >= 38 AND `Frequency of Purchases` >= 6 AND `Promo Dependency` = 0
GROUP BY `Customer Segment`
ORDER BY strong_repeat_rate DESC;

-- QUESTION 3: Which geographies signal organic demand versus discount-driven volume?

SELECT Location,
    ROUND(AVG(`Loyalty Score`),2) AS avg_loyalty,
    ROUND(AVG(`Promo Dependency`),2) AS avg_promo_dependency,
    ROUND(AVG(`CLV Proxy`),2) AS avg_clv,
    CASE
        WHEN AVG(`Loyalty Score`) >
             (SELECT AVG(`Loyalty Score`) FROM finaldataset)
         AND AVG(`Promo Dependency`) <
             (SELECT AVG(`Promo Dependency`) FROM finaldataset)
        THEN 'Organic Demand'
        WHEN AVG(`Loyalty Score`) <
             (SELECT AVG(`Loyalty Score`) FROM finaldataset)
         AND AVG(`Promo Dependency`) >
             (SELECT AVG(`Promo Dependency`) FROM finaldataset)
        THEN 'Discount-Driven Volume'
        ELSE 'Mixed'
    END AS geography_type
FROM finaldataset
GROUP BY Location;


-- QUESTION 3: Which demographics are commercially underlevered?

-- Gender Analysis

SELECT Gender,
    COUNT(*) AS customers,
    ROUND(COUNT(*) * 100.0 /(SELECT COUNT(*) FROM finaldataset),2) AS customer_share_pct,
    ROUND(AVG(`CLV Proxy`),2) AS avg_clv,
    ROUND(AVG(`Loyalty Score`),2) AS avg_loyalty,
    ROUND(AVG(`Promo Dependency`),2) AS avg_promo_dependency
FROM finaldataset
GROUP BY Gender
ORDER BY avg_clv DESC;

-- Age Group Analysis

SELECT
    CASE
        WHEN Age < 30 THEN '18-29'
		WHEN Age < 45 THEN '30-44'
		WHEN Age < 60 THEN '45-59'
		ELSE '60+'
		END AS age_group,
    COUNT(*) AS customers,
    ROUND(COUNT(*) * 100.0 /(SELECT COUNT(*) FROM finaldataset),2) AS customer_share_pct,
    ROUND(AVG(`CLV Proxy`),2) AS avg_clv,
    ROUND(AVG(`Loyalty Score`),2) AS avg_loyalty,
    ROUND(AVG(`Promo Dependency`),2) AS avg_promo_dependency
FROM finaldataset
GROUP BY age_group
ORDER BY avg_clv DESC;

-- QUESTION 5: Ideal Customer Profile

SELECT
    COUNT(*) AS customers,
    ROUND(AVG(Age),2) AS avg_age,
    ROUND(AVG(`Purchase Amount (USD)`),2) AS avg_purchase_amount,
    ROUND(AVG(`CLV Proxy`),2) AS avg_clv,
    ROUND(AVG(`Previous Purchases`),2) AS avg_previous_purchases,
    ROUND(AVG(`Frequency of Purchases`),2) AS avg_purchase_frequency,
    ROUND(AVG(`Loyalty Score`),2) AS avg_loyalty_score,
    ROUND(AVG(`Promo Dependency`),2) AS avg_promo_dependency,
    ROUND(AVG(`Review Rating`),2) AS avg_review_rating
FROM finaldataset
WHERE `Customer Segment` = 'Platinum Champions';

SELECT
    CASE
        WHEN Age < 30 THEN '18-29'
		WHEN Age < 45 THEN '30-44'
		WHEN Age < 60 THEN '45-59'
		ELSE '60+'
    END AS age_bracket, Gender, Location,
    COUNT(*) AS customers,
    ROUND(AVG(`CLV Proxy`),2) AS avg_clv,
    ROUND(AVG(`Loyalty Score`),2) AS avg_loyalty
FROM finaldataset
WHERE `Customer Segment` = 'Platinum Champions' AND `Loyalty Score` > (SELECT AVG(`Loyalty Score`) FROM finaldataset WHERE `Customer Segment` = 'Platinum Champions')
GROUP BY age_bracket, Gender, Location
ORDER BY avg_loyalty DESC, avg_clv DESC, customers DESC
LIMIT 10;

-- ROUGH 
SELECT
    Category,
    COUNT(*) AS customers,
    ROUND(AVG(`Purchase Amount (USD)`),2) AS avg_purchase_amount,
    ROUND(AVG(`Previous Purchases`),2) AS avg_previous_purchases,
    ROUND(AVG(`Frequency of Purchases`),2) AS avg_purchase_frequency,
    ROUND(AVG(`Loyalty Score`),2) AS avg_loyalty_score,
    ROUND(AVG(`CLV Proxy`),2) AS avg_clv,
    ROUND(AVG(`Promo Dependency`),2) AS avg_promo_dependency,
    ROUND(AVG(`Review Rating`),2) AS avg_review_rating
FROM finaldataset
GROUP BY Category
ORDER BY avg_clv DESC;