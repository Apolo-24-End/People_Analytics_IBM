# People_Analytics_IBM

Proyecto de People Analytics en Power BI. Modelé un esquema en estrella con SQL desde datos planos y desarrollé KPIs en DAX para RRHH. El dashboard dual (Compensaciones y Demografía) audita la equidad salarial y analiza la rotación, revelando fugas críticas de talento en el primer año y anomalías de pago para optimizar decisiones corporativas.

## 1. Contexto y Objetivo del Negocio

El departamento de Recursos Humanos requería visibilidad sobre la distribución de su masa salarial y el comportamiento de la rotación de personal. El objetivo fue construir una herramienta interactiva que permitiera auditar la equidad salarial interna y detectar los principales focos de pérdida de talento humano para tomar acciones correctivas.

## 2. Arquitectura y Modelado de Datos (Back-end)

Se partió de una base de datos plana (`Raw_HR_Data`) la cual fue normalizada y estructurada bajo las mejores prácticas de inteligencia de negocios:

* **Diseño de Modelo en Estrella:** Creación mediante consultas SQL de una tabla de hechos central (`Fact_Nomina`) para las métricas cuantitativas, rodeada de dimensiones clave (`Dim_Employee`, `Dim_JobRole`, `Dim_Desempeño`).
* **Optimización:** Uso de llaves subrogadas y eliminación de columnas redundantes o estáticas para asegurar un procesamiento eficiente en el motor VertiPaq de Power BI.

## 3. Desarrollo Analítico (DAX)

Se programaron medidas dinámicas para responder a preguntas de negocio complejas:

* **Índice de Equidad Interna:** Creación de un KPI personalizado que compara el salario de un colaborador contra la mediana salarial de sus pares en el mismo rol, identificando fugas de presupuesto o empleados subpagados.
* **Métricas de Rotación:** Cálculos dinámicos de la tasa de renuncia (`Attrition`) segmentables por departamento, género y antigüedad.
* **Agrupación Demográfica:** Uso de DAX para categorizar edades exactas en rangos generacionales lógicos, facilitando el análisis visual poblacional.

## 4. Diseño de Interfaz y Experiencia de Usuario (UI/UX)

El reporte se dividió en dos lienzos enfocados en reducir la carga cognitiva del usuario gerencial:

* **Dashboard de Compensación y Equidad:** Visualización del presupuesto por niveles jerárquicos (Gráficos 100% apilados) y matrices de calor con formato condicional para resaltar desviaciones en las políticas de pago.
* **Dashboard Demográfico:** Análisis de diversidad y curvas de retención a lo largo del ciclo de vida del empleado.
* **Storytelling con Datos:** Implementación de una paleta de colores corporativa (Azul marino base y acentos vibrantes) donde el color actúa como alerta semaforizada, dirigiendo la atención inmediatamente a los departamentos con problemas (ej. Alta rotación resaltada en color naranja/rojo).

## 5. Hallazgos Clave (Business Insights)

Gracias a la interactividad del modelo, se detectaron hallazgos críticos para la toma de decisiones:

1. **Penalización del Talento:** El análisis cruzado reveló que los colaboradores calificados como "Talento Excepcional" perciben, en promedio, un salario ligeramente inferior a aquellos que solo "Cumplen Expectativas", evidenciando una falla en el esquema de incentivos.
2. **Crisis de Onboarding:** La curva de antigüedad demuestra que el pico máximo de renuncias ocurre durante el primer año, sugiriendo la necesidad urgente de rediseñar el proceso de inducción.
3. **Focos de Rotación:** Los departamentos de Ventas (Sales) y Recursos Humanos presentan tasas de rotación superiores al límite aceptable corporativo (15%), requiriendo intervención inmediata.
