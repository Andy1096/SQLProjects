--Select *
--From PortfolioProject..CovidDeaths
--ORDER BY 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--ORDER BY 3,4

--Select data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
ORDER BY 1,2

--Looking at total cases vs total deaths
-- shows the likelihood of dying if you contract covid in your country

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
WHERE location like '%State%'
ORDER BY 1,2

--Looking at total cases vs population
-- Shows what % of population got covid

SELECT Location, date, total_cases, population, (total_deaths/population)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
WHERE location like '%State%'
ORDER BY 1,2

-- Looking at countries with highest infection rates compared to population

SELECT Location, population, Max(total_cases) as HighestInfectionCount, MAX((total_deaths/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--WHERE location like '%State%'
Group by Location, population
ORDER BY PercentPopulationInfected Desc

--Showing the countries with highest death count per population

SELECT Location, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--WHERE location like '%State%'
Where continent is not null
Group by Location
ORDER BY TotalDeathCount Desc
 
 --Let's break things down by continent
 --Showing the continent with the highest death count

 SELECT continent, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--WHERE location like '%State%'
Where continent is not null
Group by continent
ORDER BY TotalDeathCount Desc

--Global numbers

SELECT  SUM(cast(new_cases as int)) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,
	SUM(cast(new_deaths as int))/SUM(new_cases) *100 as DeathPercentage
From PortfolioProject..CovidDeaths
--WHERE location like '%State%'
Where continent is not null
--Group by date
ORDER BY 1,2

--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.location, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location Order by dea.location,
	dea.date) as RollingPeopleVaccinated,
	--(RollingPeopleVaccinated/population) * 100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
ORDER BY 2,3

--Use CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location Order by dea.location,
	dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--ORDER BY 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--Temp table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(225),
location nvarchar(225),
date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert Into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location Order by dea.location,
	dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--ORDER BY 2,3

Select *
From #PercentPopulationVaccinated

-- (not Working) Creating view to store data for later (visualization)

--Create View PercentPopulationVaccinated as 
--Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
--	SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location Order by dea.location,
--	dea.date) as RollingPeopleVaccinated
--From PortfolioProject..CovidDeaths dea
--Join PortfolioProject..CovidVaccinations vac
--	On dea.location = vac.location
--	and dea.date = vac.date
--Where dea.continent is not null
----ORDER BY 2,3

--Creating view to store data for later (visualization)

USE PortfolioProject
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

Create View PercentPopulationVaccinated 
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location Order by dea.location,
	dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--ORDER BY 2,3
)

GO