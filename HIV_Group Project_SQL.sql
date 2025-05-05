DROP DATABASE IF EXISTS sanikayn_edx;
CREATE database sanikayn_edx;

CREATE TABLE country_info (
    Country VARCHAR(100),
    Year INT,
    Country_Population INT,
    GDP_per_capita DECIMAL(15, 2),
    Unemployment_rate DECIMAL(10, 2),
    School_enrollment_rate DECIMAL(10, 2)
);
LOAD DATA LOCAL INFILE 'C:/Users/sanik/OneDrive/Documents/Sanika/NEU/ITC6000/HIV Group Project/country_info (1).csv'
INTO TABLE country_info
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    Country,
    Year,
    Country_Population,
    GDP_per_capita,
    unemployment_rate,
    School_enrollment_rate
);
SELECT * FROM country_info LIMIT 10;

DROP TABLE dohmh_hiv_aids_annual_report;
CREATE TABLE dohmh_hiv_aids_annual_report (
    Year INT,
    Borough VARCHAR(50),
    UHF VARCHAR(50),
    Gender VARCHAR(20),
    Age VARCHAR(50),
    Race VARCHAR(50),
    HIV_diagnoses DECIMAL(10, 2),
    HIV_diagnosis_rate DECIMAL(10, 2),
    Concurrent_diagnoses DECIMAL(10, 2),
    Linked_to_care_within_3_months DECIMAL(10, 2),
    AIDS_diagnoses DECIMAL(10, 2),
    AIDS_diagnosis_rate DECIMAL(10, 2),
    PLWDHI_prevalence DECIMAL(10, 2),
    Viral_suppression DECIMAL(10, 2),
    Deaths INT,
    Death_rate DECIMAL(10, 2),
    HIV_related_death_rate DECIMAL(10, 2),
    Non_HIV_related_death_rate DECIMAL(10, 2)
);



DROP TABLE hiv_early_infant_diagnosis;
CREATE TABLE hiv_early_infant_diagnosis (
    ISO3 CHAR(3),
    Type VARCHAR(50),
    Country_Region VARCHAR(100),
    UNICEF_Region VARCHAR(100),
    Indicator TEXT,
    Data_source TEXT,
    Year INT,
    Value DECIMAL(10, 2),
    Lower VARCHAR(50),
    Upper VARCHAR(50)
);
LOAD DATA LOCAL INFILE 'C:/Users/sanik/OneDrive/Documents/Sanika/NEU/ITC6000/HIV Group Project/HIV_Early_Infant_Diagnosis_2024 (2).csv'
INTO TABLE hiv_early_infant_diagnosis
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
SELECT * FROM hiv_early_infant_diagnosis LIMIT 10;

CREATE TABLE hiv_epidemiology_children_adolescents (
    ISO3 CHAR(3),
    Type VARCHAR(50),
    Country_Region VARCHAR(100),
    UNICEF_Region VARCHAR(100),
    Indicator TEXT,
    Data_source TEXT,
    Year INT,
    Sex VARCHAR(10),
    Age VARCHAR(50),
    Value VARCHAR(50),
    Lower VARCHAR(50),
    Upper VARCHAR(50)
);
LOAD DATA LOCAL INFILE 'C:/Users/sanik/OneDrive/Documents/Sanika/NEU/ITC6000/HIV Group Project/HIV_Epidemiology_Children_Adolescents_2024 (1).csv'
INTO TABLE hiv_epidemiology_children_adolescents
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
SELECT * FROM hiv_epidemiology_children_adolescents LIMIT 10;

CREATE TABLE hiv_discrimination (
    iso3 CHAR(3),                              
    country VARCHAR(100),                      
    unicef_region VARCHAR(100),                
    indicator TEXT,                            
    data_source TEXT,                          
    year INT,                                  
    sex VARCHAR(10),                           
    age VARCHAR(20),                           
    disagg_category VARCHAR(50),              
    disagg VARCHAR(100),                       
    value DECIMAL(10, 2)                       
);
LOAD DATA LOCAL INFILE 'C:/Users/sanik/OneDrive/Documents/Sanika/NEU/ITC6000/HIV Group Project/HIV_Discrimination_2024 (1).csv'
INTO TABLE hiv_discrimination
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
SELECT * FROM hiv_discrimination LIMIT 10;

-- estimated number of people living with HIV 
SELECT 
    Year,
    SUM(PLWDHI_prevalence) AS estimated_number_of_people_living_with_hiv
FROM dohmh_hiv_aids_annual_report
WHERE PLWDHI_prevalence IS NOT NULL
GROUP BY Year
ORDER BY Year;

-- Total deaths dues to HIV by year 
SELECT 
    Year,
    SUM(HIV_related_death_rate) AS total_hiv_related_deaths
FROM dohmh_hiv_aids_annual_report
WHERE HIV_related_death_rate IS NOT NULL
GROUP BY Year
ORDER BY Year;

-- total deaths due to HIV across broughts and years 
SELECT 
    Year,
    Borough,
    SUM(HIV_related_death_rate) AS total_hiv_related_deaths
