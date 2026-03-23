# People_Analytics_IBM: Auditoría Salarial y Retención del Talento

Proyecto integral de People Analytics desarrollado en Power BI. El objetivo principal fue transformar un dataset transaccional plano en un modelo de datos dimensional (Esquema en Estrella) mediante SQL, y desarrollar KPIs en DAX para el área de Recursos Humanos. El dashboard dual resultante (Compensaciones y Demografía) audita la equidad salarial y analiza la rotación, revelando fugas críticas de talento en el primer año y anomalías de pago para optimizar la toma de decisiones corporativas.

---

## 1. Contexto y Preguntas de Negocio

El departamento de Recursos Humanos requería visibilidad profunda sobre la distribución de su presupuesto y la salud de su plantilla. El proyecto se estructuró para responder a tres preguntas de negocio críticas:
1. ¿Estamos compensando de manera justa y competitiva a nuestros colaboradores según su desempeño?
2. ¿Existen sesgos salariales o anomalías en la estructura de pagos de los distintos departamentos?
3. ¿En qué momento exacto del ciclo de vida del empleado se produce la mayor fuga de talento?

---

## 2. Arquitectura y Modelado de Datos (Back-end)

Se partió de una base de datos plana (`Raw_HR_Data`) la cual fue normalizada utilizando **SQL Server**. Se estructuró bajo el enfoque de modelado dimensional de Ralph Kimball para asegurar un procesamiento eficiente en el motor VertiPaq de Power BI:

* **Tabla de Hechos (`Fact_Nomina`):** Almacena métricas cuantitativas puras (MonthlyIncome, PercentSalaryHike) y dimensiones degeneradas (Attrition).
* **Tablas de Dimensiones:** Creación de `Dim_Employee` (datos demográficos), `Dim_JobRole` (jerarquía y área) y `Dim_Desempeño` (catálogo de evaluaciones).
* **Integridad y Rendimiento:** Se generaron llaves subrogadas (`IDENTITY(1,1)`) y se limpiaron columnas con varianza cero (ej. `StandardHours = 80`) para optimizar el peso del modelo. Todas las relaciones en Power BI se configuraron como **1 a Varios (1:*)** con dirección de filtro único.

---

## 3. Desarrollo Analítico (Código DAX)

Para dotar al dashboard de inteligencia real, se evitaron los promedios simples y se programaron medidas dinámicas complejas orientadas a la evaluación de RRHH:

* **A. Índice de Equidad Interna (Alternativa al Compa-Ratio):**
Se calculó la mediana salarial específica de cada rol para evaluar si un empleado está sobrepagado o subpagado respecto a sus pares directos.

dax
Mediana Salarial del Puesto = 
CALCULATE(
    MEDIAN(Fact_Nomina[MonthlyIncome]),
    ALLEXCEPT(Dim_JobRole, Dim_JobRole[JobRole])
)

Indice Equidad Interna = 
DIVIDE(
    AVERAGE(Fact_Nomina[MonthlyIncome]),
    [Mediana Salarial del Puesto],
    BLANK()
)

* **B. Tasa de Rotación (Turnover Rate):**
Cálculo dinámico que reacciona a los filtros demográficos y geográficos.
Total Bajas = CALCULATE([Total Colaboradores], Fact_Nomina[Attrition] = "Yes")

Tasa de Rotacion = DIVIDE([Total Bajas], [Total Colaboradores], 0)

* **C. Segmentación Generacional (Columnas Calculadas):**
Transformación de la edad lineal en bloques de análisis demográfico para evitar el ruido visual en los gráficos.
Rango de Edad = 
SWITCH(
    TRUE(),
    Dim_Employee[Age] >= 18 && Dim_Employee[Age] <= 25, "1. 18 - 25 años",
    Dim_Employee[Age] >= 26 && Dim_Employee[Age] <= 35, "2. 26 - 35 años",
    Dim_Employee[Age] >= 36 && Dim_Employee[Age] <= 45, "3. 36 - 45 años",
    Dim_Employee[Age] >= 46 && Dim_Employee[Age] <= 60, "4. 46 - 60 años",
    "Sin registro"
)

## 4. Diseño de Interfaz y Visualizaciones (UI/UX)
El reporte se dividió en dos lienzos aplicando principios de Storytelling con Datos y una paleta de colores corporativa (Azul marino base para contexto, Naranja/Rojo para alertas).

### Lienzo 1: Dashboard de Compensación y Equidad
**Gráfico de Barras Apiladas 100%:** Mostró la Masa Salarial por JobLevel. Permitió visualizar instantáneamente qué departamentos tienen estructuras operativas pesadas (Niveles 1 y 2) vs. cúpulas gerenciales costosas.

**Matriz de Calor con Formato Condicional:** Cruzó el JobRole con el Índice de Equidad Interna. Los roles con índices < 95% se iluminaron en naranja, creando una herramienta accionable diaria para revisión de sueldos.

**Gráfico de Columnas (Salario vs. Desempeño):** Diseñado para validar si la empresa practica una verdadera meritocracia.

### Lienzo 2: Dashboard Demográfico y Retención
**Gráfico de Barras Horizontales (Pirámide Poblacional):** Alimentado por el DAX de Rangos de Edad, mapeó el núcleo generacional de la empresa.

**Gráfico de Líneas (Fugas por Antigüedad):** Trazó el volumen de bajas en el Eje Y contra los años en la empresa en el Eje X, revelando los momentos críticos de deserción.

**Gráfico de Columnas con Línea Constante:** Mostró la rotación por departamento, marcando con una línea roja el 15% (Límite aceptable corporativo).

## 5. Hallazgos Clave y Recomendaciones (Business Insights)
La interactividad del modelo permitió descubrir tres fallos sistémicos en las políticas de Recursos Humanos:

* **Penalización Económica del Top Talent:** El cruce de Salario vs. Desempeño reveló una anomalía crítica: los colaboradores calificados como "Talento Excepcional" perciben, en promedio, un salario inferior a aquellos evaluados como "Cumple Expectativas". Recomendación: Congelar contrataciones externas y reestructurar el presupuesto de bonos para retener a los top performers.

* **Crisis en el Onboarding (Deserción Temprana):** El análisis de fuga por antigüedad demostró que el pico máximo absoluto de renuncias ocurre drásticamente en el Año 1. Recomendación: Auditar el proceso de reclutamiento (¿se están prometiendo condiciones irreales?) y rediseñar por completo el programa de inducción de los primeros 90 días.

* **Focos Rojos de Rotación Departamental:* Ventas (Sales) y Recursos Humanos superaron ampliamente la barrera del 15% de rotación. Al filtrar el departamento de Ventas en el gráfico de antigüedad, el eje dinámico reveló una "segunda ola" de renuncias alrededor del quinto año, sugiriendo un fuerte desgaste (burnout) del talento comercial senior.
