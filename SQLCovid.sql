Select * From PortfolioProject..CovidDeaths
order by 3,4

Select * From PortfolioProject..CovidVaccinations
order by 3,4

--Wybieramy dane, kt�re b�dziemy u�ywa�
Select Location, date, total_cases, new_cases, total_deaths, population 
From PortfolioProject..CovidDeaths
order by 1,2

--Por�wnanie Total_Deaths vs Total_Cases w USA
Select Location, date, total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where Location like '%state%'
order by 1,2

--Por�wnanie Total_Cases vs Population
Select Location, date, total_cases, population, (total_cases/population)*100 as SickPercentage
From PortfolioProject..CovidDeaths
order by 1,2

--Patrzymy na kraje z najwieksz� liczb� zaka�e� w por�wnaniu z populacj�
Select Location, population, MAX(total_cases) as NajwiekszaLiczbaZakazen, MAX(total_cases/population)*100 as ProcentZarazonejPopulacji
From PortfolioProject..CovidDeaths
Group by Location. Population
order by ProcentZarazonejPopulacji desc

--Pokazanie kraj�w z najwi�ksz� liczb� zgon�w w por�wnaniu z populacj�
Select Location, MAX(total_deaths) as LiczbaZgonow
From PortfolioProject..CovidDeaths
Group by Location
order by LiczbaZgonow desc

--Pokazanie kontynent�w z najwi�ksz� liczb� zgon�w
Select continent, MAX(cast(total_deaths as float)) as LiczbaZgonow
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
Order by LiczbaZgonow desc

--GLOBAL NUMBERS
Select date, SUM(cast(new_cases as int)), SUM(cast(new_deaths as int)), SUM(cast(new_deaths as int))/SUM(cast(new_cases as int))*100 as ProcentPrzypadkowSmiertelnych
From PortfolioProject..CovidDeaths
Group by date
order by 1,2