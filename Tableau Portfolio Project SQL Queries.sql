/*
Queries used for Tableau Project
*/

-- 1.

Select dea.continent, dea.location, dea.date, dea.population, MAX(vac.total_vaccinations) as RollingPeopleVaccinated
From PortfolioProject.coviddeaths dea
Join PortfolioProject.covidvaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date
Where dea.continent is not null 
Group by dea.continent, dea.location, dea.date, dea.population
Order by 1,2,3;




-- 2.

Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject.coviddeaths
Where continent is not null 
Order by 1,2;


-- 3.

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

Select location, SUM(new_deaths) as TotalDeathCount
From PortfolioProject.coviddeaths
Where continent is null 
And location not in ('World', 'European Union', 'International')
Group by location
Order by TotalDeathCount desc;



-- 4.

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject.coviddeaths
Group by Location, Population
Order by PercentPopulationInfected desc;



-- 5.

--  Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
-- From PortfolioProject.coviddeaths
-- Where continent is not null 
-- Order by 1,2

-- took the above query and added population
Select Location, date, population, total_cases, total_deaths
From PortfolioProject.coviddeaths
Where continent is not null 
Order by 1,2;


-- 6. 


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
Select *, (RollingPeopleVaccinated/Population)*100 as PercentVaccinated
From PopvsVac;


-- 7. 

Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject.coviddeaths
Group by Location, Population, date
Order by PercentPopulationInfected desc;