SELECT * FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

SELECT * FROM PortfolioProject..CovidVaccinations
ORDER BY 3,4

--select data that are going to use

SELECT location,date,total_cases,new_cases,total_deaths,population 
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

--looking at total cases vs total deaths
--shows the likelihood of death if contact with covid in a country
SELECT location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
AND  location like '%India%'
ORDER BY 1,2

--looking at total_cases vs population
--shows what percentage of population are affected by covid

SELECT location,date,population,total_cases,(total_cases/population)*100 as population_infected_Percentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
AND location ='India'
ORDER BY 1,2

--looking at countries with highest infection rate compared to popukation

SELECT location,population,MAX(total_cases) AS highest_infection_count,max((total_cases/population))*100 as population_infected_Percentage
FROM PortfolioProject..CovidDeaths
--WHERE location ='India'
GROUP BY location,population
ORDER BY population_infected_Percentage DESC

--Countries with highest death count per population
SELECT location,MAX(CAST(total_deaths AS INT)) AS Total_Death_Count
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY Total_Death_Count DESC

--BY CONTINET
--Showing contintents with the highest death count per population

SELECT continent,MAX(CAST(total_deaths AS INT)) AS Total_Death_Count_Continet
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY Total_Death_Count_Continet DESC

--Global Numbers
SELECT SUM(new_cases) AS total_new_cases,SUM(CAST(new_deaths AS INT)) AS total_new_deaths, (SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100 as Global_Death_Percentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
--AND  location like '%India%'
ORDER BY 1,2


--looking at total population vs vaccination

SELECT Cdea.continent, Cdea.location, Cdea.date, Cdea.population,Cvac.new_vaccinations
 , SUM(CONVERT(INT,Cvac.new_vaccinations)) OVER(PARTITION BY Cdea.location ORDER BY Cdea.location,Cdea.date) AS Rolling_People_Vaccinated
 FROM PortfolioProject..CovidDeaths Cdea
 JOIN PortfolioProject..CovidVaccinations Cvac
 ON Cdea.location = Cvac.location
 AND Cdea.date = Cvac.date
 WHERE Cdea.continent IS NOT NULL
 ORDER BY 2,3

 --USE CTE
 WITH PopVsVac(Continent, Location, Date, Population, new_vaccinations, Rolling_People_Vaccinated)
 AS
 (
 SELECT Cdea.continent, Cdea.location, Cdea.date, Cdea.population,Cvac.new_vaccinations
 , SUM(CONVERT(INT,Cvac.new_vaccinations)) OVER(PARTITION BY Cdea.location ORDER BY Cdea.location,Cdea.date) AS Rolling_People_Vaccinated
 FROM PortfolioProject..CovidDeaths Cdea
 JOIN PortfolioProject..CovidVaccinations Cvac
 ON Cdea.location = Cvac.location
 AND Cdea.date = Cvac.date
 WHERE Cdea.continent IS NOT NULL
 --ORDER BY 2,3
 )
SELECT *, (Rolling_People_Vaccinated/Population)*100
FROM PopVsVac

--Temp Table

DROP TABLE if exists #percentpopulationvaccinated
CREATE TABLE #percentpopulationvaccinated
(
continent nvarchar(255),
Location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
Rolling_People_Vaccinated numeric,
)

INSERT INTO #percentpopulationvaccinated
 SELECT Cdea.continent, Cdea.location, Cdea.date, Cdea.population,Cvac.new_vaccinations
 , SUM(CONVERT(INT,Cvac.new_vaccinations)) OVER(PARTITION BY Cdea.location ORDER BY Cdea.location,Cdea.date) AS Rolling_People_Vaccinated
 FROM PortfolioProject..CovidDeaths Cdea
 JOIN PortfolioProject..CovidVaccinations Cvac
 ON Cdea.location = Cvac.location
 AND Cdea.date = Cvac.date
 --WHERE Cdea.continent IS NOT NULL
 --ORDER BY 2,3

 SELECT *, (Rolling_People_Vaccinated/Population)*100
FROM #percentpopulationvaccinated


--Creating the View
--DROP VIEW [percentpopulationvaccinated]
CREATE VIEW [percentpopulationvaccinated] AS
SELECT Cdea.continent, Cdea.location, Cdea.date, Cdea.population,Cvac.new_vaccinations
 , SUM(CONVERT(INT,Cvac.new_vaccinations)) OVER(PARTITION BY Cdea.location ORDER BY Cdea.location,Cdea.date) AS Rolling_People_Vaccinated
 FROM PortfolioProject..CovidDeaths Cdea
 JOIN PortfolioProject..CovidVaccinations Cvac
 ON Cdea.location = Cvac.location
 AND Cdea.date = Cvac.date
 WHERE Cdea.continent IS NOT NULL
 --ORDER BY 2,3

 SELECT * FROM percentpopulationvaccinated

