/*This is a personal project made by Jerris George*/

/*Every year 703 000 people take their own life and there are many more people who attempt suicide. 
Every suicide is a tragedy that affects families, communities and entire countries and has long-lasting effects on the people left behind. 
Suicide occurs throughout the lifespan and was the fourth leading cause of death among 15-29 year-olds globally in 2019.
Suicide does not just occur in high-income countries, but is a global phenomenon in all regions of the world. 
In fact, over 77% of global suicides occurred in low- and middle-income countries in 2019.
Suicide is a serious public health problem; however, suicides are preventable with timely, evidence-based and often low-cost interventions. 
For national responses to be effective, a comprehensive multisectoral suicide prevention strategy is needed.
SOURCE: https://www.who.int/news-room/fact-sheets/detail/suicide */

/*I have created a Microsoft SQL Server Database(WHO_SUICIDES) and a new table(dbo.who_suicide) using data obtained from the WHO. 
I will late use Tableau to create a dashboard which I will publish on Tableau public*/ 

--Basic Exploration of Table: Obtain Row Count
SELECT 
	COUNT(*) row_count 
FROM WHO_SUICIDES.dbo.who_suicide


--Basic Exploration of Table: Obtain first 100 rows
SELECT TOP 100
	*
FROM WHO_SUICIDES.dbo.who_suicide

--Basic Exploration of Table: List of countries in dataset(141 countries or territories located)
SELECT DISTINCT
  country
FROM WHO_SUICIDES.dbo.who_suicide


-- Add new column that will be used to hold values based on age column
ALTER TABLE WHO_SUICIDES.dbo.who_suicide
    ADD [age_category] nvarchar(50);

-- Use update command to add values based on current value in age column. These values can be used to group 	
UPDATE t1
SET [age_category] = (CASE
  WHEN [age] = '55-74 years' THEN 'Senior'
  WHEN [age] = '35-54 years' THEN 'Adult'
  WHEN [age] = '25-34 years' THEN 'Adult'
  WHEN [age] = '75+ years' THEN 'Senior'
  WHEN [age] = '15-24 years' THEN 'Youth'
  WHEN [age] = '5-14 years' THEN 'Children'
  ELSE 'Not Listed'
END)
FROM WHO_SUICIDES.dbo.who_suicide t1;

-- Alter value to be Child instead on Children.
UPDATE WHO_SUICIDES.dbo.who_suicide
SET [age_category] = 'Child'
WHERE [age_category] = 'Children';


-- Drop newly created column if neeed, commenting out but may be used later.
--ALTER TABLE WHO_SUICIDES.dbo.who_suicide
--    DROP COLUMN age_category;


--Basic Exploration of Table: obtain total population by country, year, and gender.
-- result: (141 countries or territories located)
SELECT country
, [year]
, sex
, coalesce(SUM(CAST(population AS BIGINT)),0) as total_population
FROM WHO_SUICIDES.dbo.who_suicide
GROUP BY country, [year], sex
ORDER BY country, [year] asc

--Basic Exploration of Table: obtain total suicides by country, year, and gender.
SELECT country
, [year]
, sex
, coalesce(SUM(CAST(suicides_no AS BIGINT)),0) as total_suicides
FROM WHO_SUICIDES.dbo.who_suicide
GROUP BY country, [year], sex
ORDER BY country, [year] asc

-- Lets look at the suicides  United States
SELECT [year]
, sex
, coalesce(SUM(CAST(suicides_no AS BIGINT)),0) as total_suicides
FROM WHO_SUICIDES.dbo.who_suicide
WHERE country = 'United States of America'
GROUP BY country, [year], sex
ORDER BY country, [year] asc

-- Lets look at the suicides in the United States and obtain the year with the highest suicide number and gender.
-- Results: 2015 and Males.
WITH cte1 AS (
SELECT [year],
sex,
coalesce(SUM(CAST(suicides_no AS BIGINT)),0) as total_suicides
FROM WHO_SUICIDES.dbo.who_suicide
WHERE country = 'United States of America'
GROUP BY country, [year], sex
)
SELECT 
[year],
sex
FROM cte1
GROUP BY [year], sex
HAVING MAX(total_suicides) = (SELECT
MAX(total_suicides)
FROM cte1)

-- country with the most suicides.
-- Results: Russian Federation 1500992
SELECT TOP 1
  country,
  COALESCE(SUM(CAST(suicides_no AS bigint)), 0) AS total_suicides
FROM WHO_SUICIDES.dbo.who_suicide
GROUP BY country
ORDER BY total_suicides DESC

-- Top 5 countries based on suicides
SELECT TOP 5
  country,
  COALESCE(SUM(CAST(suicides_no AS bigint)), 0) AS total_suicides
FROM WHO_SUICIDES.dbo.who_suicide
GROUP BY country
ORDER BY total_suicides DESC

-- Bottom 5 countries based on suicides
SELECT TOP 5
  country,
  COALESCE(SUM(CAST(suicides_no AS bigint)), 0) AS total_suicides
FROM WHO_SUICIDES.dbo.who_suicide
GROUP BY country
ORDER BY total_suicides ASC

-- Lets look at the suicides in the United States by newly created column age_category
SELECT [age_category]
, coalesce(SUM(CAST(suicides_no AS BIGINT)),0) as total_suicides
FROM WHO_SUICIDES.dbo.who_suicide
WHERE country = 'United States of America'
GROUP BY [age_category]
ORDER BY total_suicides asc

-- Lets look at the suicides in Russia by newly created column age_category
SELECT [age_category]
, coalesce(SUM(CAST(suicides_no AS BIGINT)),0) as total_suicides
FROM WHO_SUICIDES.dbo.who_suicide
WHERE country = 'Russian Federation'
GROUP BY [age_category]
ORDER BY total_suicides asc
