Select * From PortfolioProject..CovidDeaths
order by 3,4

Select * From PortfolioProject..CovidVaccinations
order by 3,4

--Wybieramy dane, które bêdziemy u¿ywaæ
Select Location, date, total_cases, new_cases, total_deaths, population 
From PortfolioProject..CovidDeaths
order by 1,2

--Porównanie Total_Deaths vs Total_Cases w USA
Select Location, date, total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where Location like '%state%'
order by 1,2

--Porównanie Total_Cases vs Population
Select Location, date, total_cases, population, (total_cases/population)*100 as SickPercentage
From PortfolioProject..CovidDeaths
order by 1,2

--Patrzymy na kraje z najwieksz¹ liczb¹ zaka¿eñ w porównaniu z populacj¹
Select Location, population, MAX(total_cases) as NajwiekszaLiczbaZakazen, MAX(total_cases/population)*100 as ProcentZarazonejPopulacji
From PortfolioProject..CovidDeaths
Group by Location, Population
order by ProcentZarazonejPopulacji desc

--Pokazanie krajów z najwiêksz¹ liczb¹ zgonów w porównaniu z populacj¹
Select Location, MAX(total_deaths) as LiczbaZgonow
From PortfolioProject..CovidDeaths
Group by Location
order by LiczbaZgonow desc

--Pokazanie kontynentów z najwiêksz¹ liczb¹ zgonów
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

--Patrzymy na Populacja vs Szczepienia
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
dea.Date) as LudzieZaszczepieni
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
And dea.date = vac.date
Where dea.continent is not null
order by 2,3

--U¿ycie CTE
With PopvsVac (Continent, Location, Date, Population, New_vaccinations, LudzieZaszczepieni)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
dea.Date) as LudzieZaszczepieni
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	And dea.date = vac.date
Where dea.continent is not null
order by 2,3
)
Select *, (LudzieZaszczepieni/population)*100
From PopvsVac

--Tymczasowa tabela
Drop Table if exists #ProcentPopulacjiZaszczepionej
Create Table #ProcentPopulacjiZaszczepionej
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
LudzieZaszczepieni numeric
)

Insert into #ProcentPopulacjiZaszczepionej
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
dea.Date) as LudzieZaszczepieni
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	And dea.date = vac.date

Select *, (LudzieZaszczepieni/population)*100
From #ProcentPopulacjiZaszczepionej

--Tworzenie widoku do przechowywania danych do pózniejszej wizualizacji
Create View ProcentPopulacjiZaszczepionej as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
dea.Date) as LudzieZaszczepieni
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	And dea.date = vac.date
Where dea.continent is not null

Select*
From ProcentPopulacjiZaszczepionej
