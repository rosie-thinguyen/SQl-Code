/*
Covid 19 Data Exploration

Skills used: Joins, CTE's, Temp Table, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

SELECT * 
FROM Covid19Analysis..CovidDeaths
WHERE continent is not null
ORDER BY 3,4


SELECT * 
FROM Covid19Analysis..CovidVaccinations
ORDER BY 3,4


--Selecting Data that will be used

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Covid19Analysis..CovidDeaths
WHERE continent is not null
ORDER BY 1,2


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)* 100 AS DeathPercentage
FROM Covid19Analysis..CovidDeaths
WHERE location like '%United Kingdom%'
AND continent is not null
ORDER BY 1,2


--Total Cases vs Population
--Shows what percentage of poplation got Covid

SELECT location, date, population, total_deaths, (total_cases/population)* 100 AS InfectedPopulationPercentage
FROM Covid19Analysis..CovidDeaths
WHERE location like '%United Kingdom%'
AND continent is not null
ORDER BY 1,2


-- Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases)AS HighestInfectionCount, MAX ((total_cases/population) * 100) AS InfectedPopulationPercentage
FROM Covid19Analysis..CovidDeaths
WHERE continent is not null
ORDER BY 4 DESC


-- Countries with Highest Death Count per Population

SELECT location, (MAX (CAST(total_deaths as INT))) TotalDeathCount
FROM Covid19Analysis..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC

			    
BREAKING THINGS DOWN BY CONTINENT
			    
-- Continents with the highest death count per population
SELECT continent, (MAX (CAST(total_deaths as INT))) TotalDeathCount
FROM Covid19Analysis..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC



--GLOBAL NUMBERS
			     
SELECT SUM (new_cases) AS total_cases, SUM (CAST(new_deaths AS INT)) AS total_deaths,
(SUM (CAST(new_deaths AS INT)) / SUM (new_cases) * 100) AS DeathPercentage
FROM Covid19Analysis..CovidDeaths
WHERE continent is not null
--GROUP BY date
ORDER BY 3 DESC

      

-- Total population vs Vaccinations
-- The percentage of population that has received at least one Covid Vaccine
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


	      
-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

      
      
--Using Temp Table to perform calculation on Partition By in previous query
	      
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingTotalVaccinationPerDate numeric
)


INSERT INTO #PercentPopulationVaccinated
SELECT dea.Continent, dea.location, dea.date, dea.population, vac.New_Vaccinations,
SUM (CONVERT(INT,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date ) AS RollingTotalVaccinationPerDate

FROM Covid19Analysis..CovidDeaths AS dea
JOIN Covid19Analysis..CovidVaccinations AS vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 1,2,3
SELECT * , (RollingTotalVaccinationPerDate/population) * 100 AS VaccinationPercentage
FROM #PercentPopulationVaccinated





-- Create View to stored data for later visualisation
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.Continent, dea.location, dea.date, dea.population, vac.New_Vaccinations,
SUM (CONVERT(INT,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date ) AS RollingTotalVaccinationPerDate

FROM Covid19Analysis..CovidDeaths AS dea
JOIN Covid19Analysis..CovidVaccinations AS vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 1,2,3


