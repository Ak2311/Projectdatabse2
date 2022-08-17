SELECT *
FROM ProjectDatabase..CovidDeaths$
Where continent is not null
ORDER BY 3,4

--SELECT *
--FROM ProjectDatabase..CovidVaccinations$
--ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM ProjectDatabase..CovidDeaths$
order by 1,2

--Total cases vs Total deaths

SELECT location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM ProjectDatabase..CovidDeaths$
where location like '%states%'
order by 1,2

--Total cases vs Population

SELECT location, date, population, total_cases,(total_cases/population)*100 as CasesPercentage
FROM ProjectDatabase..CovidDeaths$
--where location like '%states%'
order by 1,2


SELECT location, population, MAX(total_cases) as HighestInfection, MAX((total_cases/population))*100 as PopulationPercentageInfected
FROM ProjectDatabase..CovidDeaths$
--where location like '%states%'
Group by location, population
order by PopulationPercentageInfected desc

--Countries with highest death count

SELECT location, MAX(cast(total_deaths as int)) as Totaldeathcount
FROM ProjectDatabase..CovidDeaths$
--where location like '%states%'
Where continent is not null
Group by location
order by Totaldeathcount desc

-- According to Continents

SELECT continent, MAX(cast(total_deaths as int)) as Totaldeathcount
FROM ProjectDatabase..CovidDeaths$
--where location like '%states%'
Where continent is not null
Group by continent
order by Totaldeathcount desc

-- Global numbers

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
FROM ProjectDatabase..CovidDeaths$
where continent is not null
--group by date
order by 1,2


-- total population vs vaccination

select dea.continent, dea.location, dea.date, dea.population ,vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date) as RollingCountofVaccination
from ProjectDatabase..CovidDeaths$ dea
join ProjectDatabase..CovidVaccinations$ vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3 

--use cte

with popvsVac (Continent, location, date, population, new_vaccinations, RollingCountofVaccination)
as 
(
select dea.continent, dea.location, dea.date, dea.population ,vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date) as RollingCountofVaccination
--(RollingCountofVaccination/population)*100
from ProjectDatabase..CovidDeaths$ dea
join ProjectDatabase..CovidVaccinations$ vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3 
)
select *, (RollingCountofVaccination/population)*100 
from popvsVac


--temp table

DROP TABLE if exists #PercentPopulationsVaccinated
Create Table #PercentPopulationsVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
date datetime,
Population numeric,
new_vaccinations numeric,
RollingCountofVaccination numeric
)

Insert into #PercentPopulationsVaccinated
select dea.continent, dea.location, dea.date, dea.population ,vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date) as RollingCountofVaccination
--, (RollingCountofVaccination/population)*100
from ProjectDatabase..CovidDeaths$ dea
join ProjectDatabase..CovidVaccinations$ vac
    on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3 

select *, (RollingCountofVaccination/population)*100 
from #PercentPopulationsVaccinated


--create view to store data visaulization

Create View PercentPopulationsVaccinated as
select dea.continent, dea.location, dea.date, dea.population ,vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date) as RollingCountofVaccination
--, (RollingCountofVaccination/population)*100
from ProjectDatabase..CovidDeaths$ dea
join ProjectDatabase..CovidVaccinations$ vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 


select *
from PercentPopulationsVaccinated