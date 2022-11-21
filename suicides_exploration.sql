/*Every year 703 000 people take their own life and there are many more people who attempt suicide. 
Every suicide is a tragedy that affects families, communities and entire countries and has long-lasting effects on the people left behind. 
Suicide occurs throughout the lifespan and was the fourth leading cause of death among 15-29 year-olds globally in 2019.
Suicide does not just occur in high-income countries, but is a global phenomenon in all regions of the world. 
In fact, over 77% of global suicides occurred in low- and middle-income countries in 2019.
Suicide is a serious public health problem; however, suicides are preventable with timely, evidence-based and often low-cost interventions. 
For national responses to be effective, a comprehensive multisectoral suicide prevention strategy is needed.
SOURCE: https://www.who.int/news-room/fact-sheets/detail/suicide */

--Basic Exploration of Table: Obtain Row Count
SELECT
  COUNT(*) row_count
FROM WHO_SUICIDES.dbo.who_suicide


--Basic Exploration of Table: Obtain first row
SELECT TOP 100
  *
FROM WHO_SUICIDES.dbo.who_suicide

-- I would like to check columns for missing values(NULLS)
-- We see that suicides_no column is the only column with missing values, we can explore this some more later.
SELECT
  COUNT([country])
FROM WHO_SUICIDES.dbo.who_suicide
WHERE [country] = '';

SELECT
  COUNT([year])
FROM WHO_SUICIDES.dbo.who_suicide
WHERE [year] = '';

SELECT
  COUNT([sex])
FROM WHO_SUICIDES.dbo.who_suicide
WHERE [sex] = '';

SELECT
  COUNT([age])
FROM WHO_SUICIDES.dbo.who_suicide
WHERE [age] = '';

SELECT
  COUNT([suicides_no])
FROM WHO_SUICIDES.dbo.who_suicide
WHERE [suicides_no] = '';

SELECT
  COUNT([population])
FROM WHO_SUICIDES.dbo.who_suicide
WHERE [population] = '';


--Basic Exploration of Table: List of countries in dataset(141 countries or territories located)
SELECT DISTINCT
  country
FROM WHO_SUICIDES.dbo.who_suicide
ORDER BY country


-- Change some of the country names
UPDATE WHO_SUICIDES.dbo.who_suicide
SET [country] = 'Cape Verde'
WHERE [country] = 'Cabo Verde'

UPDATE WHO_SUICIDES.dbo.who_suicide
SET [country] = 'Brunei'
WHERE [country] = 'Brunei Darussalam'

UPDATE WHO_SUICIDES.dbo.who_suicide
SET [country] = 'Iran'
WHERE [country] = 'Iran (Islamic Rep of)'

UPDATE WHO_SUICIDES.dbo.who_suicide
SET [country] = 'Venezuela'
WHERE [country] = 'Venezuela (Bolivarian Republic of)'

UPDATE WHO_SUICIDES.dbo.who_suicide
SET [country] = 'Macedonia'
WHERE [country] = 'TFYR Macedonia'

UPDATE WHO_SUICIDES.dbo.who_suicide
SET [country] = 'Syria'
WHERE [country] = 'Syrian Arab Republic'

UPDATE WHO_SUICIDES.dbo.who_suicide
SET [country] = 'Saint Vincent and the Grenadines'
WHERE [country] = 'Saint Vincent and Grenadines'

UPDATE WHO_SUICIDES.dbo.who_suicide
SET [country] = 'Korea, South'
WHERE [country] = 'Republic of Korea'

-- Perform validation of changes 1st looking for previous values
-- No results found
SELECT DISTINCT
  [country]
FROM WHO_SUICIDES.[dbo].[who_suicide]
WHERE [country] IN ('Republic of Korea',
'Saint Vincent and Grenadines',
'Syrian Arab Republic', 'TFYR Macedonia',
'Venezuela (Bolivarian Republic of)',
'Iran (Islamic Rep of)', 'Brunei Darussalam', 'Cabo Verde')

-- Perform validation of changes 2nd looking for new values
-- 8 results found
SELECT DISTINCT
  [country]
