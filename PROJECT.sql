--Data Selecting
select*
from SQLproject..DEATH$
where continent is not null
order by 1,2

--select*
--from SQLproject..VAKSIN
--order by 1,2

select location, date, total_cases,new_cases, total_deaths, population
from SQLproject..DEATH$
where continent is not null
order by 1,2

--Total Cases vs Total Deaths (Likelihood of Dying contract covid in Afghanistan)
select location, date, total_cases, total_deaths, (convert(float,total_deaths)/nullif(convert(float, total_cases),0))*100 as DeathPercentage
from SQLproject..DEATH$
where continent is not null and location like '%Ind%'
order by 1,2

--Total Cases vs Population (percentage pupulation got Covid)
select location, date, total_cases, population, (convert(float,total_cases)/nullif(convert(float, population),0))*100 as PupulationInfected
from SQLproject..DEATH$
where continent is not null and location like '%Ind%'
order by 1,2

--Country with Highest Infection compared to Population
select location, population, Max(total_cases) as HighestInfectedCount, max(convert(float,total_cases)/nullif(convert(float, population),0))*100 as PercentPupulationInfected
from SQLproject..DEATH$
where continent is not null and location like '%Ind%'
group by location, population
order by PercentPupulationInfected desc

--Showing Country With the highest Death count by continent
select continent, Max(cast(total_deaths as int)) as TotalDeathCount
from SQLproject..DEATH$
where continent is not null
group by continent
order by TotalDeathCount desc

--Continent with highest death count per population
select continent, Max(cast(total_deaths as int)) as TotalDeathCount
from SQLproject..DEATH$
where continent is not null
group by continent
order by TotalDeathCount desc

--Global Numbers
select 
sum(new_cases) AS total_cases, 
sum(cast(new_deaths as int)) AS total_deaths, 
(sum(cast(new_deaths as int))/nullif(sum(new_cases),0)*100) as DeathPercentage
from SQLproject..DEATH$
where continent is not null
--where location like '%Ind%'
--Group by date
order by 1,2





--Total Population vs vaccinations
select* from SQLproject..VAKSIN

SELECT dea.continent,
       dea.date,
       dea.population,
       vak.F32 AS NewFaccinate,
       SUM(CONVERT(INT, vak.F32)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleFaccinated,
       (SUM(CONVERT(INT, vak.F32)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) / dea.population) * 100
FROM SQLproject..DEATH$ dea
JOIN SQLproject..VAKSIN vak ON dea.location = vak.F3 AND dea.date = vak.F4
WHERE dea.continent IS NOT NULL
ORDER BY dea.date, dea.population

--USE CTE
WITH PopvsVac (Continent, location, date, population, new_vaccinated, RollingPeopleFaccinated)
AS
(
    SELECT dea.continent,
           dea.location,
           dea.date,
           dea.population,
           vak.F32 AS NewFaccinate,
           SUM(CONVERT(INT, vak.F32)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleFaccinated
		   --,(SUM(CONVERT(INT, vak.F32)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) / dea.population) * 100
    FROM SQLproject..DEATH$ dea
    JOIN SQLproject..VAKSIN vak ON dea.location = vak.F3 AND dea.date = vak.F4
    --WHERE dea.continent IS NOT NULL
)

SELECT *, (RollingPeopleFaccinated/population)*100
FROM PopvsVac

--Temp Table

drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated 
(
Continent  nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
New_vaccinated numeric,
RollingPeopleFaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent,
           dea.location,
           dea.date,
           dea.population,
           vak.F32 AS NewFaccinate,
           SUM(CONVERT(INT, vak.F32)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleFaccinated
		   --,(SUM(CONVERT(INT, vak.F32)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) / dea.population) * 100
    FROM SQLproject..DEATH$ dea
    JOIN SQLproject..VAKSIN vak ON dea.location = vak.F3 AND dea.date = vak.F4
    --WHERE dea.continent IS NOT NULL
	--order by 2,3

SELECT *, (RollingPeopleFaccinated/population)*100
FROM #PercentPopulationVaccinated


--Creating View to store data for Visualizations

GO
CREATE VIEW PercentPopulationVaccination AS
SELECT dea.continent,
       dea.location,
       dea.date,
       dea.population,
       vak.F32 AS NewFaccinate,
       SUM(CONVERT(INT, vak.F32)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleFaccinated
FROM SQLproject..DEATH$ dea
JOIN SQLproject..VAKSIN vak ON dea.location = vak.F3 AND dea.date = vak.F4
WHERE dea.continent IS NOT NULL;


select*
from PercentPopulationVaccination

