SELECT * FROM PortfolioProject..CovidDeaths
Order By 3,4

--SELECT * FROM PortfolioProject..CovidRecoveries
--Order By 3,4

Select [Country/Region], TotalCases, NewCases, TotalDeaths, Population From  PortfolioProject..CovidDeaths
Order By [Country/Region]

--The likelihood of Dying if you infected by Covid in Sudan
Select [Country/Region], TotalCases, TotalDeaths, (TotalDeaths/TotalCases)*100 as DeathPercentage From  PortfolioProject..CovidDeaths
Where [Country/Region] = 'Sudan'
Order By [Country/Region]

--What Percentage of Sudan's Population got Covid
Select [Country/Region], TotalCases, Population, (TotalCases/Population)*100 as Covid_CasesPercentage From  PortfolioProject..CovidDeaths
Where [Country/Region] = 'Sudan'
Order By [Country/Region]

--What countries have the highest infection rates per Population
Select [Country/Region], max(TotalCases) as Highest_InfectionCount, Population, max((TotalCases/Population))*100 as Highest_InfectionPercentage 
From  PortfolioProject..CovidDeaths
Group By [Country/Region], Population
Order By Highest_InfectionPercentage desc

--What Countries have highest death rates per Population
Select [Country/Region], max(TotalDeaths) as Highest_DeathCount, Population, max((TotalDeaths/Population))*100 as Highest_DeathPercentage 
From  PortfolioProject..CovidDeaths
Group By [Country/Region], Population
Order By Highest_DeathPercentage desc

--The likelihood of Dying if you infected by Covid per Country
Select [Country/Region], TotalCases, TotalDeaths, (TotalDeaths/TotalCases)*100 as DeathPercentage_Global From  PortfolioProject..CovidDeaths
Order By DeathPercentage_Global desc

--What Continents have highest death rates per Population
Select Continent, max(TotalDeaths) as TotalDeathCount From  PortfolioProject..CovidDeaths
Where Continent is not null
Group By Continent
Order By TotalDeathCount desc

--Global Numbers
Select Sum( Population) as GlobalPopulation, Sum(TotalCases) GlobalTotalCases, Sum(TotalDeaths) GlobalTotalDeaths, (sum(TotalCases)/sum(Population))*100 as InfectionPercentage_Global, (sum(TotalDeaths)/sum(TotalCases))*100 as DeathsPercentage_Global From  PortfolioProject..CovidDeaths


-- What is total number of Pepole per Country that are Recovered
SELECT CoD.Continent, CoD.[Country/Region], CoD.Population, CoD.TotalCases, CoR.TotalRecovered
From PortfolioProject..CovidDeaths CoD
Join PortfolioProject..CovidRecoveries CoR
    on CoD.[Country/Region]=CoR.[Country/Region] 
	and CoD.Continent=CoR.Continent
Where CoD.Continent is not null
Order By 1,2

--What is the percentage of Recovered vs Deaths from Total Cases per Country
SELECT CoD.Continent, CoD.[Country/Region], (CoD.TotalDeaths/CoD.TotalCases)*100 as Death_Percentage, (CoR.TotalRecovered/CoR.TotalCases)*100 as Recovery_Perentage 
From PortfolioProject..CovidDeaths CoD
Join PortfolioProject..CovidRecoveries CoR
    on CoD.[Country/Region]=CoR.[Country/Region] 
	and CoD.Continent=CoR.Continent
Where CoD.Continent is not null
Order By 1,2

-- Global numbers (Infected vs Recovered vs Deaths)
Select Sum(CoD.Population) as Global_Population, Sum(CoD.TotalCases) Global_TotalCases, 
Sum(CoD.TotalDeaths) Global_TotalDeaths, (sum(COD.TotalCases)/sum(Cod.Population))*100 as Infection_Percentage_Global,
(sum(CoD.TotalDeaths)/sum(CoD.TotalCases))*100 as Deaths_Percentage_Global, (sum(CoR.TotalRecovered/CoR.TotalCases))*100 as Recovered_Percentage_Global 
From PortfolioProject..CovidDeaths CoD
Join PortfolioProject..CovidRecoveries CoR
    on CoD.[Country/Region]=CoR.[Country/Region] 
	and CoD.Continent=CoR.Continent
Where CoD.Continent is not null
Order By 1,2


-- Global numbers (Infected vs Recovered vs Deaths)
WITH GlobalSummary AS (
    SELECT
	    CoD.[Country/Region] AS Location,
        SUM(CoD.Population) AS Global_Population,
        SUM(CoD.TotalCases) AS Global_TotalCases,
        SUM(CoD.TotalDeaths) AS Global_TotalDeaths,
        SUM(CoD.TotalDeaths) / SUM(CoD.TotalCases) * 100 AS Deaths_Percentage_Global,
        SUM(CoR.TotalRecovered) / SUM(CoR.TotalCases) * 100 AS Recovered_Percentage_Global,
		SUM(CoD.TotalCases) / SUM(Cod.Population) * 100 AS Infection_Percentage_Global,
        RANK() OVER (ORDER BY CoD.[Country/Region]) AS CountryRank
    FROM
        PortfolioProject..CovidDeaths CoD
    JOIN
        PortfolioProject..CovidRecoveries CoR ON CoD.[Country/Region] = CoR.[Country/Region] AND CoD.Continent = CoR.Continent
    WHERE
        CoD.Continent IS NOT NULL
)
SELECT
    Location
    Global_Population,
    Global_TotalCases,
    Global_TotalDeaths,
    Deaths_Percentage_Global,
    Recovered_Percentage_Global,
	Infection_Percentage_Global
FROM
    GlobalSummary
WHERE
    CountryRank = 1
ORDER BY
    CountryRank;


--Temp Table
Drop Table if exists Percent_Population_Recovered
Create Table Percent_Population_Recovered
(
Continent nvarchar(255),
[Country/Region] nvarchar(255),
Population numeric,
NewRecovered numeric,
RollingPeopleRecovered numeric
)
Insert Into Percent_Population_Recovered
Select CoD.Continent, CoD.[Country/Region], CoD.Population, CoR.TotalRecovered,
SUM(CONVERT(int,CoR.TotalRecovered)) OVER (Partition by CoD.[Country/Region] Order by CoD.[Country/Region]) AS RollingPeopleRecovered
From PortfolioProject..CovidDeaths CoD
Join PortfolioProject..CovidRecoveries CoR
    on CoD.[Country/Region]=CoR.[Country/Region] 
	and CoD.Continent=CoR.Continent
Where CoD.Continent is not null
Order By 1,2
Select *, (RollingPeopleRecovered/Population)*100
From Percent_Population_Recovered


--For Visulization Purposes
Create View Recovery_Percentage as
Select CoD.Continent, CoD.[Country/Region], CoD.Population, CoR.TotalRecovered,
SUM(CONVERT(int,CoR.TotalRecovered)) OVER (Partition by CoD.[Country/Region] Order by CoD.[Country/Region]) AS RollingPeopleRecovered
From PortfolioProject..CovidDeaths CoD
Join PortfolioProject..CovidRecoveries CoR
    on CoD.[Country/Region]=CoR.[Country/Region] 
	and CoD.Continent=CoR.Continent
Where CoD.Continent is not null
