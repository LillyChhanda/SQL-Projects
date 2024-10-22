--DEMOGRAPHIC INDICATORS

--DATA PREPARATION
--Data Set source: 
--https://population.un.org/wpp/Download/Standard/MostUsed/
--https://population.un.org/wpp/GlossaryOfDemographicTerms/


--Data Cleansing
--Delete unwanted columns. (Variant, Notes… also all Migration related columns)

--Split the dataset into below three categories each having Initial key columns (Index, Region,Year..)
--1.	Population
--2.	Fertility
--3.	Mortality

--DATA EXPLORATION

--Population: WORLD Figures (as of 1 July 2023)
--Total world population in Billion as of July 2023

--TOTAL Population (In Billions)
select
 Round(MAX(([Total Population, as of 1 July (thousands)]*1000)/1000000000),2) as "Total Population"
from DemographicEstPopulation



--TOTAL MALE Population
select
 Round(MAX(([Male Population, as of 1 July (thousands)]*1000)/1000000000),2) as "Total Male Population"
from DemographicEstPopulation

--TOTAL FEMALE Population
select
 Round(MAX(([Female Population, as of 1 July (thousands)]*1000)/1000000000),2) as "Total Female Population"
from DemographicEstPopulation

--SEX RATIO (Number of males per 100 females in the population)
select
 Round((Round(MAX(([Male Population, as of 1 July (thousands)]*1000)/1000000000),2)/Round(MAX(([Female Population, as of 1 July (thousands)]*1000)/1000000000),2))*100,2)
 as "Male to Female Ratio"
from DemographicEstPopulation

--Population: Country wise Figures (as of 1 July 2023)
--TOTAL Population TOP 150 Countries (In Millions)
select 
TOP 150 Round(MAX(([Total Population, as of 1 July (thousands)]*1000)/1000000),2) as Total_Population_in_millions
,[Region, subregion, country or area *]
from DemographicEstPopulation
where Type='Country/Area'
group by [Region, subregion, country or area *]
order by Total_Population_in_millions desc

--TOTAL Population Country wise (In Millions)
select 
[Region, subregion, country or area *]
,Round(MAX(([Total Population, as of 1 July (thousands)]*1000)/1000000),4) as Total_Population_in_millions
from DemographicEstPopulation
where Type='Country/Area'
group by [Region, subregion, country or area *]
order by Total_Population_in_millions desc


--TOTAL Population Country wise (In Thousands)
select 
[Region, subregion, country or area *]
,MAX([Total Population, as of 1 July (thousands)]) as Total_Population_in_thousands
from DemographicEstPopulation
where Type='Country/Area'
group by [Region, subregion, country or area *]
order by Total_Population_in_thousands desc

--Total population vs Population Density by Countries
select 
[Region, subregion, country or area *]
,Round(MAX(([Total Population, as of 1 July (thousands)]*1000)/1000000),4) as Total_Population_in_millions
,max([Population Density, as of 1 July (persons per square km)]) as "PopulationDensity(persons per square km)"
from DemographicEstPopulation
where Type='Country/Area'
group by [Region, subregion, country or area *]
order by Total_Population_in_millions desc

--SEX RATIO by Countries (Number of males per 100 females in the population)
select 
[Region, subregion, country or area *]
,MAX([Population Sex Ratio, as of 1 July (males per 100 females)]) as "Population Sex Ratio"
from DemographicEstPopulation
where Type='Country/Area'
group by [Region, subregion, country or area *]
order by "Population Sex Ratio" asc

--Median Age by Countries
select 
[Region, subregion, country or area *]
,MAX([Median Age, as of 1 July (years)]) as "Population Sex Ratio"
from DemographicEstPopulation
where Type='Country/Area'
group by [Region, subregion, country or area *]
order by "Population Sex Ratio" desc


--Population TRENDS: YEAR Figures (1950 - 2023)
--Total Population of the world over the years
select
Year
 ,Round(([Total Population, as of 1 July (thousands)]*1000)/1000000000,2) as "Total Population in Billions"
from DemographicEstPopulation
where Type = 'World'
--where [Total Population, as of 1 July (thousands)] != NULL
order by Year asc

--Total Population of Denmark (In thousands) over the years
select
Year
,[Region, subregion, country or area *]
 ,[Total Population, as of 1 July (thousands)] as "Total Population in Thousandss"
from DemographicEstPopulation
where [Region, subregion, country or area *]=’Denmark’
order by [Region, subregion, country or area *], Year

--Joining Population and fertility table
--Population Growth vs Birth Rate of India

select 
 popu.year
 ,popu.[Region, subregion, country or area *]
,popu.[Total Population, as of 1 July (thousands)]
,fert.[Births (thousands)]
from DemographicEstPopulation as popu
join DemographicEstFertility as fert
on popu.[Index]=fert.[Index]
where popu.[Region, subregion, country or area *]='India'


--Joining Population, fertility and Mortality table
--Population Growth vs Birth Rate vs Mortality of India

--Using CTE
with popvsfert (ID,Year,Country,Population,Birth)
as
(
select 
popu.[Index]
 ,popu.year
 ,popu.[Region, subregion, country or area *]
,popu.[Total Population, as of 1 July (thousands)]
,fert.[Births (thousands)]
from DemographicEstPopulation as popu
join DemographicEstFertility as fert
on popu.[Index]=fert.[Index]
where popu.[Region, subregion, country or area *]='India'
)
--select * from popvsfert

select 
a.Year,a.Country,a.Population,a.Birth
,b.[Total Deaths (thousands)]
from popvsfert as a
join DemographicEstMortality as b
on a.ID=b.[Index]

--Using TEMP Table
DROP Table if exists #popvsfert
Create Table #popvsfert
(
ID float,
Year float,
Country nvarchar(255),
Population float,
Birth float
)
Insert into #popvsfert
select 
popu.[Index]
 ,popu.year
 ,popu.[Region, subregion, country or area *]
,popu.[Total Population, as of 1 July (thousands)]
,fert.[Births (thousands)]
from DemographicEstPopulation as popu
join DemographicEstFertility as fert
on popu.[Index]=fert.[Index]
where popu.[Region, subregion, country or area *]='India'


select 
a.Year,a.Country,a.Population,a.Birth
,b.[Total Deaths (thousands)]
from #popvsfert as a
join DemographicEstMortality as b
on a.ID=b.[Index]

--Using VIEW
Create View popvsfertvw as
select 
popu.[Index] as ID
 ,popu.year
 ,popu.[Region, subregion, country or area *] as Country
,popu.[Total Population, as of 1 July (thousands)] as Population
,fert.[Births (thousands)] as Birth
from DemographicEstPopulation as popu
join DemographicEstFertility as fert
on popu.[Index]=fert.[Index]
where popu.[Region, subregion, country or area *]='India'


select 
a.Year,a.Country,a.Population,a.Birth
,b.[Total Deaths (thousands)]
from popvsfertvw as a
join DemographicEstMortality as b
on a.ID=b.[Index]

--Birth Rate of Countries compared to Avg Birth Rate of their Continent
select 
year
,fert.[Region, subregion, country or area *]
,con.continent as Continent
,ROUND(fert.[Births (thousands)],0) as Births
,ROUND(AVG(fert.[Births (thousands)]) over(partition by con.Continent),0) as AvgBirthPerContinent
from DemographicEstFertility as fert
join CountriesAndContinent as con
on fert.[Region, subregion, country or area *]=con.Country
where fert.Year='2023'
