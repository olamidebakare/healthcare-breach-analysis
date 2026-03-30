-- ============================================================
-- US Healthcare Data Breach Analysis — SQL Queries
-- Author: Olamide Bakare | Data Engineer & Data Governance Specialist
-- ============================================================

-- 1. Total breaches and individuals affected per year
SELECT 
    Year,
    COUNT(*) AS total_breaches,
    SUM(Individuals_Affected) AS total_individuals,
    AVG(Individuals_Affected) AS avg_breach_size,
    MAX(Individuals_Affected) AS largest_breach
FROM healthcare_breaches
GROUP BY Year
ORDER BY Year;

-- 2. Breach type breakdown by year (shows shift toward hacking)
SELECT 
    Year,
    Type_of_Breach,
    COUNT(*) AS breach_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY Year), 1) AS pct_of_year
FROM healthcare_breaches
GROUP BY Year, Type_of_Breach
ORDER BY Year, breach_count DESC;

-- 3. Top 10 states by total breaches
SELECT 
    State,
    COUNT(*) AS total_breaches,
    SUM(Individuals_Affected) AS total_individuals,
    ROUND(AVG(Days_to_Report), 0) AS avg_days_to_report
FROM healthcare_breaches
GROUP BY State
ORDER BY total_breaches DESC
LIMIT 10;

-- 4. Entity type analysis
SELECT 
    Covered_Entity_Type,
    COUNT(*) AS total_breaches,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM healthcare_breaches), 1) AS pct_of_total,
    SUM(Individuals_Affected) AS total_individuals,
    ROUND(AVG(Individuals_Affected), 0) AS avg_breach_size
FROM healthcare_breaches
GROUP BY Covered_Entity_Type
ORDER BY total_breaches DESC;

-- 5. HIPAA compliance check: breaches reported after 60-day window
SELECT 
    Year,
    COUNT(*) AS total_breaches,
    SUM(CASE WHEN Days_to_Report > 60 THEN 1 ELSE 0 END) AS late_reports,
    ROUND(SUM(CASE WHEN Days_to_Report > 60 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS pct_late
FROM healthcare_breaches
GROUP BY Year
ORDER BY Year;

-- 6. Largest breaches (top 20)
SELECT 
    Name_of_Covered_Entity,
    State,
    Covered_Entity_Type,
    Type_of_Breach,
    Individuals_Affected,
    Breach_Date,
    Days_to_Report
FROM healthcare_breaches
ORDER BY Individuals_Affected DESC
LIMIT 20;

-- 7. Monthly trend analysis
SELECT 
    Year,
    MONTH(Breach_Date) AS breach_month,
    COUNT(*) AS breach_count
FROM healthcare_breaches
GROUP BY Year, MONTH(Breach_Date)
ORDER BY Year, breach_month;

-- 8. Network server vs other locations — governance insight
SELECT 
    Location_of_Breached_Information,
    COUNT(*) AS breach_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM healthcare_breaches), 1) AS pct_of_total,
    SUM(Individuals_Affected) AS total_individuals
FROM healthcare_breaches
GROUP BY Location_of_Breached_Information
ORDER BY breach_count DESC;

-- 9. Year-over-year growth rate
SELECT 
    Year,
    COUNT(*) AS breaches,
    LAG(COUNT(*)) OVER (ORDER BY Year) AS prev_year,
    ROUND((COUNT(*) - LAG(COUNT(*)) OVER (ORDER BY Year)) * 100.0 
        / LAG(COUNT(*)) OVER (ORDER BY Year), 1) AS yoy_growth_pct
FROM healthcare_breaches
GROUP BY Year
ORDER BY Year;

-- 10. Business associate breach analysis (third-party governance)
SELECT 
    Year,
    COUNT(*) AS ba_breaches,
    SUM(Individuals_Affected) AS ba_individuals,
    ROUND(COUNT(*) * 100.0 / (
        SELECT COUNT(*) FROM healthcare_breaches hb2 WHERE hb2.Year = healthcare_breaches.Year
    ), 1) AS pct_of_year
FROM healthcare_breaches
WHERE Covered_Entity_Type = 'Business Associate'
GROUP BY Year
ORDER BY Year;
