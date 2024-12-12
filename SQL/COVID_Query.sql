-- Select Data that we are going to be using
Select Location, Date, total_cases, new_cases,total_deaths,population,continent
From PortfolioProject..CovidDeaths
order by 1,2


-- Calculating the DeathPercentage
Select Location, Date, total_cases,total_deaths,  (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where Location='Argentina'
order by 1,2

-- Looking Total Cases vs Population
Select Location, Date, total_cases,population,(total_cases/population)*100 as CasesPercentage
From PortfolioProject..CovidDeaths
where Location='Argentina'
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population
Select Location,population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by Location,population
order by PercentPopulationInfected DESC

-- Showing countries with highest Death count per Population
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by Location
order by TotalDeathCount DESC

-- By continent
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is null
Group by location
order by TotalDeathCount DESC

-- Looking at total population vs Vaccinations

-- USING CTE
With PopvsVac (Continent,Location,Date,Population,New_Vaccinations,RollingPeopleVaccinated)
as (
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location 
	Order by dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac 
	ON dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null 
)
select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location 
	Order by dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac 
	ON dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null 

Select *
From PercentPopulationVaccinated