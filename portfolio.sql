select *
from CovidVaccinations$
--order by 3,4

--select*
--from CovidDeaths$
--where continent is not null
--order by 3,4

--select location,date,total_cases,new_cases,total_deaths,population
--from CovidDeaths$
--where continent is not null
--order by 1,2

--total cases vs total deaths

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as Deathpercentage
from CovidDeaths$
where location like '%India%'
where continent is not null
order by 1,2

--Total cases vs Population
--shows what percentage of population got covid

select location,date,population,total_cases,(total_cases/population)*100 as percent_population_affected
from CovidDeaths$
--where location like '%India%'
where continent is not null
order by 1,2

--Countries with highest infection rate compared to population

select location,population,max(total_cases)as highestinfectioncount,max((total_cases/population))*100 as percent_population_affected
from CovidDeaths$
--where location like '%India%'
where continent is not null
group by population,location
order by percent_population_affected desc

--Countries with highest death count per population

select location, max(cast(total_deaths as int)) as Totaldeathcount
from CovidDeaths$
--where location like '%India%'
where continent is not null
group by location
order by Totaldeathcount desc

--Let's break things down by continent


--showing continents with the highest death count per population

select continent,max(cast(total_deaths as int)) as Totaldeathcount
from CovidDeaths$
--where location like '%India%'
where continent is not null
group by continent
order by Totaldeathcount desc

--Global numbers

select date,sum(new_cases)as total_cases,sum(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/sum(new_cases)*100 as death_percentage
from CovidDeaths$
--where location like '%India%'
where continent is not null
group by date
order by 1,2

--Looking at total population vs vaccination


Select dea.continent, dea.location, dea.date , dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location) as totalpopulationvaccinated
--,(totalpopulationVaccinated/population)*100
From CovidDeaths$ dea
Join CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3





-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations,totalpopulationvaccinated )
as
(
Select dea.continent, dea.location, dea.date , dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location) as totalpopulationvaccinated
--,(totalpopulationVaccinated/population)*100
From CovidDeaths$ dea
Join CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (totalpopulationvaccinated/Population)*100 percentpopulationvaccinated
From PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Vaccinated numeric,
totalpopulationvaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date , dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location) as totalpopulationvaccinated
--,(totalpopulationVaccinated/population)*100
From CovidDeaths$ dea
Join CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3


Select *, (totalpopulationvaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated1 as
Select dea.continent, dea.location, dea.date , dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location) as totalpopulationvaccinated
--,(totalpopulationVaccinated/population)*100
From CovidDeaths$ dea
Join CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3



