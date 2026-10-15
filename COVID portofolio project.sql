select *
from PortifolioProject..CovidDeaths
where continent is not null


-- select * 
-- from PortifolioProject..CovidVaccinations
-- order by 3,4

-- select data that we going to using

select location,date, total_cases, new_cases, total_deaths, population
from PortifolioProject..CovidDeaths
order by 1,2
where continent is not null


-- Looking at Total Casses vs Total Deaths
-- Show likelihood of dying if you contract covid in your country
select location,date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortifolioProject..CovidDeaths
where location like '%indonesia%'
where continent is not null
order by 1,2


-- Looking at Total Cases vs Total Population
-- Show what percentage of population got covid
select location,date, total_cases, population, (total_cases/population)*100 as PercentagePopulatationInfected
from PortifolioProject..CovidDeaths
where location like '%indonesia%'
order by 1,2

-- Looking at Countries with Heighest Infection Rate compared to Population

select location,population, max (total_cases) as HighesInfectionCount, max (total_cases/population)*100 as 
PercentagePopulatationInfected
from PortifolioProject..CovidDeaths
-- where location like '%indonesia%'
group by location, population
order by PercentagePopulatationInfected desc

-- Showing Countries with Heighest Infection Rate compared to Population
select location,max(cast (Total_deaths as int)) as TotalDeathCount
from PortifolioProject..CovidDeaths
-- where location like '%indonesia%'
where continent is not null
group by location
order by TotalDeathCount desc

-- Let's BREAK THINGS DOWN BY CONTINENT



-- Showing contintents with the highest death count per population

select continent,max(cast (Total_deaths as int)) as TotalDeathCount
from PortifolioProject..CovidDeaths
-- where location like '%indonesia%'
where continent is not null
group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBER
select SUM(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 
as DeathPercentage
from PortifolioProject..CovidDeaths
-- where location like '%indonesia%'
where continent is not null
-- GROUP BY DATE
order by 1,2

-- menggaungkan 2 tabel
-- melihat total vaksinasi vs populasi
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert (int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortifolioProject..CovidDeaths dea
join PortifolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- PAKAI CTE

with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert (int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortifolioProject..CovidDeaths dea
join PortifolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- order by 2,3
)
select * , (RollingPeopleVaccinated/population)*100
from PopvsVac

-- TABEL SEMENTARA
drop table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(225),
location nvarchar(225),
date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert (int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortifolioProject..CovidDeaths dea
join PortifolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
-- order by 2,3

select * , (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

-- Create View to store data for  later visualizations

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert (int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortifolioProject..CovidDeaths dea
join PortifolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from PercentPopulationVaccinated
