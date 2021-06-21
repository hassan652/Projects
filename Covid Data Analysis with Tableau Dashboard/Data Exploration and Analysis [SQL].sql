/*
Covid 19 Data Exploration 
*/

SELECT *
FROM Projects..[covid-vaccinations]
Where continent is not null 
order by 3,4

SELECT *
FROM projects..[covid-deaths];


--Covid Deaths Table
Select *
From projects..[covid-deaths]
Where continent is not null 
order by location,date;


--Covid Vaccinations Table
Select *
From projects..[covid-vaccinations]
Where continent is not null 
order by location,date


-- Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From Projects..[covid-deaths]
Where continent is not null 
order by location, date


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in Germany

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Projects..[covid-deaths]
Where location like '%germany%'
and continent is not null 
order by location, date


-- Total Cases vs Population

-- Shows what percentage of population infected with Covid

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From Projects..[covid-deaths]
--Where location like '%germany%'
order by location, date


-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From projects..[covid-deaths]
--Where location like '%germany%'
Group by Location, Population
order by PercentPopulationInfected desc


-- Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From Projects..[covid-deaths]
--Where location like '%germany%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc


-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From Projects..[covid-deaths]
--Where location like '%germany%'
Where continent is null 
Group by location
order by TotalDeathCount desc


-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From projects..[covid-deaths]
--Where location like '%germany%'
where continent is not null 
--Group By date
--order by location, date


-- Total Population vs Vaccinations

-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, 
			  Convert(date,dea.date)) as RollingPeopleVaccinated
From Projects..[covid-deaths] dea
Join Projects..[covid-vaccinations] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by  dea.location, dea.date



-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, 
			CAST(dea.Date as date)) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From projects..[covid-deaths] dea
Join Projects..[covid-vaccinations] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac
--where location = 'Germany'



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, 
              cast(dea.Date as date)) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From projects..[covid-deaths] dea
Join Projects..[covid-vaccinations] vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100 as PercentagePeopleVaccinated
From #PercentPopulationVaccinated
order by 2,3




-- Creating View to store data for later visualizations
--DROP TABLE IF EXISTS
Create View 
PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, 
      CONVERT(date, dea.Date) )as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From projects..[covid-deaths] dea
Join projects..[covid-vaccinations] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

select * from PercentPopulationVaccinated


--Creating view for continent wise cases

CREATE VIEW	Continentnumbers as 
Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From Projects..[covid-deaths]
--Where location like '%germany%'
Where continent is null 
Group by location
--order by TotalDeathCount desc

select * from Continentnumbers


--Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types