FROM dohmh_hiv_aids_annual_report
WHERE HIV_related_death_rate IS NOT NULL
GROUP BY Year, Borough
ORDER BY Year, Borough;


-- preparing table 1 - table schema
DROP TABLE hiv_summary;
CREATE TABLE hiv_summary (
    Year INT,
    Country VARCHAR(100),
    Estimated_people_living_with_HIV DECIMAL(15, 2),
    Estimated_deaths_due_to_HIV DECIMAL(15, 2),
    Estimated_women_15_and_older_living_with_HIV DECIMAL(15, 2),
    Percent_pregnant_women_with_known_HIV_status DECIMAL(10, 2),
    Final_mother_to_child_transmission_rate DECIMAL(10, 2)
);

-- Estimated Number of People Living with HIV data comes from the hiv_epidemiology table
SELECT 
    Year,
    Country_Region AS Country,
    SUM(CAST(REPLACE(Value, ',', '') AS DECIMAL(15, 2))) AS Estimated_people_living_with_HIV
FROM hiv_epidemiology_children_adolescents
WHERE Indicator = 'Estimated number of people living with HIV'
  AND Year BETWEEN 2007 AND 2016
  AND Value REGEXP '^[0-9,.]+$'
GROUP BY Year, Country;

-- estimated number of deaths due to HIV 
SELECT 
    Year,
    Borough AS Country,
    SUM(Deaths) AS Estimated_deaths_due_to_HIV
FROM dohmh_hiv_aids_annual_report
WHERE Year BETWEEN 2007 AND 2016
GROUP BY Year, Borough;

-- estimanted number of women living with HIV with age more than 15 
SELECT 
    Year,
    SUM(PLWDHI_prevalence) AS estimated_number_of_women_living_with_hiv
FROM dohmh_hiv_aids_annual_report
WHERE Gender = 'Female'
  AND (
      Age = '18-29' OR 
      Age = '30-39' OR 
      Age = '40-49' OR 
      Age = '50-59' OR 
      Age = '60+'
  )
  AND PLWDHI_prevalence IS NOT NULL
GROUP BY Year
ORDER BY Year;

-- Percent (%) of Pregnant Women with Known HIV Status
SELECT 
    Year,
    Country_Region AS Country,
    AVG(CAST(REPLACE(Value, ',', '') AS DECIMAL(10, 2))) AS Percent_pregnant_women_with_known_HIV_status
FROM hiv_anc_testing
WHERE Indicator = 'Percentage of pregnant women with known HIV status'
  AND Year BETWEEN 2007 AND 2016
  AND Value REGEXP '^[0-9,.]+$'
GROUP BY Year, Country;

-- Mother-to-Child Transmission Rate Including Breastfeeding Period
SELECT 
    Year,
    Country_Region AS Country,
    AVG(CAST(REPLACE(Value, ',', '') AS DECIMAL(10, 2))) AS Final_mother_to_child_transmission_rate
FROM hiv_early_infant_diagnosis
WHERE Indicator = 'Final mother-to-child transmission rate (including breastfeeding)'
  AND Year BETWEEN 2007 AND 2016
  AND Value REGEXP '^[0-9,.]+$'
GROUP BY Year, Country;

SELECT Value
FROM hiv_epidemiology_children_adolescents
WHERE Indicator = 'Estimated number of people living with HIV'
  AND (Value IS NULL OR Value NOT REGEXP '^[0-9,.]+$');
SELECT Value
FROM hiv_anc_testing
WHERE Indicator = 'Percentage of pregnant women with known HIV status'
  AND (Value IS NULL OR Value NOT REGEXP '^[0-9,.]+$');
SELECT Value
FROM hiv_early_infant_diagnosis
WHERE Indicator = 'Final mother-to-child transmission rate (including breastfeeding)'
  AND (Value IS NULL OR Value NOT REGEXP '^[0-9,.]+$');

INSERT INTO hiv_summary (Year, Country, Estimated_people_living_with_HIV, Estimated_deaths_due_to_HIV, Estimated_women_15_and_older_living_with_HIV, Percent_pregnant_women_with_known_HIV_status, Final_mother_to_child_transmission_rate)
SELECT 
    people.Year,
    people.Country,
    people.Estimated_people_living_with_HIV,
    deaths.Estimated_deaths_due_to_HIV,
    women.estimated_number_of_women_living_with_hiv,
    pregnant.Percent_pregnant_women_with_known_HIV_status,
    transmission.Final_mother_to_child_transmission_rate
FROM 
    (SELECT 
        Year,
        Country_Region AS Country,
        SUM(CAST(REPLACE(Value, ',', '') AS DECIMAL(15, 2))) AS Estimated_people_living_with_HIV
     FROM hiv_epidemiology_children_adolescents
     WHERE Indicator = 'Estimated number of people living with HIV'
       AND Year BETWEEN 2007 AND 2016
       AND Value REGEXP '^[0-9,.]+$'
     GROUP BY Year, Country
    ) people
