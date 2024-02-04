select*
from PortfolioProject..CovidDeaths
where continent IS NOT NULL
order by 3,4

--select*
--from PortfolioProject..CovidVaccinations
--order by 3,4

--Select data that we are going to be using

Select Location, date, total_cases, total_deaths,population
from PortfolioProject..CovidDeaths
order by 1,2

--Looking at Total deaths VS Total cases

-- shows the likelihood of dying if you contact covid in United Kingdom
Select Location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%kingdom%'and continent is not null
order by 1,2

--Looking at total cases VS population
-- show what percentage of the population contracted covid
Select Location, date,population, total_cases,(total_cases / population)*100 as InfectionRate
from PortfolioProject..CovidDeaths
where location like '%kingdom%' and continent is not null

order by 1,2

--looking at countries with higest infection rate compared to population

Select Location,population, MAX(total_cases)as HighestInfectionCount,MAX(total_cases / population)*100 as InfectionRate
from PortfolioProject..CovidDeaths
--where location like '%kingdom%'
where continent IS NOT NULL
Group by population, location
order by InfectionRate desc

--Showing the countries with the hightest deathcount per population
Select Location, MAX(cast(total_deaths as int))as TotaldeathCount
from PortfolioProject..CovidDeaths
where continent IS NOT NULL
Group by population, location
order by TotaldeathCount desc

-- Let break things down by continent
Select Location, MAX(cast(total_deaths as int))as TotaldeathCount
from PortfolioProject..CovidDeaths
where continent IS NULL
Group by location
order by TotaldeathCount desc

--Global numbers
Select sum (new_cases)as Total_cases, sum(cast(new_deaths as int)) as Total_deaths,(sum(cast(new_deaths as int))/sum (new_cases))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
--group by date
order by 1,2

--Global numbers by date
Select date, sum (new_cases)as Total_cases, sum(cast(new_deaths as int)) as Total_deaths,(sum(cast(new_deaths as int))/sum (new_cases))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2

-- Looking at total population VS Vaccination
select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations))over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on  dea.location = vac.location
and dea.date= vac.date
where dea.continent is not null
order by 2,3
	
-- Using CTE
with popvsvac ( continent,location,Date,Population,New_Vacciations,RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations))over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on  dea.location = vac.location
and dea.date= vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
from popvsvac

--Temp table

Drop table if exists #PercentpopulationVaccinated
create table #PercentpopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_Vaccination numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentpopulationVaccinated
select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations))over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on  dea.location = vac.location
and dea.date= vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
from #PercentpopulationVaccinated


--Creating View to store data for later Visualisations

Drop View if exists PercentPopulationVaccinated
Create view PercentPopulationVaccinated as

select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations))over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on  dea.location = vac.location
and dea.date= vac.date
where dea.continent is not null
--order by 2,3