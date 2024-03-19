select *
from PortfolioProject..CovidDeaths
Where continent is not null
order by 3, 4


--select *
--from PortfolioProject..CovidVaccinations
--order by 3, 4

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2

--looking at total cases vs total deaths

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deathpercentage
from PortfolioProject..CovidDeaths
--where location like '%states%'
and continent is not null
order by 1,2


--Looking at Total cases vs Population (Shows what percentage of population got Covid)

select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
order by 1,2

--Looking at Countries with Highest Infection Rate combared to Population

select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
Group by location, population
order by PercentPopulationInfected desc


-- Showing Countries with Highest Death count per Population

select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by location
order by TotalDeathCount desc

-- Showing Continents with the Highest Death count per population 

select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc


--Global Numbers

select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int))as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Deathpercentage
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
Group by date
order by 1,2



--Looking at Total Population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
   on dea.location=vac.location
   and dea.date=vac.date
where dea.continent is not null
   order by 1,2,3

   --USE CTE

   with  PopvsVac (continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
   as
   (
   select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
   on dea.location=vac.location
   and dea.date=vac.date
where dea.continent is not null
   --order by 1,2,3
   )
   Select *, (RollingpeopleVaccinated/Population)*100
   From PopvsVac

   
   --Temp Table

   Drop table if exists ##PercentPopulationVaccinated
   Create Table #PercentPopulationVaccinated
   (
   Continent nvarchar(255),
   Location nvarchar(255),
   Date datetime,
   Population numeric,
   New_vaccinations numeric,
   RollingPeopleVaccinated numeric
   )


   Insert into #PercentPopulationVaccinated
   select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
   on dea.location=vac.location
   and dea.date=vac.date
where dea.continent is not null
   --order by 1,2,3

    Select *, (RollingpeopleVaccinated/Population)*100
   From #PercentPopulationVaccinated



   --Creating view to store data for later visualizations

   Create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
   on dea.location=vac.location
   and dea.date=vac.date
where dea.continent is not null
   --order by 2,3

   select *
   From	PercentPopulationVaccinated