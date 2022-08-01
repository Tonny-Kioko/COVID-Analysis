SELECT * FROM covid_deaths
WHERE continent IS NOT NULL;

SELECT population FROM covid_deaths;

-- Selecting the data for evaluation

SELECT location, record_date, total_cases, new_cases, total_deaths, population FROM covid_deaths
WHERE continent IS NOT NULL
ORDER BY location, record_date;

-- Total Cases Vs Total Deaths
--Percentage of people in Africa who die after getting infected (Likelihood of death)

SELECT location, record_date, total_cases, total_deaths,  (total_deaths/total_cases)*100 as DeathPercentage
FROM covid_deaths
WHERE location = 'Africa'
ORDER BY location, record_date;

--Total Cases Vs the Population (%ge of population infected)

SELECT location, record_date, total_cases, population,  (total_cases/ population)*100 as InfectedPercentage
FROM covid_deaths
WHERE location = 'Africa'
ORDER BY location, record_date;

--Countries with the highest infection rates compared to population

SELECT location, MAX ( total_cases) AS Highest_Infection, population,  MAX((total_cases/ population))*100 
AS InfectedPercentage
FROM covid_deaths
--WHERE location = 'Africa'
GROUP BY location, population
ORDER BY InfectedPercentage DESC;

--Highest infection level in Kenya

SELECT location, MAX ( total_cases) AS Highest_Infection, population,  MAX((total_cases/ population))*100 
AS InfectedPercentage
FROM covid_deaths
WHERE location = 'Kenya'
GROUP BY location, population
ORDER BY InfectedPercentage;

--The countries with the highest mortality in the population

SELECT location, MAX ( total_deaths) AS Death_Counts
FROM covid_deaths
WHERE total_deaths IS NOT NULL
AND continent IS NOT NULL
GROUP BY location
ORDER BY Death_Counts DESC;

--Continents with the highest mortality

SELECT continent, MAX ( total_deaths) AS Death_Counts
FROM covid_deaths
WHERE total_deaths IS NOT NULL
AND continent IS NOT NULL
GROUP BY continent
ORDER BY Death_Counts DESC;


--NUMBERS ON A GLOBAL SCALE

--New cases reported everyday globally

SELECT record_date, SUM (new_cases) AS New_Infections
FROM covid_deaths
WHERE new_cases IS NOT NULL
AND continent IS NOT NULL
GROUP BY record_date, new_cases
--ORDER BY Death_Counts DESC;

--New deaths reported globally

SELECT record_date, SUM (new_deaths) AS New_Deaths
FROM covid_deaths
WHERE new_deaths IS NOT NULL
AND continent IS NOT NULL
GROUP BY record_date, new_deaths
--ORDER BY Death_Counts DESC;

--Death percentage in contrast to reported cases

SELECT record_date, SUM (new_cases) AS TotalNewCases, SUM (new_deaths) AS TotalNewDeaths,
((SUM (new_cases))  / (SUM (new_deaths))*100) AS DeathPercentage
FROM covid_deaths
--WHERE new_cases IS NOT NULL
WHERE continent IS NOT NULL
--AND new_deaths IS NOT NULL
GROUP BY record_date, new_cases, new_deaths
ORDER BY record_date, DeathPercentage DESC;


SELECT  * FROM covid_vaccinations;

-- Joining the Covid_deaths and Covid_vaccination tables

SELECT * FROM covid_deaths d JOIN covid_vaccinations v
ON (d.location = v.location)
AND (d.record_date = v.record_date);

--Total Vaccinations VS the Population

SELECT d.continent, d.location, d.record_date, d.population, v.new_vaccinations,
SUM (v.new_vaccinations) OVER (PARTITION BY d.location ORDER BY d.location, d.record_date) AS Country_Totals
FROM covid_deaths d JOIN covid_vaccinations v
              ON (d.location = v.location)
              AND (d.record_date = v.record_date)
WHERE d.continent IS NOT NULL
ORDER BY 1,2,3;

--Creating table for Country Totals for Comparison with Population Totals

CREATE TABLE Rolling_Country_Totals (continent, location, record_date, population, new_vaccinations, country_totals)
AS 
(SELECT d.continent, d.location, d.record_date, d.population, v.new_vaccinations,
SUM (v.new_vaccinations) OVER (PARTITION BY d.location ORDER BY d.location, d.record_date) AS Country_Totals
FROM covid_deaths d JOIN covid_vaccinations v
              ON (d.location = v.location)
              AND (d.record_date = v.record_date)
WHERE d.continent IS NOT NULL
--ORDER BY 1,2,3
);


SELECT  * FROM rolling_country_totals;

SELECT continent, location, record_date, population, new_vaccinations, country_totals,
(country_totals/population*100) AS Vaccinated_Population
FROM rolling_country_totals
--WHERE location = 'Kenya'
ORDER BY 7;

--Creating views for Tableau Visualizaton

CREATE VIEW rolling_county_totals_view
AS 
(SELECT d.continent, d.location, d.record_date, d.population, v.new_vaccinations,
SUM (v.new_vaccinations) OVER (PARTITION BY d.location ORDER BY d.location, d.record_date) AS Country_Totals
FROM covid_deaths d JOIN covid_vaccinations v
              ON (d.location = v.location)
              AND (d.record_date = v.record_date)
WHERE d.continent IS NOT NULL
--ORDER BY 1,2,3
);

