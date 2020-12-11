-------------------------------------------------------------------------------------------------------------------
Desarrollo Proyecto Final - Curso: Product Development Maestria en Ciencia de Datos - Universidad Galileo
-------------------------------------------------------------------------------------------------------------------
Integrantes del Grupo
Jonathan André De León Monzón - Carné:09001843
Marlon Samuel Gonzales Flores - Carné:20007175
Sergio José Barrios Martínez  - Carné:19012765 
Alvaro Andres Esquivel Gomez  - Carné:11002822
---------------------------------------------------------------------------------------------------------
Contenido en Repositorio:
---------------------------------------------------------------------------------------------------------
Archivos para la creación del Contenedor de Airflow, con todas sus configuraciones
---------------------------------------------------------------------------------------------------------
- Carpeta airflow
          -> config
               -> airflow.cfg
               -> setup_connections.py
          -> script
               -> entrypoint.sh
	  -> Dockerfile
          -> requirements.txt
---------------------------------------------------------------------------------------------------------
Archivos para la creación de los DAGS de Airflow
---------------------------------------------------------------------------------------------------------
- Carpeta dags
          -> covid_dag.py
          -> covid_deaths.py
          -> covid_recover.py
---------------------------------------------------------------------------------------------------------
Archivos para la creación del Contenedor de Airflow, con el código del dashboard a ejecutar
---------------------------------------------------------------------------------------------------------
- Carpeta dashboard_shiny
          -> code
               -> server.R
               -> ui.R
          -> Dockerfile
---------------------------------------------------------------------------------------------------------
Archivos CSV de la data que se procesará para cargar los datos del dashboard
---------------------------------------------------------------------------------------------------------
- Carpeta data
          -> time_series_covid19_confirmed_global.csv
          -> time_series_covid19_deaths_global.csv
          -> time_series_covid19_recovered_global.csv
---------------------------------------------------------------------------------------------------------
Carpeta donde el contenedor de shiny depositará los logs
---------------------------------------------------------------------------------------------------------
- Carpeta logs
---------------------------------------------------------------------------------------------------------
Carpeta donde los DAGS de airflow tomarán los archivos CSV para cargar a la base de datos
---------------------------------------------------------------------------------------------------------
- Carpeta monitor
---------------------------------------------------------------------------------------------------------
Archivos para la creación de las tablas de la Base de datos del Dashboard de COVID
---------------------------------------------------------------------------------------------------------
- Carpeta script_dbs
          -> schema.sql
---------------------------------------------------------------------------------------------------------
Docker-Compose del proyecto
---------------------------------------------------------------------------------------------------------
- Archivo Docker-compose.yml
---------------------------------------------------------------------------------------------------------
Documento con especificación Técnica del Proyecto
---------------------------------------------------------------------------------------------------------
- Archivo Proyecto Final- Especificación Técnica.docx
