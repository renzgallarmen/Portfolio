/*
Covid 19 Data Exploration

Skills used: Joins, CTE's, Temp Tables, Window Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

Select *
From Portfolio..CovidDeaths
Where continent is not NULL
Order By 3,4

Select *
From Portfolio..CovidVaccinations
Where continent is not NULL
Order by 3,4

-- Selecting the data I'm starting with

Select continent, Location, date, total_cases, new_cases, total_deaths, population
From Portfolio..CovidDeaths
Where continent is not NULL
order by 1,2

-- Total Cases vs Total Deaths in Asia in Percentage

Select continent, Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Portfolio..CovidDeaths
Where continent like '%Asia%'
Order by 1,2

-- Total Case Vs. Population 

Select continent, Location, date, total_cases, population, (total_cases/population)*100 as InfectionPercentage
From Portfolio..CovidDeaths
Where continent like '%Asia%'
Order by 1,2

-- Countries with the Highest Infection Rate in Asia compared to Population

Select Location, Population, Max(total_cases) as HighestInfectionCount, Max(total_cases/population)*100 as PercentPopulationInfected
From Portfolio..CovidDeaths
Where continent like '%Asia%'
Group by Location, Population
Order by PercentPopulationInfected desc

--Countries with the Highest Death Count per Population in Asia

Select Location, MAX(cast (total_deaths as int)) as TotalDeathCount
From Portfolio..CovidDeaths
Where continent like '%Asia%' 
Group by Location
Order by TotalDeathCount desc

--Vaccinated People Over Time in Asia
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as VaccinatedPeopleOverTime
From Portfolio..CovidDeaths as dea
Join Portfolio..CovidVaccinations as vac
    On dea.location = vac.location
    and dea.date = vac.date
where vac.continent like '%Asia%'
Order by 2,3

-- Using Temp Table to perform a Calculation on Partition By in the previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent NVARCHAR(255),
Location NVARCHAR(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location) as VaccinatedPeopleOverTime
From Portfolio..CovidDeaths as dea
Join Portfolio..CovidVaccinations as vac
    On dea.location = vac.location
    and dea.date = vac.date
where vac.continent like '%Asia%'
Order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100 as PercentageRollingVaccine
From #PercentPopulationVaccinated
