SELECT *
FROM Raw_HR_Data
GO

--Dim_Employee Tabla
CREATE TABLE Dim_Employee (
    EmployeeKey INT IDENTITY(1,1) PRIMARY KEY,
    EmployeeNumber INT,
    Age INT,
    Gender NVARCHAR(50),
    MaritalStatus NVARCHAR(50),
    EducationField NVARCHAR(50),
    DistanceFromHome INT,
	EnvironmentSatisfaction INT,
	Over18 NVARCHAR(5),
	NumCompaniesWorked INT,
	YearsAtCompany INT,
	YearsInCurrentRole INT,
	YearsSinceLastPromotion INT,
	YearsWithCurrManager INT,
	StockOptionLevel INT,
	TrainingTimesLastYear INT
);

-- Insertamos los datos únicos
INSERT INTO Dim_Employee (EmployeeNumber, Age, Gender, MaritalStatus, EducationField, DistanceFromHome,EnvironmentSatisfaction, Over18, NumCompaniesWorked, YearsAtCompany, YearsInCurrentRole,
	YearsSinceLastPromotion, YearsWithCurrManager, StockOptionLevel,
	TrainingTimesLastYear)
SELECT DISTINCT EmployeeNumber, Age, Gender, MaritalStatus, 
	EducationField, DistanceFromHome, EnvironmentSatisfaction, 
	Over18, NumCompaniesWorked, YearsAtCompany, YearsInCurrentRole,
	YearsSinceLastPromotion, YearsWithCurrManager, StockOptionLevel,
	TrainingTimesLastYear
FROM Raw_HR_Data;

-- Dim_JobRole
CREATE TABLE Dim_JobRole (
    JobRoleKey INT IDENTITY(1,1) PRIMARY KEY,
	BusinessTravel NVARCHAR(50),
    Department NVARCHAR(50),
	JobInvolvement INT,
    JobRole NVARCHAR(50),
    JobLevel INT, 
	JobSatisfaction INT
);

INSERT INTO Dim_JobRole (BusinessTravel, Department, JobInvolvement, JobRole, JobLevel, JobSatisfaction)
SELECT DISTINCT BusinessTravel, Department, JobInvolvement, JobRole, JobLevel, JobSatisfaction
FROM Raw_HR_Data;

-- Dim_Desempeño
CREATE TABLE Dim_Desempeño (
	Id_Desempeño INT PRIMARY KEY,
	Etiqueta_Desempeño VARCHAR(50)
);

INSERT INTO Dim_Desempeño (Id_Desempeño, Etiqueta_Desempeño)
VALUES 
    (1, 'Bajo Rendimiento'),
    (2, 'Necesita Mejorar'),
    (3, 'Cumple Expectativas'),
    (4, 'Talento Excepcional'),
	(5, 'Rendimiento Perfecto')

SELECT *
FROM Dim_Desempeño
GO

SELECT *
FROM Dim_JobRole
GO

SELECT *
FROM Dim_Employee
GO

--Tabla de Hechos
-- Creamos la Tabla de Hechos
CREATE TABLE Fact_Nomina (
    FactKey INT IDENTITY(1,1) PRIMARY KEY,
    
    -- Llaves Foráneas (Conexión a tus dimensiones)
    EmployeeKey INT,
    JobRoleKey INT,
    Id_Desempeño INT,
    
    -- Dimensiones Degeneradas (Textos cortos que varían por evento y filtran rápido)
    Attrition NVARCHAR(10), -- 'Yes' o 'No' (Rotación)
    OverTime NVARCHAR(10),  -- 'Yes' o 'No' (Horas extras)
    
    -- Métricas / Hechos (Los datos que vas a sumar o promediar)
    MonthlyIncome INT,
    DailyRate INT,
    HourlyRate INT,
    MonthlyRate INT,
    PercentSalaryHike INT,
    StandardHours INT,
    
    -- Restricciones de llaves foráneas
    FOREIGN KEY (EmployeeKey) REFERENCES Dim_Employee(EmployeeKey),
    FOREIGN KEY (JobRoleKey) REFERENCES Dim_JobRole(JobRoleKey),
    FOREIGN KEY (Id_Desempeño) REFERENCES Dim_Desempeño(Id_Desempeño)
);

-- Insertamos los datos cruzando con las dimensiones para obtener las llaves (Keys)
INSERT INTO Fact_Nomina (
    EmployeeKey, JobRoleKey, Id_Desempeño, 
    Attrition, OverTime, 
    MonthlyIncome, DailyRate, HourlyRate, MonthlyRate, 
    PercentSalaryHike, StandardHours
)
SELECT 
    e.EmployeeKey,
    j.JobRoleKey,
    r.PerformanceRating AS Id_Desempeño, -- Conecta directo con el 1, 2, 3 o 4
    r.Attrition,
    r.OverTime,
    r.MonthlyIncome,
    r.DailyRate,
    r.HourlyRate,
    r.MonthlyRate,
    r.PercentSalaryHike,
    r.StandardHours
FROM Raw_HR_Data r
-- Unimos con Dim_Employee usando el número de empleado (llave natural)
JOIN Dim_Employee e ON r.EmployeeNumber = e.EmployeeNumber
-- Unimos con Dim_JobRole asegurando que coincidan todos los atributos que la definen
JOIN Dim_JobRole j ON 
    r.BusinessTravel = j.BusinessTravel AND 
    r.Department = j.Department AND 
    r.JobInvolvement = j.JobInvolvement AND 
    r.JobRole = j.JobRole AND 
    r.JobLevel = j.JobLevel AND 
    r.JobSatisfaction = j.JobSatisfaction;

SELECT Max(Age) AS MAX_1, Min(Age) AS MIN_1
FROM Dim_Employee
go