FROM WHO_SUICIDES.[dbo].[who_suicide]
WHERE [country] IN ('Korea, South',
'Saint Vincent and the Grenadines',
'Syria', 'Macedonia', 'Venezuela',
'Iran', 'Brunei', 'Cape Verde')

--Basic Exploration of Table: obtain total population by country all genders (141 countries or territories located)
--SELECT country
--, [year]
--, coalesce(SUM(CAST(population AS BIGINT)),0) as total_population
--FROM WHO_SUICIDES.dbo.who_suicide
--GROUP BY country, [year]
--ORDER BY country, [year] asc

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

-- View unique values newly created age_category column
SELECT DISTINCT
  [age_category]
FROM WHO_SUICIDES.[dbo].[who_suicide]


-- Drop newly created column if neeed, commenting out but may be used later.
--ALTER TABLE WHO_SUICIDES.dbo.who_suicide
--    DROP COLUMN age_category;


--Basic Exploration of Table: obtain total population by country and genders (141 countries or territories located)
SELECT
  country,
  [year],
  sex,
  COALESCE(SUM(CAST(population AS bigint)), 0) AS total_population
FROM WHO_SUICIDES.dbo.who_suicide
GROUP BY country,
         [year],
         sex
ORDER BY country, [year] ASC

--Basic Exploration of Table: obtain total suicides by country and genders (141 countries or territories located)
SELECT
  country,
  [year],
  sex,
  COALESCE(SUM(CAST(suicides_no AS bigint)), 0) AS total_suicides
FROM WHO_SUICIDES.dbo.who_suicide
GROUP BY country,
         [year],
         sex
ORDER BY country, [year] ASC

-- Lets look at the suicides  United States
SELECT
  [year],
  sex,
  COALESCE(SUM(CAST(suicides_no AS bigint)), 0) AS total_suicides
FROM WHO_SUICIDES.dbo.who_suicide
WHERE country = 'United States of America'
GROUP BY country,
         [year],
         sex
ORDER BY country, [year] ASC

-- Lets look at the suicides in the United States and obtain the year with the highest suicide number and gender ans: 2015, Males.
WITH cte1
AS (SELECT
  [year],
  sex,
  COALESCE(SUM(CAST(suicides_no AS bigint)), 0) AS total_suicides
FROM WHO_SUICIDES.dbo.who_suicide
WHERE country = 'United States of America'
GROUP BY country,
         [year],
         sex)
SELECT
  [year],
  sex
FROM cte1
GROUP BY [year],
         sex
HAVING MAX(total_suicides) = (SELECT
  MAX(total_suicides)
FROM cte1)

-- country with the most suicides answ: Russian Federation 1500992
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

-- MEDIAN suicides
SELECT
  [year],
  suicides_no
FROM WHO_SUICIDES.dbo.who_suicide
WHERE suicides_no = (SELECT
DISTINCT
  PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY suicides_no) OVER ()
FROM WHO_SUICIDES.dbo.who_suicide)
ORDER BY [year]

-- Lets look at the suicides in the United States by newly created column age_category
SELECT
  [age_category],
  COALESCE(SUM(CAST(suicides_no AS bigint)), 0) AS total_suicides
FROM WHO_SUICIDES.dbo.who_suicide
WHERE country = 'United States of America'
GROUP BY [age_category]
ORDER BY total_suicides ASC

-- Lets look at the suicides in Russia by newly created column age_category
SELECT
  [age_category],
  COALESCE(SUM(CAST(suicides_no AS bigint)), 0) AS total_suicides
FROM WHO_SUICIDES.dbo.who_suicide
WHERE country = 'Russian Federation'
GROUP BY [age_category]
ORDER BY total_suicides ASC

-- Create a new table that has continents and their countries
CREATE TABLE WHO_SUICIDES.dbo.country_continents (
  Continent varchar(50),
  Country varchar(50)
);

