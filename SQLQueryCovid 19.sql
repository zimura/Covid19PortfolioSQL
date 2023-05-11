SELECT *
FROM PortfolioProject..CovidDea$
ORDER BY 1, 2


SELECT *
FROM PortfolioProject..CovidVac$

--selecting the data i want to use
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDea$
ORDER BY 1, 2

--looking for total cases vs total death
SELECT location, date, total_cases,total_deaths, (CONVERT(INT, total_deaths)/CONVERT(INT,total_cases))*100
FROM PortfolioProject..CovidDea$
WHERE continent is not null
ORDER BY 3, 4

--shows what percent of the population got covid
SELECT location, date, total_cases, population, (total_cases/population)*100 as Deathpercentage
FROM PortfolioProject..CovidDea$
WHERE location Like '%Africa%'
ORDER BY 1, 2

--looking for countries with higest infection rate compared to the population
SELECT location, population, MAX(total_cases)AS HigestInfection, MAX((total_cases/population))*100 as HighestInfectionpercentage
FROM PortfolioProject..CovidDea$
--WHERE location Like '%Africa%'
GROUP BY location, population
ORDER BY HighestInfectionpercentage DESC

--showing countries with highest death count per population
SELECT location, MAX(CAST(total_deaths as int))as DeathCount
FROM PortfolioProject..CovidDea$
--WHERE location Like '%Africa%'
GROUP BY location
ORDER BY DeathCount DESC

--showing highest death count per continent
SELECT continent, MAX(CAST(total_deaths as int))as DeathCount
FROM PortfolioProject..CovidDea$
WHERE continent is Not NULL
GROUP BY continent
ORDER BY DeathCount DESC

--Global numbers
SELECT date, SUM(new_cases)AS NewCase, SUM(CONVERT(int, total_deaths))AS TotalDeaths,
SUM(CONVERT(int, total_deaths))/SUM(new_cases)--*100 as GroundTotal
FROM PortfolioProject..CovidDea$
--WHERE continent is NOT NULL
GROUP BY date
ORDER BY 1, 2

--for location
SELECT date, location, SUM(new_cases)AS NewCase, SUM(CONVERT(int, total_deaths))AS TotalDeaths,
SUM(new_cases)/SUM(CONVERT(int, total_deaths))*100 as GroundTotal
FROM PortfolioProject..CovidDea$
WHERE continent is NOT NULL
GROUP BY date, location
ORDER BY 1, 2

--joining both tables
SELECT *
FROM PortfolioProject..CovidDea$ dea
JOIN PortfolioProject..CovidVac$ vac
ON  dea.date = vac.date
AND dea.location = vac.location

--looking for total population vs vacinnes
SELECT dea.continent, dea.population, dea.location, dea.date, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (Partition by dea.location ORDER BY dea.location) as sumvaccines
FROM PortfolioProject..CovidDea$ dea
JOIN PortfolioProject..CovidVac$ vac
ON  dea.date = vac.date
AND dea.location = vac.location
WHERE dea.continent is null
ORDER BY 2, 3

--UseCTE
WITH PopvsVac (continent, population, location, date, new_vaccinations, sumvaccines)
as
(
SELECT dea.continent, dea.population, dea.location, dea.date, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (Partition by dea.location ORDER BY dea.location) as sumvaccines
FROM PortfolioProject..CovidDea$ dea
JOIN PortfolioProject..CovidVac$ vac
ON  dea.date = vac.date
AND dea.location = vac.location
WHERE dea.continent is null
--ORDER BY 2, 3
)
SELECT location, population, (sumvaccines/population)*100
FROM PopvsVac

--Temp Table
DROP TABLE IF exists #PercentPopulationVaccined
CREATE TABLE #PercentPopulationVaccined
(
continents nvarchar(255),
population numeric,
location nvarchar(255),
date datetime,
new_vaccinations numeric,
sumvaccines numeric
)

INSERT INTO #PercentPopulationVaccined
SELECT dea.continent, dea.population, dea.location, dea.date, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (Partition by dea.location ORDER BY dea.location) as sumvaccines
FROM PortfolioProject..CovidDea$ dea
JOIN PortfolioProject..CovidVac$ vac
ON  dea.date = vac.date
AND dea.location = vac.location
WHERE dea.continent is null
--ORDER BY 2, 3

SELECT location, population, (sumvaccines/population)*100
FROM #PercentPopulationVaccined

--create view for storing data for later visualization
Create view PercentPopulationVaccined as
SELECT dea.continent, dea.population, dea.location, dea.date, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (Partition by dea.location ORDER BY dea.location) as sumvaccines
FROM PortfolioProject..CovidDea$ dea
JOIN PortfolioProject..CovidVac$ vac
ON  dea.date = vac.date
AND dea.location = vac.location
WHERE dea.continent is null
--ORDER BY 2, 3
