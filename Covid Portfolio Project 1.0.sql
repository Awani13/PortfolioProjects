select * 
from PortfolioProject..CovidDeaths
order by 3,4 desc

--select * 
--from PortfolioProject..CovidVaccinations
--order by 3,4 desc

select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2


--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country

select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%states'
order by 1,2


--Looking at Total Cases vs Population
--Shows what percentage of Population got covid

select Location, date, population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
where location like '%states'
order by 1,2


--Looking at Countries with highest infection rate compared to population
select Location, population, max(total_cases) as HigestInfectionCount,  max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
Group by location, population
order by PercentPopulationInfected desc


--Showing Countries With Highest Death Count per Population

select Location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
Group by location
order by  TotalDeathCount desc


-- LET'S BREAK THINGS DOWN BY CONTINENT


--Showing Continents with the highest death count per population

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
Group by continent
order by  TotalDeathCount desc


--GLOBAL NUMBERS

--Global Numbers with Date 

select date, sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths , sum(cast(new_deaths as int))/sum(new_cases) *100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%states'
where continent is not null
Group by date
order by 1,2

--Global Numbers without Date 

select sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths , sum(cast(new_deaths as int))/sum(new_cases) *100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%states'
where continent is not null
--Group by date
order by 1,2

--JOINING THE TWO TABLES

-- Looking at Total Population vs Vaccination 

Select dea.continent, dea.location, dea.date, vac.new_vaccinations,
sum(Cast(vac.new_vaccinations as bigint)) Over (Partition by dea.location Order by dea.location , dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 order by 1,2

 --USE CTE

 With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
 as
 (
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(Cast(vac.new_vaccinations as bigint)) Over (Partition by dea.location Order by dea.location , dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 --order by 1,2
 )
 Select * , (RollingPeopleVaccinated / Population) *100
 from PopvsVac


 --TEMP TABLE 

 Drop Table if exists #PecentPopualationVaccinated
 Create Table #PecentPopualationVaccinated
 (
 Continent nvarchar(55), 
 Location nvarchar(55),
 Date datetime,
 Population numeric, 
 New_Vaccinations numeric,
 RollingPeopleVaccinated numeric
 )
 Insert into #PecentPopualationVaccinated
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(Cast(vac.new_vaccinations as bigint)) Over (Partition by dea.location Order by dea.location , dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 --where dea.continent is not null
 --order by 1,2

  Select * , (RollingPeopleVaccinated / Population) *100
 from #PecentPopualationVaccinated


 -- Creating View To Store Data Later For Visualization

 Create view PecentPopualationVaccinated as
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(Cast(vac.new_vaccinations as bigint)) Over (Partition by dea.location Order by dea.location , dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 --order by 1,2

 Select * 
 from PecentPopualationVaccinated