

show GLOBAL VARIABLES like 'local_infile';
SET GLOBAL local_infile = 'ON' ;
show GLOBAL VARIABLES like 'local_infile';

use portfolioprojects ;

-- LOAD DATA LOCAL INFILE 'C:/new downloads/CovidDeaths.csv'
-- INTO TABLE coviddeaths
-- FIELDS TERMINATED BY ','
-- ENCLOSED BY '"'
-- LINES TERMINATED BY '\n'
-- IGNORE 1 ROWS;

SELECT COUNT(*) FROM coviddeaths ; 


-- LOAD DATA LOCAL INFILE 'C:/new downloads/covidvaccination.csv'
-- INTO TABLE covidvaccination
-- FIELDS TERMINATED BY ','
-- ENCLOSED BY '"'
-- LINES TERMINATED BY '\n'
-- IGNORE 1 ROWS;
desc covidvaccination  ;
SELECT COUNT(*) FROM covidvaccination  ;


select * from coviddeaths ; 
-- lets chage the data type column date to datetime format 


SELECT location , date , total_cases , new_cases , total_deaths , population 
from coviddeaths order by 1, 2;


--  looking at total_cases vs total _deaths 
-- shows likelihood of dying if u contract covid in you country
 SELECT location , date  , total_cases , total_deaths, (total_deaths/total_cases)*100  as Death_percentage from coviddeaths 
 where location like '%India%'
 order by 1,2  ; 
 
 -- looking at total cases vs population 
 -- shows what percentage of population got infected with covid -- 
 SELECT location , date  , population,  total_cases , (total_cases/population)*100  as infected_percentage  
 from coviddeaths 
where location like '%India%'
and continent is not null
order by 1,2  ; 
 
 -- what country has the hoghest infection rates compared to population 
 
SELECT location , population,  max(total_cases) as HighestInfectionCount ,max((total_cases/population)*100)  as percentagePopulationInfected
from coviddeaths 
group by location , population
order by  percentagePopulationInfected desc; 
 
 --  showing the coutries with highest death count per population 

 
UPDATE  coviddeaths 
set continent = NULL
where continent= '' ;


  SELECT location  , 
 max(cast(total_deaths as signed )) as totaldeathcount
 from coviddeaths 
where continent is not null 
group by location 
order by   totaldeathcount desc;


-- lets break things down by continent 
SELECT continent  , 
max(cast(total_deaths as signed )) as totaldeathcount
from coviddeaths 
where continent is not null and location not like '%income%'
group by continent 
order by   totaldeathcount desc;

SELECT location   , 
max(cast(total_deaths as signed )) as totaldeathcount
from coviddeaths 
where continent is  null and location  not like '%income%'
group by location 
order by   totaldeathcount desc;


-- Global numbers 

 SELECT   STR_TO_DATE(date, '%m/%d/%Y') AS formatted_date,sum(new_cases) as TOtal_new_cases , sum(cast(new_deaths as signed )) as Total_new_deaths, sum(cast(new_deaths as signed))/sum(cast(new_cases as signed))*100 as deathPercentage --  total_deaths, (total_deaths/total_cases)*100  as Death_percentage 
 from coviddeaths 
 where continent is not null
 group by date
 order by 1,2  ;
 
 
 select * 
 from coviddeaths dea 
 join covidvaccination vac 
 on dea.location= vac.location 
 and dea.date = vac.date ;

-- lloking at total population vs vacciation 
update covidvaccination 
set new_vaccinations = null
where new_vaccinations='';


SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS SIGNED)) OVER 
        (PARTITION BY dea.location ORDER BY dea.date) AS rolling_people_vaccinated 
FROM 
    coviddeaths dea 
JOIN 
    covidvaccination vac ON dea.location = vac.location AND dea.date = vac.date 
WHERE 
    dea.continent IS NOT NULL 
ORDER BY 
    dea.location, 
    dea.date;





--  use CTE
WITH PopvsVac AS (
    SELECT 
        dea.continent, 
        dea.location, 
        dea.date, 
        dea.population, 
        vac.new_vaccinations,
        SUM(CAST(vac.new_vaccinations AS SIGNED)) OVER 
            (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated 
    FROM 
        coviddeaths dea 
    JOIN 
        covidvaccination vac ON dea.location = vac.location AND dea.date = vac.date 
    WHERE 
        dea.continent IS NOT NULL 
)
SELECT * , (rolling_people_vaccinated/population)*100
FROM PopvsVac;




-- creating view to store data for later visualizations 
create view  PercentPopulationVccinated  as 
select dea.continent , dea.location , 
str_to_date(dea.date , '%m/%d/%Y') as formatted_date, dea.population , vac.new_vaccinations ,
sum(cast(vac.new_vaccinations as signed )) over (partition by dea.location ,dea.date) as rollingPeopleVaccinated 
from coviddeaths dea 
join covidvaccination vac 
  on   dea.location= vac.location 
  and str_to_date(dea.date , '%m/%d/%Y') =  str_to_date(vac.date , '%m/%d/%Y')
  where dea.continent is not null ; 


select * from percentpopulationvccinated;


    
    
