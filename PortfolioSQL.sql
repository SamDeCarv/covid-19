#Covid 19 Data Exploration

#Skills  used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

#Small Country is under 10 million people
#Medium country 10 million and above and below 100 million people
#Large country is 100 Million people and above.

# In order to compare countries of different sizes equally, the comparisons will be done by percentages. 

SELECT *
FROM portfolioproject.coviddeaths
WHERE continent is not null
order by 3,4; 

# I need to set my dates to date values rather than string so I'm going to make a temp table that I can refer to throughout the query.
DROP TABLE IF Exists tempdate;

DROP TABLE IF Exists tempdate2;

CREATE TEMPORARY TABLE tempdate AS 
SELECT 
	str_to_date(date, '%m/%d/%Y') as formatted_date,
    Location,
    population,
    total_cases, 
    new_cases, 
    total_deaths, 
    new_deaths,
    continent
FROM portfolioproject.coviddeaths;

CREATE TEMPORARY TABLE tempdate2 AS 
SELECT 
	str_to_date(date, '%m/%d/%Y') as formatted_date,
    Location,
    population,
	CAST(NULLIF(new_vaccinations, '') AS SIGNED) as new_vaccinations,
    continent
FROM portfolioproject.covidvaccinations;

# How much time does this report cover? 
# This can be run everytime we get a new report to see how much time has passed.
SELECT
    COALESCE(DATEDIFF(
        MAX(formatted_date),
        MIN(formatted_date)
    ), 0) AS days_covered,
    COALESCE(DATEDIFF(
        MAX(formatted_date),
        MIN(formatted_date)
    ), 0) / 365 AS years_covered
FROM
    TempDate
WHERE
    Location = 'Afghanistan';

SELECT 
	Location, 
	formatted_date, 
    total_cases, 
    new_cases, 
    total_deaths, 
    population
From tempdate
order by 1,2;

# What were the covid deaths per country?
 SELECT 
	Location, 
    formatted_date, 
    total_cases, 
    total_deaths, 
    (total_deaths/total_cases)*100 as deathpercentage
From tempdate
order by 1,2;

# What was the comparative covid deaths in the United States?   
SELECT 
	Location, 
    formatted_date, 
    total_cases, 
    total_deaths, 
    (total_deaths/total_cases)*100 as deathpercentage
From tempdate
WHERE Location like '%united states%'
order by 1,2;
    
# What percentage of people were infected by covid in each country?
SELECT
	Location, 
    formatted_date,
    population, 
    total_cases,
    (total_cases/population)*100 AS infection_percentage    
From tempdate
ORDER BY 1,2;
    
# Which countries have the highest infection rate?
# By average
SELECT
	Location,
    Population,
    AVG(total_cases) as highest_infection,
    AVG(total_cases/population)*100 AS highest_infect_percentage
FROM tempdate
GROUP BY 
	Location,
    population
Order By highest_infect_percentage DESC
LIMIT 10;

# By highest peak percentage
SELECT
	Location,
    Population,
    MAX(total_cases) as highest_infection,
    MAX(total_cases/population)*100 AS highest_infect_percentage
FROM tempdate
GROUP BY 
	Location,
    population
Order By highest_infect_percentage DESC
LIMIT 10;

# Countries with the highest death count per population
# By highest peak deaths
SELECT 
	LOCATION,
	MAX(CAST(total_deaths AS SIGNED)) AS total_death_count
FROM tempdate
WHERE continent is not null
GROUP BY location
ORDER BY total_death_count DESC;
# These numbers are intersting as either China's extreme measures of locking people in their apartments actually worked or their numbers are being underrepresented. 
# As the largest populated country in the world, and ground zero for the start of the virus, you would expect their numbers to be higher.

# Global Numbers

SELECT 
	SUM(new_cases) as total_cases,
    SUM(cast(new_deaths as signed)) as total_deaths, 
    SUM(cast(new_deaths as signed))/SUM(new_cases)*100 as death_percentage
FROM tempdate
WHERE continent is not null;
# Death percentage is 89% and total cases is '1,858,972,171'.

# Does population size affect covid infections or deaths?
SELECT 
	Location,
	Population,
    continent,
    MAX(total_cases)/population*100 AS max_cases,
    AVG(total_cases)/population*100 AS avg_cases,
    MAX(total_deaths)/population*100 AS max_deaths,
    AVG(total_deaths)/population*100 AS avg_deaths
 FROM tempdate