-- manually insert values into new table
INSERT INTO WHO_SUICIDES.dbo.country_continents
  VALUES ('Africa', 'Angola'),
  ('Africa', 'Benin'),
  ('Africa', 'Botswana'),
  ('Africa', 'Burkina'),
  ('Africa', 'Burundi'),
  ('Africa', 'Cameroon'),
  ('Africa', 'Egypt'),
  ('Africa', 'Cape Verde'),
  ('Africa', 'Central African Republic'),
  ('Africa', 'Chad'),
  ('Africa', 'Comoros'),
  ('Africa', 'Congo'),
  ('Africa', 'Congo, Democratic Republic of'),
  ('Africa', 'Djibouti'),
  ('Africa', 'Equatorial Guinea'),
  ('Africa', 'Eritrea'),
  ('Africa', 'Ethiopia'),
  ('Africa', 'Gabon'),
  ('Africa', 'Gambia'),
  ('Africa', 'Ghana'),
  ('Africa', 'Guinea'),
  ('Africa', 'Mauritius'),
  ('Africa', 'Morocco'),
  ('Africa', 'Guinea-Bissau'),
  ('Africa', 'Ivory Coast'),
  ('Africa', 'Sao Tome and Principe'),
  ('Africa', 'Kenya'),
  ('Africa', 'Seychelles'),
  ('Africa', 'South Africa'),
  ('Africa', 'Lesotho'),
  ('Africa', 'Liberia'),
  ('Africa', 'Libya'),
  ('Africa', 'Tunisia'),
  ('Africa', 'Zimbabwe'),
  ('Africa', 'Madagascar'),
  ('Africa', 'Malawi'),
  ('Africa', 'Mali'),
  ('Africa', 'Mauritania'),
  ('Africa', 'Mozambique'),
  ('Africa', 'Namibia'),
  ('Africa', 'Niger'),
  ('Africa', 'Nigeria'),
  ('Africa', 'Rwanda'),
  ('Africa', 'Senegal'),
  ('Africa', 'Sierra Leone'),
  ('Africa', 'Somalia'),
  ('Africa', 'South Sudan'),
  ('Africa', 'Sudan'),
  ('Africa', 'Swaziland'),
  ('Africa', 'Tanzania'),
  ('Africa', 'Togo'),
  ('Africa', 'Uganda'),
  ('Africa', 'Zambia'),
  ('Africa', 'Algeria'),
  ('Asia', 'Bhutan'),
  ('Asia', 'Brunei'),
  ('Asia', 'Burma (Myanmar)'),
  ('Asia', 'Cambodia'),
  ('Asia', 'China'),
  ('Asia', 'East Timor'),
  ('Asia', 'India'),
  ('Asia', 'Indonesia'),
  ('Asia', 'Iran'),
  ('Asia', 'Korea, North'),
  ('Asia', 'Korea, South'),
  ('Asia', 'Laos'),
  ('Asia', 'Lebanon'),
  ('Asia', 'Bahrain'),
  ('Asia', 'Nepal'),
  ('Asia', 'Iraq'),
  ('Asia', 'Israel'),
  ('Asia', 'Japan'),
  ('Asia', 'Jordan'),
  ('Asia', 'Kazakhstan'),
  ('Asia', 'Kuwait'),
  ('Asia', 'Kyrgyzstan'),
  ('Asia', 'Pakistan'),
  ('Asia', 'Malaysia'),
  ('Asia', 'Maldives'),
  ('Asia', 'Mongolia'),
  ('Asia', 'Oman'),
  ('Asia', 'Philippines'),
  ('Asia', 'Qatar'),
  ('Asia', 'Russian Federation'),
  ('Asia', 'Saudi Arabia'),
  ('Asia', 'Singapore'),
  ('Asia', 'Sri Lanka'),
  ('Asia', 'Tajikistan'),
  ('Asia', 'Thailand'),
  ('Asia', 'Turkey'),
  ('Asia', 'Turkmenistan'),
  ('Asia', 'United Arab Emirates'),
  ('Asia', 'Uzbekistan'),
  ('Asia', 'Syria'),
  ('Asia', 'Vietnam'),
  ('Asia', 'Yemen'),
  ('Asia', 'Afghanistan'),
  ('Asia', 'Bangladesh'),
  ('Europe', 'CZ'),
  ('Europe', 'Liechtenstein'),
  ('Europe', 'Macedonia'),
  ('Europe', 'Moldova'),
  ('Europe', 'Albania'),
  ('Europe', 'Armenia'),
  ('Europe', 'Austria'),
  ('Europe', 'Azerbaijan'),
  ('Europe', 'Belarus'),
  ('Europe', 'Belgium'),
  ('Europe', 'Bosnia and Herzegovina'),
  ('Europe', 'Bulgaria'),
  ('Europe', 'Croatia'),
  ('Europe', 'Cyprus'),
  ('Europe', 'Denmark'),
  ('Europe', 'Estonia'),
  ('Europe', 'Finland'),
  ('Europe', 'France'),
  ('Europe', 'Georgia'),
  ('Europe', 'Germany'),
  ('Europe', 'Greece'),
  ('Europe', 'Hungary'),
  ('Europe', 'Iceland'),
  ('Europe', 'Ireland'),
  ('Europe', 'Italy'),
  ('Europe', 'Latvia'),
  ('Europe', 'Lithuania'),
  ('Europe', 'Luxembourg'),
  ('Europe', 'Malta'),
  ('Europe', 'Monaco'),
  ('Europe', 'Montenegro'),
  ('Europe', 'Netherlands'),
  ('Europe', 'Norway'),
  ('Europe', 'Poland'),
  ('Europe', 'Portugal'),
  ('Europe', 'Romania'),
  ('Europe', 'San Marino'),
  ('Europe', 'Serbia'),
  ('Europe', 'Slovakia'),
  ('Europe', 'Slovenia'),
  ('Europe', 'Spain'),
  ('Europe', 'Sweden'),
  ('Europe', 'Switzerland'),
  ('Europe', 'Ukraine'),
  ('Europe', 'United Kingdom'),
  ('Europe', 'Vatican City'),
  ('Europe', 'Andorra'),
  ('North America', 'Saint Vincent and the Grenadines'),
  ('North America', 'Antigua and Barbuda'),
  ('North America', 'Bahamas'),
  ('North America', 'Barbados'),
  ('North America', 'Belize'),
  ('North America', 'Canada'),
  ('North America', 'Costa Rica'),
  ('North America', 'Cuba'),
  ('North America', 'Dominica'),
  ('North America', 'Dominican Republic'),
  ('North America', 'El Salvador'),
  ('North America', 'Grenada'),
  ('North America', 'Guatemala'),
  ('North America', 'Haiti'),
  ('North America', 'Honduras'),
  ('North America', 'Jamaica'),
  ('North America', 'Mexico'),
  ('North America', 'Nicaragua'),
  ('North America', 'Panama'),
  ('North America', 'Saint Kitts and Nevis'),
  ('North America', 'Saint Lucia'),
  ('North America', 'Trinidad and Tobago'),
  ('North America', 'United States of America'),
  ('Oceania', 'Marshall Islands'),
  ('Oceania', 'Micronesia'),
  ('Oceania', 'Nauru'),
  ('Oceania', 'Palau'),
  ('Oceania', 'Papua New Guinea'),
  ('Oceania', 'Samoa'),
  ('Oceania', 'Solomon Islands'),
  ('Oceania', 'Australia'),
  ('Oceania', 'Fiji'),
  ('Oceania', 'Kiribati'),
  ('Oceania', 'Tonga'),
  ('Oceania', 'Tuvalu'),
  ('Oceania', 'New Zealand'),
  ('Oceania', 'Vanuatu'),
  ('South America', 'Venezuela'),
  ('South America', 'Argentina'),
  ('South America', 'Bolivia'),
  ('South America', 'Brazil'),
  ('South America', 'Chile'),
  ('South America', 'Colombia'),
  ('South America', 'Ecuador'),
  ('South America', 'Guyana'),
  ('South America', 'Paraguay'),
  ('South America', 'Peru'),
  ('South America', 'Suriname'),
  ('South America', 'Uruguay');

-- Lets look at total suicides by continent using a join from the first table to the new table
-- We can see the total suicides is highest in Asia, followed by Asia, and then Europe.
SELECT
  [Continent],
  COALESCE(SUM(CAST(suicides_no AS bigint)), 0) AS total_suicides
FROM WHO_SUICIDES.dbo.who_suicide AS ws
JOIN WHO_SUICIDES.dbo.[country_continents] AS cc
  ON ws.country = cc.Country
GROUP BY [Continent]
ORDER BY total_suicides DESC
