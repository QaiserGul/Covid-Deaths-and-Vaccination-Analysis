ALTER DATABASE PortfolioProject
SET COMPATIBILITY_LEVEL = 90;

USE PortfolioProject;

SELECT * FROM covidDeaths ORDER BY 1,2 DESC;

SELECT * FROM covidVaccinations;

-- Selecting and understanding data that we will use for analysis

 SELECT Location, date, total_cases, new_cases, total_deaths, population
 FROM covidDeaths
 ORDER BY Location, date

 -- Looking at total cases vs total deaths
 -- Probability of dying if we get in contact with covid
  SELECT Location, date, total_cases, total_deaths,ROUND( (total_deaths/total_cases)*100,2) AS death_percentage
 FROM covidDeaths
 WHERE Location = 'India'
 ORDER BY total_cases DESC

 -- Looking at total cases vs population
 -- Shows what percentage of population got Covid

  SELECT Location, date, population, total_cases, ROUND(total_cases/population * 100,2) AS cases_percentage
 FROM covidDeaths
 --WHERE Location = 'India'
 ORDER BY total_cases DESC

 -- Looking at countries with highest infection rate compared to population

   SELECT Location, population, MAX(total_cases) as highest_infection_count, (MAX(total_cases)/population)*100 AS max_cases_percentage
 FROM covidDeaths
 GROUP BY population, Location
 ORDER BY max_cases_percentage DESC

 -- Countries with highest death count per population

   SELECT Location, population, MAX(CAST(total_deaths AS INT)) AS total_death_count, (MAX(total_deaths)/population)*100 AS max_cases_percentage
 FROM covidDeaths
 GROUP BY population, Location
 ORDER BY total_death_count DESC

 -- The original datatype of total_deaths is VARCHAR(255)
 -- Converting it to INT datatype can be done like this
 --ALTER TABLE covidDeaths
 --ALTER COLUMN total_deaths INT;

 -- Some records with null continents results World as an output 
 -- So by adding WHERE clause we can remove that

  SELECT Location, MAX(CAST(total_deaths AS INT)) AS total_death_count
 FROM covidDeaths
 WHERE continent IS NOT NULL
 GROUP BY Location
 ORDER BY total_death_count DESC


 -- Showing the continent with highest death count

   SELECT continent, MAX(CAST(total_deaths AS INT)) AS total_death_count
 FROM covidDeaths
 WHERE continent IS NOT NULL
 GROUP BY continent
 ORDER BY total_death_count DESC

 -- Global Numbers

 SELECT 
 --date, 
 SUM(new_cases) AS total_cases,
 SUM(CAST(new_deaths AS INT)) AS total_deaths, 
 ROUND(SUM(CAST(new_deaths AS INT))/SUM(new_cases) * 100,2) AS death_percentage
 FROM covidDeaths
 WHERE continent IS NOT NULL 
 AND total_cases IS NOT NULL
 --GROUP BY date
 --ORDER BY 1






-- INTRODUCING COVID VACCINATION TABLE-- 

SELECT *
FROM covidVaccinations

-- JOINing both deaths and vaccination table
-- Looking total population vs total vaccination
-- USE CTE


WITH PopvsVac (continent, location,date, population, new_deaths, new_vaccinations
,rolling_vaccination)
AS (
SELECT cd.continent, cd.location,cd.date, cd.population, cd.new_deaths, cv.new_vaccinations
, SUM(CAST(cv.new_vaccinations AS INT)) OVER(PARTITION BY cd.location ORDER BY cd.date) AS rolling_vaccination
FROM covidDeaths AS cd
INNER JOIN covidVaccinations AS cv 
ON cd.location = cv.location 
AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
AND cd.new_deaths IS NOT NULL
AND cv.new_vaccinations IS NOT NULL
)
SELECT *, (rolling_vaccination/population)*100 AS percentage_vaccinated
FROM PopvsVac



-- TEMP TABLE


CREATE TABLE percent_population_vaccinated (
  continent NVARCHAR(255),
  location NVarchar(255),
  date DATETIME,
  population NUMERIC,
  new_vaccinations NUMERIC,
  rolling_vaccinations NUMERIC
);


INSERT INTO percent_population_vaccinated
SELECT cd.continent, cd.location,cd.date, cd.population, cv.new_vaccinations
, SUM(CAST(cv.new_vaccinations AS NUMERIC)) OVER(PARTITION BY cd.location ORDER BY cd.date) AS rolling_vaccinations
FROM covidDeaths AS cd
INNER JOIN covidVaccinations AS cv 
ON cd.location = cv.location 
AND cd.date = cv.date


-- Creating view to store data for later visualization


CREATE VIEW V_percent_population_vaccinated AS
SELECT cd.continent, cd.location,cd.date, cd.population, cd.new_deaths, cv.new_vaccinations
, SUM(CAST(cv.new_vaccinations AS NUMERIC)) OVER(PARTITION BY cd.location ORDER BY cd.date) AS rolling_vaccination
FROM covidDeaths AS cd
INNER JOIN covidVaccinations AS cv 
ON cd.location = cv.location 
AND cd.date = cv.date
WHERE cd.continent IS NOT NULL


SELECT * 
FROM V_percent_population_vaccinated






















































































































































































