WHERE continent != ''
#WHERE location = "cape verde"
GROUP BY 1,2, 3
ORDER BY population DESC
LIMIT 10;

# Which countries have the worst number of peak infections?
SELECT 
	Location,
	Population,
    MAX(total_cases)/population*100 AS max_cases
 FROM tempdate
GROUP BY 1,2
ORDER BY
	max_cases DESC
LIMIT 10;
# Latvia, Slovenia, Australia, Bonaire Sint Eustatius and Saba, Lithuania, Barbados, Saint Martin, Gibraltar, United States, San Marino
# Of these countries, Australia and the United States are the outliers as the others are small countries. 

# Which countries have the worst average number of infections?
SELECT 
	Location,
	Population,
    AVG(total_cases)/population*100 AS avg_cases
 FROM tempdate
GROUP BY 
	location,
    population
ORDER BY
	avg_cases DESC
LIMIT 10;
#San Marino, Cyprus, Gibraltar, Andorra, Faeroe Islands, Slovenia, Austria, Martinique, Denmark, Jersey
#These are all small populations with the largest have just under 9 million people.

# Which countries average the most deaths?
SELECT 
	Location,
	Population,
    AVG(total_deaths)/population*100 AS avg_deaths
 FROM tempdate
GROUP BY 1,2
ORDER BY avg_deaths DESC
LIMIT 10;
# Peru, Bulgaria, Bosnia and Herzegovina, North Macedonia, Hungary, Montenegro, Czechia, Georgia, 
# Of these countries, Peru is the only medium size country, the others are all small countries.

# Which countries peaked with the highest death percentage of those infected?
SELECT 
	Location,
	Population,
    MAX(total_deaths)/population*100 AS max_deaths
 FROM tempdate
GROUP BY 1, 2
ORDER BY max_deaths DESC
LIMIT 10;
# North Macedonia, Slovenia, Bosnia and Herzegovina, Moldova, Gibraltar, United States, San Marino, Peru, Martinique, Georgia
# Of these countries, United States is large and Peru is medium. The rest are all small. 

# Which countries has the smallest number of cases by percentage?
SELECT 
	Location,
	Population,
    total_cases,
    MAX(total_cases)/population*100 AS max_cases
 FROM tempdate
GROUP BY 1, 2, 3
ORDER BY max_cases ASC
LIMIT 10;
# Turkmenistan, North Korea, Tanzania, Benin, Sierra Leone, Uganda, Oman, Afghanistan, Madascar, Niger
# These numbers seem unlikely. 

# What countries have the highest number of average cases?
SELECT 
	Location,
	Population,
    total_cases,
    AVG(total_cases)/population*100 AS avg_cases
 FROM tempdate
GROUP BY 1, 2, 3 
ORDER BY avg_cases ASC
LIMIT 10;
# North Korea, Turkmenistan, Yemen, Niger, Chad, Tanzania, Democratic Republic of the Congo, Sierra Leone, Burkina Faso, Nigeria

# Which countries have the lowest average deaths by percentage?

##################################################################

SELECT 
	Location,
	Population,
    total_deaths,
    AVG(total_deaths)/population*100 AS avg_deaths
 FROM tempdate
GROUP BY 1, 2, 3
ORDER BY
	avg_deaths ASC
LIMIT 10;
# Vatican, North Korea, Turkmenistan, Falkland Islands, Saint Helena, Tokelau, Pitcairn, Niue, Burundi, Tanzania


# Which countries have the highest maximum deaths?
SELECT 
	Location,
	Population,
    MAX(total_deaths)/population*100 AS max_deaths
 FROM 
	portfolioproject.coviddeaths
GROUP BY 
	location,
    population
ORDER BY
	max_deaths DESC
LIMIT 10;

# Most of the countries that are in the extremes are very small. 
# It is unclear if this is becuase of lack of reporting or because lack of funding or some other factor. 

# What continents have the best numbers?
Select continent, 
	MAX(cast(total_deaths as SIGNED)) as TotalDeathCount, 
    (MAX(cast(total_deaths as SIGNED))/ MAX(population))*100 as TotalDeathCountPerc 
