--select * from [portfolio projects]..['covid death$']
 order by 3,4


--select * from [portfolio projects]..['covid vaccinations$']
order by 3,4



--selecting data am using

select location,date,total_cases,
new_cases,total_deaths,population from
 [portfolio projects]..['covid death$']
 where continent is not null
order by 1,2


--total cases and total deaths
select location, date, total_cases,
total_deaths, (total_deaths/total_cases)*100 as percentage_deaths
 from
 [portfolio projects]..['covid death$']
 where continent is not null
order by 1,2

---total cases and total deaths in states
select location, date, total_cases,
total_deaths, (total_deaths/total_cases)*100 as percentage_deaths
 from
 [portfolio projects]..['covid death$'] where location like '%states%'
 and continent is not null
order by 1,2


---total cases and population
select location, date, total_cases,
population, (total_cases/population)*100 as percentage_population
 from
 [portfolio projects]..['covid death$']
 where continent is not null
order by 1,2 

---total cases and population in states
select location, date,
population,total_cases, (total_cases/population)*100 as percentage_population
 from
 [portfolio projects]..['covid death$'] where location like '%states%'
 and continent is not null
order by 1,2


---countries with the highest infection
select location,population, max (total_cases) as highestinfectioncount, 
max(total_cases/population)*100 as percentage_population_infected
 from
 [portfolio projects]..['covid death$']
 where continent is not null
 group by location,population
order by percentage_population_infected desc

---countries with highest deaths per population
select location,max(total_deaths) as total_deaths_count
 from
 [portfolio projects]..['covid death$']
 where continent is not null
 group by location
order by total_deaths_count desc

---cast total deaths as int due to result is not accurate
select location,max(cast(total_deaths as int)) as total_deaths_count
 from
 [portfolio projects]..['covid death$']
 where continent is not null
 group by location
order by total_deaths_count desc

---continent with the highest count per population
select continent,max(cast(total_deaths as int)) as total_deaths_count
 from
 [portfolio projects]..['covid death$']
 where continent is not null
 group by continent
order by total_deaths_count desc

---global result
select date,sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percentage
 from
 [portfolio projects]..['covid death$']
 where continent is not null
 group by date
order by 1,2

select sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percentage
 from
 [portfolio projects]..['covid death$']
 where continent is not null
-- group by date
order by 1,2

---total population and vaccination
select cod.continent,cod.location,cod.date,cod.population,cov.new_vaccinations
, sum(convert(float,cov.new_vaccinations)) over (partition by cod.location order by cod.location,cod.date)
as addedpeoplevaccinated
 from
 [portfolio projects]..['covid death$'] cod
 join [portfolio projects]..['covid vaccinations$'] cov
 on cod.location = cov.location
 and cod.date = cov.date
 where cod.continent is not null
order by 2,3

---CTE

with popvac(continent,location,date,population,new_vaccinations,addedpeoplevaccinated)
as
(
select cod.continent,cod.location,cod.date,cod.population,cov.new_vaccinations
, sum(convert(float,cov.new_vaccinations)) over (partition by cod.location order by cod.location,cod.date)
as addedpeoplevaccinated
 from
 [portfolio projects]..['covid death$'] cod
 join [portfolio projects]..['covid vaccinations$'] cov
 on cod.location = cov.location
 and cod.date = cov.date
 where cod.continent is not null
--order by 2,3
)
select *, (addedpeoplevaccinated/population)*100 from popvac


---temp table
drop table if exists #percentagepopulationvaccinated
create table #percentagepopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
addedpeoplevaccinated numeric
)
insert into #percentagepopulationvaccinated
select cod.continent,cod.location,cod.date,cod.population,cov.new_vaccinations
, sum(convert(float,cov.new_vaccinations)) over (partition by cod.location order by cod.location,cod.date)
as addedpeoplevaccinated
 from
 [portfolio projects]..['covid death$'] cod
 join [portfolio projects]..['covid vaccinations$'] cov
 on cod.location = cov.location
 and cod.date = cov.date
-- where cod.continent is not null
--order by 2,3

select *, (addedpeoplevaccinated/population)*100 from #percentagepopulationvaccinated

 
---creating view for data visualisation

create view percentagepopulationvaccinated as  
select cod.continent,cod.location,cod.date,cod.population,cov.new_vaccinations
, sum(convert(float,cov.new_vaccinations)) over (partition by cod.location order by cod.location,cod.date)
as addedpeoplevaccinated
 from
 [portfolio projects]..['covid death$'] cod
 join [portfolio projects]..['covid vaccinations$'] cov
 on cod.location = cov.location
 and cod.date = cov.date
 where cod.continent is not null
--order by 2,3

---creating view for highest population count
create view highest_population as
select continent,max(cast(total_deaths as int)) as total_deaths_count
 from
 [portfolio projects]..['covid death$']
 where continent is not null
 group by continent
--order by total_deaths_count desc

---creating view for global result
create view global_result as
select date,sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percentage
 from
 [portfolio projects]..['covid death$']
 where continent is not null
 group by date
---order by 1,2
