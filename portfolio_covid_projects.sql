--select * from Portfolioproject..covid_death$
--order by 3,4

--select location,date,total_cases,new_cases,total_deaths,population
--from Portfolioproject..covid_death$
--where location='India'
--order by 3,4

--LOOKING FOR TOTAL CASES VS TOTAL DEATHS

--select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as Deathpercentage
--from Portfolioproject..covid_death$
--where location='India'


--TOTAL CASES VS POPULATION
--select location,date,population,total_cases,(total_cases/population)*100 as infection_percentage
--from Portfolioproject..covid_death$
--where location like '%india%'
--order by 1,2

--LOOKING FOR COUNTRIES WITH HIGHRST INFECTION RATE COMPARED TO POPULATION
--select location,population,MAX(total_cases) AS HIGHEST_INFECTION, MAX((total_cases/population))*100 as infection_percentagE
--from Portfolioproject..covid_death$
--GROUP BY location, population
--ORDER BY infection_percentagE DESC

--SHOWING THE COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION

--select location,MAX(cast(total_deaths as int)) AS HIGHEST_death
--from Portfolioproject..covid_death$
--where continent is not null
--GROUP BY location
--ORDER BY HIGHEST_death DESC

--select location,MAX(cast(total_deaths as int)) AS HIGHEST_death
--from Portfolioproject..covid_death$
--where continent is null
--GROUP BY location
--ORDER BY HIGHEST_death DESC

--BREAKING GLOBAL NUMBERS
--select  sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as TOTAL_DEATH, sum(cast(new_deaths as int))/ sum(new_cases)*100 as death_percentage
--from Portfolioproject..covid_death$
--where continent is not null
--group by date
--order by 1,2 

-- total population vs vacc rolling count
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.Location order by dea.location,dea.date)as rooling_vacc
from Portfolioproject..['owid-covid-data$'] vac 
join Portfolioproject..covid_death$ dea
	on vac.location=dea.location
	and dea.date=vac.date
where dea.continent is not null
order by 2,3


--use CTE
WITH  Popvsvac (continent,Location,date,population,new_vaccinations,rolling_vacc)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.Location order by dea.location,dea.date)as rooling_vacc
from Portfolioproject..['owid-covid-data$'] vac 
join Portfolioproject..covid_death$ dea
	on vac.location=dea.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select * from Popvsvac

--temp table

Drop Table if exists #percentpopulation
create table #percentpopulation
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
rolling_vacc numeric
)

insert into #percentpopulation
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
 sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.Location order by dea.location,dea.date) as rolling_vacc
from Portfolioproject..['owid-covid-data$'] vac 
join Portfolioproject..covid_death$ dea
	on vac.location=dea.location
	and dea.date=vac.date
where dea.continent is not null

select *,(rolling_vacc/population)*100 from #percentpopulation

--creating view to store data for visualization
create view percentpopulation1 as 
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
 sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.Location order by dea.location,dea.date) as rolling_vacc
from Portfolioproject..['owid-covid-data$'] vac 
join Portfolioproject..covid_death$ dea
	on vac.location=dea.location
	and dea.date=vac.date
where dea.continent is not null