From tempdate
Where continent is not null 
GROUP BY continent
order by TotalDeathCount desc;

# How many people have been vaccinated per country on a rolling basis?
# Used CTE to calculate rolling number of vaccinated.
SELECT 
    continent, 
    location, 
    formatted_date, 
    population, 
    new_vaccinations, 
    RollingPeopleVaccinated
FROM (
    SELECT 
        death.continent, 
        death.location, 
        death.formatted_date, 
        death.population, 
        vac.new_vaccinations, 
        SUM(vac.new_vaccinations) OVER (PARTITION BY death.location ORDER BY death.location, death.formatted_date) as RollingPeopleVaccinated
    FROM tempdate death
    JOIN tempdate2 vac
        ON death.location = vac.location
        AND death.formatted_date = vac.formatted_date
    WHERE death.location IS NOT NULL
) AS subquery
WHERE RollingPeopleVaccinated IS NOT NULL
ORDER BY 2, 3;
# Many countries do not record their daily vaccinations but rather update them all at once so you will see spikes on a day were thousands of people are added to the new vaccinations. 


# Creating views of data for later use. 
# Rolling Vaccination Numbers
CREATE VIEW RollingVaccinated as
SELECT 
    continent, 
    location, 
    formatted_date, 
    population, 
    new_vaccinations, 
    RollingPeopleVaccinated
FROM (
    SELECT 
        death.continent, 
        death.location, 
        death.formatted_date, 
        death.population, 
        vac.new_vaccinations, 
        SUM(vac.new_vaccinations) OVER (PARTITION BY death.location ORDER BY death.location, death.formatted_date) as RollingPeopleVaccinated
    FROM tempdate death
    JOIN tempdate2 vac
        ON death.location = vac.location
        AND death.formatted_date = vac.formatted_date
    WHERE death.location IS NOT NULL
) AS subquery
WHERE RollingPeopleVaccinated IS NOT NULL
ORDER BY 2, 3;

CREATE VIEW RollingVaccinated AS 
WITH tempdate AS (
    SELECT 
        str_to_date(date, '%m/%d/%Y') as formatted_date,
        Location,
        population,
        CAST(new_vaccinations AS SIGNED) as new_vaccinations,
        continent
    FROM PortfolioProject.CovidVaccinations
),
tempdate2 AS (
    SELECT 
        str_to_date(date, '%m/%d/%Y') as formatted_date,
        Location,
        population,
        CAST(new_vaccinations AS SIGNED) as new_vaccinations,
        continent
    FROM portfolioproject.covidvaccinations
)
SELECT 
    death.continent, 
    death.location, 
    death.formatted_date, 
    death.population, 
    vac.new_vaccinations, 
    SUM(vac.new_vaccinations) OVER (PARTITION BY death.location ORDER BY death.location, death.formatted_date) as RollingPeopleVaccinated
FROM tempdate death
JOIN tempdate2 vac
    ON death.location = vac.location
    AND death.formatted_date = vac.formatted_date
WHERE death.location IS NOT NULL AND RollingPeopleVaccinated IS NOT NULL
ORDER BY 2, 3;

CREATE VIEW RollingVaccinated AS  
WITH tempdate AS ( 
    SELECT  
        str_to_date(date, '%m/%d/%Y') as formatted_date,
        Location,
        population,
        CAST(new_vaccinations AS SIGNED) as new_vaccinations,
        continent
    FROM PortfolioProject.CovidVaccinations
), 
tempdate2 AS ( 
    SELECT  
        str_to_date(date, '%m/%d/%Y') as formatted_date,
        Location,
        population,
        CAST(new_vaccinations AS SIGNED) as new_vaccinations,
        continent
    FROM portfolioproject.covidvaccinations
) 
SELECT  
    death.continent, 
    death.location, 
    death.formatted_date, 
    death.population, 
    vac.new_vaccinations, 
    SUM(vac.new_vaccinations) OVER (PARTITION BY death.location ORDER BY death.location, death.formatted_date) as RollingPeopleVaccinated
FROM tempdate death
JOIN tempdate2 vac 
    ON death.location = vac.location 
    AND death.formatted_date = vac.formatted_date
WHERE death.location IS NOT NULL
HAVING RollingPeopleVaccinated IS NOT NULL
ORDER BY 2, 3;
