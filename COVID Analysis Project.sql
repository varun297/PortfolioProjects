Select * 
From PortfolioProject..CovidDeaths
where continent is not NULL
order by 3,4

--Select * 
--From PortfolioProject..CovidVaccinations
--order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2

--looking at Total cases vs Total Deaths
--shows likelihood of dying due to covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location like '%india%'
order by 1,2

--Looking at Total Cases vs Population
--shows what percentage of population got infected due to Covid

Select location, date, population, total_cases, (total_cases/population)*100 as AffectedPercentage
From PortfolioProject..CovidDeaths
--where location like '%states%'
order by 1,2

--looking at countries with highest infected rate to population

Select location, population, MAX(total_cases) as Highest_Infection_Count, (MAX(total_cases)/population)*100 as AffectedPercentage
From PortfolioProject..CovidDeaths
--where location like '%states%'
Group By Location, population
order by AffectedPercentage desc


--showing countries with highest death count per population

Select location, MAX(CAST(total_deaths as INT))  as Total_Death_Count
From PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not NULL
Group By Location
order by Total_Death_Count desc

--Now let's view by continet's

Select continent, MAX(CAST(total_deaths as INT))  as Total_Death_Count
From PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not NULL
Group By continent
order by Total_Death_Count desc

--GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--where location like '%india%'
where continent is not null
--Group By date
order by 1,2


--looking for total population vs total vaccinations
--usage of CTE

WITH popvsvac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) 
OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select * ,(RollingPeopleVaccinated/Population)*100
from popvsvac


--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) 
OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select * ,(RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated


--creating view for storing data for later usage

CREATE VIEW PercentPeopleVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) 
OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentPeopleVaccinated