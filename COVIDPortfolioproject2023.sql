--Today we start our Data Analyst Portfolio Project Series.
SELECT * 
From PortfolioProject..CovidDeaths$
order by 3,4

--select * 
--from portfolioproject..CovidVaccinations$
--order by 3,4

--Select data that we are going to be using
SELECT Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths$
order by 1,2

-- Looking at total cases vs Total Deaths
-- Shows likehood of dying if you contac covid in your country
SELECT Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
Where Location like '%Argentina%'
order by 1,2

-- Looking at total cases vs Population
-- Shows what percentage of population got covid
SELECT Location, date, total_cases,Population, (total_cases/population)*100 as PopulationpercentageInfected
From PortfolioProject..CovidDeaths$
Where Location like '%Argentina%'
order by 1,2

-- Looking at countries with highiest infection rate compared to population
SELECT Location,Population,MAX (total_cases) as HighestInfectionCount, MAX  ((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths$
Group by Location, Population
order by PercentPopulationInfected desc


-- Let´s break things down by continent
Select Location, MAX (cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
Where continent is null
Group by Location
order by TotalDeathCount desc

-- Showing Countries with highest death count per population
Select Location, MAX (cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
Where continent is not null
Group by Location
order by TotalDeathCount desc


-- Showing continents with the highest death count per population
Select Continent,MAX (cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
Where continent is not null
Group by Continent
order by TotalDeathCount desc


-- looking at total population vs vaccinations
Select dea.Continent, dea.Location, dea.Date, dea.Population, vac.new_vaccinations,
SUM (CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
    dea.Date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.Location = vac.Location
	and dea.Date=vac.Date
where dea.Continent is not null
order by 2,3

--USE CTE

WITH PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.Continent, dea.Location, dea.Date, dea.Population, vac.new_vaccinations,
SUM (CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
    dea.Date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.Location = vac.Location
	and dea.Date=vac.Date
where dea.Continent is not null
)
select *, (RollingPeopleVaccinated/Population)*100 as RollingPeopleVaccPercentage
from PopvsVac

--Temp Table

Drop Table if exists #PercentPopulationVaccinated 
Create Table #PercentPopulationVaccinated 
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated 
Select dea.Continent, dea.Location, dea.Date, dea.Population, vac.new_vaccinations,
SUM (CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
    dea.Date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.Location = vac.Location
	and dea.Date=vac.Date
where dea.Continent is not null

select *, (RollingPeopleVaccinated/Population)*100 as RollingPeopleVaccPercentage
from #PercentPopulationVaccinated 


-- Global Numbers
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast
	(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where continent is not null
order by 1,2


--Creating view to store data for later visualizations

Create view PercentPopulationVaccinated as 
Select dea.Continent, dea.Location, dea.Date, dea.Population, vac.new_vaccinations,
SUM (CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
    dea.Date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.Location = vac.Location
	and dea.Date=vac.Date
where dea.Continent is not null

Select *
From PercentPopulationVaccinated
