/*
Covid 19 Data Exploration
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/
SELECT *
FROM PortfolioProject.dbo.CovidDeaths
WHERE Continent IS NOT NULL
ORDER BY 3,4;

-- Select Data that we will be starting with

SELECT Location, Date, Total_cases,
                       New_cases,
                       Total_deaths,
                       Population
FROM PortfolioProject.dbo.CovidDeaths
WHERE Continent IS NOT NULL
ORDER BY 1,2;

--Total Cases vs Total Deaths
-- Shows likelihood of death from contracting covid in your country

SELECT Location,
       MAX(Total_cases) AS TotalCases,
       MAX(CAST(Total_deaths AS int)) AS TotalDeathCount,
       (MAX(CAST(Total_deaths AS int)) / MAX(Total_cases)) * 100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE Location = 'United States'
GROUP BY Location;

--Looking at Total Cases vs Population
--Shows what percentage of the population has contracted covid

SELECT Location, Date, Population,
                       Total_cases,
                       New_cases,
                       (Total_cases / Population) * 100 AS InfectedPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE Location = 'United States'
ORDER BY 1,2;

--Looking at countries with highest infection rate(total cases vs population)

SELECT Location,
       Population,
       MAX(Total_cases) AS HighestInfectionCount,
       MAX((Total_cases / Population)) * 100 AS InfectedPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE Continent IS NOT NULL
GROUP BY Location,
         Population
ORDER BY InfectedPercentage DESC;

-- Showing countries with highest death count per population

SELECT Location,
       MAX(CAST(Total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE Continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC;

-- LET'S BREAK THINGS DOWN BY CONTINENT

SELECT Continent,
       MAX(CAST(Total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE Continent IS NOT NULL
GROUP BY Continent
ORDER BY TotalDeathCount DESC;

-- Showing continents with the highest death count per population

SELECT Continent,
       MAX(CAST(Total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE Continent IS NOT NULL
GROUP BY Continent
ORDER BY TotalDeathCount DESC;

-- GLOBAL NUMBERS

SELECT SUM(New_cases) AS Total_cases,
       SUM(CAST(New_deaths AS int)) AS Total_deaths,
       SUM(CAST(New_deaths AS int)) / SUM(New_cases) * 100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE Continent IS NOT NULL
ORDER BY 1,2;

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT vac.Location,
       (MAX(CONVERT(bigint,vac.people_vaccinated))/dea.Population*100) AS PercentVaccinated
FROM PortfolioProject.dbo.CovidVaccinations vac
JOIN PortfolioProject.dbo.CovidDeaths dea ON vac.Location = dea.Location
AND vac.Date = dea.Date
WHERE vac.Continent IS NOT NULL
  AND vac.Location IS NOT NULL
GROUP BY vac.Location,
         dea.Population
ORDER BY vac.Location; 

-- Using CTE to perform Calculation on Partition By in previous query

  WITH PopvsVac 
	(Continent,
     Location, 
	 Date, 
	 Population,
     New_Vaccinations,
     RollingPeopleVaccinated) 
AS
  (SELECT dea.Continent,
          dea.Location,
          dea.Date,
          dea.Population,
          vac.New_vaccinations,
          SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.Location
          ORDER BY dea.location,dea.Date) AS RollingPeopleVaccinated
   FROM PortfolioProject.dbo.CovidDeaths dea
   JOIN PortfolioProject.dbo.CovidVaccinations vac ON dea.Location = vac.Location
   AND dea.date = vac.date
   WHERE dea.continent IS NOT NULL)

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac; 

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP TABLE IF EXISTS PercentPopulationVaccinated
CREATE TABLE PercentPopulationVaccinated (
		Continent nvarchar(255),
        Location nvarchar(255), 
		Date datetime, 
		Population numeric, 
		NewVaccinations numeric, 
		RollingPeopleVaccinated numeric)
INSERT INTO PercentPopulationVaccinated
SELECT dea.continent,
       dea.location,
       dea.date,
       dea.population,
       vac.new_vaccinations,
       SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.Location
       ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac ON dea.location = vac.location
AND dea.date = vac.date

SELECT *,
       (RollingPeopleVaccinated/Population)*100
FROM PercentPopulationVaccinated; 