LEFT JOIN 
    (SELECT 
        Year,
        Borough AS Country,
        SUM(Deaths) AS Estimated_deaths_due_to_HIV
     FROM dohmh_hiv_aids_annual_report
     WHERE Year BETWEEN 2007 AND 2016
     GROUP BY Year, Borough
    ) deaths ON people.Year = deaths.Year AND people.Country = deaths.Country
LEFT JOIN 
    (SELECT 
        Year,
        SUM(PLWDHI_prevalence) AS estimated_number_of_women_living_with_hiv
     FROM dohmh_hiv_aids_annual_report
     WHERE Gender = 'Female'
       AND (Age IN ('18-29', '30-39', '40-49', '50-59', '60+'))
       AND PLWDHI_prevalence IS NOT NULL
     GROUP BY Year
    ) women ON people.Year = women.Year
LEFT JOIN 
    (SELECT 
        Year,
        Country_Region AS Country,
        AVG(CAST(REPLACE(Value, ',', '') AS DECIMAL(10, 2))) AS Percent_pregnant_women_with_known_HIV_status
     FROM hiv_anc_testing
     WHERE Indicator = 'Percentage of pregnant women with known HIV status'
       AND Year BETWEEN 2007 AND 2016
       AND Value REGEXP '^[0-9,.]+$'
     GROUP BY Year, Country
    ) pregnant ON people.Year = pregnant.Year AND people.Country = pregnant.Country
LEFT JOIN 
    (SELECT 
        Year,
        Country_Region AS Country,
        AVG(CAST(REPLACE(Value, ',', '') AS DECIMAL(10, 2))) AS Final_mother_to_child_transmission_rate
     FROM hiv_early_infant_diagnosis
     WHERE Indicator = 'Final mother-to-child transmission rate (including breastfeeding)'
       AND Year BETWEEN 2007 AND 2016
       AND Value REGEXP '^[0-9,.]+$'
     GROUP BY Year, Country
    ) transmission ON people.Year = transmission.Year AND people.Country = transmission.Country;
SELECT * FROM hiv_summary;

-- performance indicators (KPIs)
-- KPI: Average Discriminatory Attitude Rate by Age Group
SELECT 
    Country,
    Age,
    AVG(Value) AS avg_discriminatory_attitude_rate
FROM hiv_discrimination
WHERE Indicator = 'Percentage with discriminatory attitudes towards people living with HIV'
AND Country = 'Bangladesh'
GROUP BY Country, Age
ORDER BY Country, avg_discriminatory_attitude_rate DESC;

-- KPI: Discriminatory Attitude Rate by Education Level
SELECT 
    Country,
    DISAGG AS education_level,
    AVG(Value) AS avg_discriminatory_attitude_rate
FROM hiv_discrimination
WHERE Indicator = 'Percentage with discriminatory attitudes towards people living with HIV'
AND Country = 'Bangladesh'
  AND DISAGG_CATEGORY = 'education'
GROUP BY Country, education_level
ORDER BY Country, avg_discriminatory_attitude_rate DESC;

-- combine the tables 
SELECT 
    d.Country,
    d.Age,
    AVG(d.Value) AS avg_discriminatory_attitude_by_age,
    e.DISAGG AS education_level,
    AVG(e.Value) AS avg_discriminatory_attitude_by_education
FROM hiv_discrimination d
LEFT JOIN hiv_discrimination e
ON d.Country = e.Country
   AND d.Year = e.Year
WHERE d.Indicator = 'Percentage with discriminatory attitudes towards people living with HIV'
  AND d.Country = 'Bangladesh'
  AND e.DISAGG_CATEGORY = 'education'
GROUP BY d.Country, d.Age, e.DISAGG
ORDER BY avg_discriminatory_attitude_by_age DESC
LIMIT 50000;

-- GDP table 
CREATE TABLE country_statistics (
    Country VARCHAR(100),
    Year INT,
    Country_Population INT,
    GDP_per_capita DECIMAL(15, 2),
    Unemployment_rate DECIMAL(10, 2)
);

INSERT INTO country_statistics (Country, Year, Country_Population, GDP_per_capita, Unemployment_rate)
SELECT 
    Country,
    Year,
    Country_Population,
    CAST(REPLACE(GDP_per_capita, ',', '') AS DECIMAL(15, 2)) AS GDP_per_capita,
    CAST(REPLACE(unemployment_rate, ',', '') AS DECIMAL(10, 2)) AS Unemployment_rate
FROM country_info
WHERE Country_Population IS NOT NULL
  AND GDP_per_capita IS NOT NULL
  AND unemployment_rate IS NOT NULL;
SELECT * FROM country_statistics;

-- combining table 1 and 2 
SELECT 
    h.Year,
    h.Country,
    h.Estimated_people_living_with_HIV,
    c.Country_Population,
    (h.Estimated_people_living_with_HIV / c.Country_Population) * 100 AS HIV_population_percentage
FROM hiv_summary h
INNER JOIN country_statistics c
ON h.Country = c.Country AND h.Year = c.Year
WHERE h.Estimated_people_living_with_HIV IS NOT NULL
  AND c.Country_Population IS NOT NULL
ORDER BY h.Country, h.Year;








  
  












