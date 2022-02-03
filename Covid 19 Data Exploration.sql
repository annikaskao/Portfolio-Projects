/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

Select * 
From PortfolioProject.coviddeaths
Order By 3,4;

-- Select data we are going to be starting with
Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject.coviddeaths
Where continent is not null 
Order by 1,2;

-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid in your contry
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject.coviddeaths
Where continent is not null 
Order by 1,2;

 -- Looking at Total Cases vs Total Deaths in United States 
 -- Shows the likelihood of dying if you contract covid in United States
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject.coviddeaths
Where Location like '%states%'
And continent is not null 
Order by 1,2;

-- Looking at Total Cases vs Populations
-- Shows what percentage of population got Covid
Select Location, date, total_cases, population, (total_cases/population)*100 as DeathPercentage
From PortfolioProject.coviddeaths
Order by 1,2;

-- Looking at Total Cases vs Populations for United States
-- Shows what percentage of population got Covid
Select Location, date, total_cases, population, (total_cases/population)*100 as DeathPercentage
From PortfolioProject.coviddeaths
Where Location like '%states%'
Order by 1,2;

-- Looking at Countries with Highest Infection Rate compared to Population
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject.CovidDeaths
Where continent is not null 
Group by Location, Population
Order by PercentPopulationInfected desc;


-- Countries with Highest Death Count per Population
Select Location, MAX(total_deaths) as TotalDeathCount
From PortfolioProject.CovidDeaths
Where continent is not null 
Group by Location
Order by TotalDeathCount desc;

-- LET'S BREAK THINGS DOWN BY CONTINENT

-- Showing the continents with the highest death count by population
Select Location, MAX(total_deaths) as TotalDeathCount
From PortfolioProject.CovidDeaths
Where continent is null 
And location not in ('World', 'European Union', 'International', 'Upper middle income', 'High income', 'Lower middle income', 'Low income')
Group by Location
Order by TotalDeathCount desc;

-- GLOBAL NUMBERS

-- Death percentages by date
Select date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, (SUM(new_deaths)/SUM(new_cases))*100 as DeathPercentage
From PortfolioProject.coviddeaths
Where continent is not null
Group by date
Order by 1,2;

-- Probability of dying if covid is contracted globally
Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, (SUM(new_deaths)/SUM(new_cases))*100 as DeathPercentage
From PortfolioProject.coviddeaths
Where continent is not null
Order by 1,2;

-- Looking at Total Population vs. Total Vaccination
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
Select *
From PortfolioProject.coviddeaths dea
Join PortfolioProject.covidvaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3;


-- Using CTE to perform Calculation on Partition By in previous query
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated 
-- ,(RollingPeopleVaccinated/population)*100
From PortfolioProject.coviddeaths dea
Join PortfolioProject.covidvaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date
Where dea.continent is not null 
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac;

-- Create Table PercentPopulationVaccinated
-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists PercentPopulationVaccinated;
Create Table PercentPopulationVaccinated 
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
);
Insert into PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
From PortfolioProject.coviddeaths dea
Join PortfolioProject.covidvaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date;

Select *, (RollingPeopleVaccinated/Population)*100
From PercentPopulationVaccinated;

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinatedV as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
From PortfolioProject.coviddeaths dea
Join PortfolioProject.covidvaccinations vac	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

