-- Selecting the data for the project

Select Entity, refo.Year, [Refugee population by country or territory of origin], Population
From dbo.RefugeeOrigin refo
Join dbo.Population pop
On refo.Entity = pop.[Country name] and refo.Year = pop.Year;

Select Entity, refa.Year, [Refugee population by country or territory of asylum], Population
From dbo.RefugeeAsylum refa
Join dbo.Population pop
On refa.Entity = pop.[Country name] and refa.Year = pop.Year;


-- Showing which country the refugees were fleeing from (the number of refugees in a given year in relation to the population)

Select Entity, refo.Year, [Refugee population by country or territory of origin], Population, 
	([Refugee population by country or territory of origin]/Population)*100 as DepartingRefugeesPercentage
From dbo.RefugeeOrigin refo
Join dbo.Population pop
On refo.Entity = pop.[Country name] and refo.Year = pop.Year
Order by 1,2;


-- Showing which country the refugees were arriving (the number of refugees in a given year in relation to the population)

Select Entity, refa.Year, [Refugee population by country or territory of asylum], Population, 
	([Refugee population by country or territory of asylum]/Population)*100 as IncomingRefugeesPercentage
From dbo.RefugeeAsylum refa
Join dbo.Population pop
On refa.Entity = pop.[Country name] and refa.Year = pop.Year
Order by 1,2;


-- Looking at the countries with the highest number of arrinving refugees in 2020 (the number of refugees in relation to the population)

Select Entity, MAX(([Refugee population by country or territory of asylum]/Population))*100 as HighestPercentageOfArrivingRefugees
From dbo.RefugeeAsylum refa
Join dbo.Population pop
On refa.Entity = pop.[Country name] and refa.Year = pop.Year
Where pop.Year = 2020
Group by Entity
Order by HighestPercentageOfArrivingRefugees desc;


-- Looking at the countries with the highest number of fleeing refugees in 2020

Select Entity, MAX(([Refugee population by country or territory of origin]/Population))*100 as HighestPercentageOfRefugeesFleeing
From dbo.RefugeeOrigin refo 
Join dbo.Population pop
On refo.Entity = pop.[Country name] and refo.Year = pop.Year
Where pop.Year = 2020
Group by Entity
Order by HighestPercentageOfRefugeesFleeing desc;


-- Looking at the countries with the highest percentage of refugees fleeing compared to the share of young people in the population (under 25) in 2020
Select Entity, ([Population under the age of 25]/Population)*100 as YoungPeoplePercentage, 
	([Refugee population by country or territory of origin]/Population)*100 as DepartingRefugeesPercentage
From dbo.RefugeeOrigin refo
Join dbo.Population pop
On refo.Entity = pop.[Country name] and refo.Year = pop.Year
Where refo.Year = 2020 and Entity not like 'World'
Order by DepartingRefugeesPercentage desc;


-- Total number of refugees in 2020
Select SUM([Refugee population by country or territory of origin]) as RefugeesTotalNumber
From dbo.RefugeeOrigin refo
Join dbo.Population pop
On refo.Entity = pop.[Country name] and refo.Year = pop.Year
Where pop.Year = 2020 and Entity not like 'World';


-- Showing the growing number of fleeing refugees from a given country

Select Entity, pop.Year, refo.[Refugee population by country or territory of origin],
  SUM(refo.[Refugee population by country or territory of origin]) OVER (Partition by Entity Order by Entity, pop.Year) as 'Sum of fleeing refugees'
From dbo.RefugeeOrigin refo
Join dbo.Population pop
On refo.Entity = pop.[Country name] and refo.Year = pop.Year
Where Entity not like 'World'
Order by 1,2;


-- Showing the growing number of incoming refugees in a given country

Select Entity, pop.Year, refa.[Refugee population by country or territory of asylum],
  SUM(refa.[Refugee population by country or territory of asylum]) OVER (Partition by Entity Order by Entity, pop.Year) as 'Growing no. of incoming refugees'
From dbo.RefugeeAsylum refa
Join dbo.Population pop
On refa.Entity = pop.[Country name] and refa.Year = pop.Year
Where Entity not like 'World'
Order by 1,2;


-- Using CTE
-- Showing the total number of refugees arriving over the years in relation to the current population (in 2020)

With InRefvPop (Entity, Year, Population, [Refugee population by country or territory of asylum], [Growing no. of incoming refugees])
as 
(
Select Entity, pop.Year, Population, refa.[Refugee population by country or territory of asylum],
  SUM(refa.[Refugee population by country or territory of asylum]) OVER (Partition by Entity Order by Entity, pop.Year) as 'Growing no. of incoming refugees'
From dbo.RefugeeAsylum refa
Join dbo.Population pop
On refa.Entity = pop.[Country name] and refa.Year = pop.Year
Where Entity not like 'World'
)
Select *, ([Growing no. of incoming refugees]/Population)*100 as 'Incoming refugees vs. current population'
From InRefvPop
Where Year = 2020
Order by 6 desc;


-- Using TEMP TABLE
-- Showing the total number of refugees leaving over the years in relation to the current population (in 2020)

Drop Table if exists #LeavingRefugeesvPopulation
Create Table #LeavingRefugeesvPopulation
(
Entity nvarchar(255),
Year numeric,
Population numeric,
[Refugee population by country or territory of origin] numeric,
[Growing no. of refugees leaving] numeric
)

Insert into #LeavingRefugeesvPopulation
Select Entity, pop.Year, Population, refo.[Refugee population by country or territory of origin],
  SUM(refo.[Refugee population by country or territory of origin]) OVER (Partition by Entity Order by Entity, pop.Year) as 'Growing no. of refugees leaving'
From dbo.RefugeeOrigin refo
Join dbo.Population pop
On refo.Entity = pop.[Country name] and refo.Year = pop.Year
Where Entity not like 'World'

Select *, ([Growing no. of refugees leaving]/Population)*100 as 'Leaving refugees vs. current population'
From #LeavingRefugeesvPopulation
Where Year = 2020
Order by 6 desc;


-- Creating View to store data for visualizations

Create View LeavingRefugeesvPopulation as
Select Entity, pop.Year, Population, refo.[Refugee population by country or territory of origin],
  SUM(refo.[Refugee population by country or territory of origin]) OVER (Partition by Entity Order by Entity, pop.Year) as 'Growing no. of refugees leaving'
From dbo.RefugeeOrigin refo
Join dbo.Population pop
On refo.Entity = pop.[Country name] and refo.Year = pop.Year
Where Entity not like 'World'

Select *
From LeavingRefugeesvPopulation;
