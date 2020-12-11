import os

from airflow import DAG
from airflow.contrib.hooks.fs_hook import FSHook
from airflow.contrib.sensors.file_sensor import FileSensor
from airflow.hooks.mysql_hook import MySqlHook
from airflow.operators.python_operator import PythonOperator
from airflow.utils.dates import days_ago
import pandas as pd

FILE_CONNECTION_ID = 'fs_default'
FILE_NAME = "time_series_covid19_confirmed_global.csv"
#FILE_PATH = "/home/airflow/monitor"
OUTPUT_TRANSFORM_FILE = '_time_series_covid19_confirmed_global.csv'

dag = DAG('covid_tag', description='Covid19',
          default_args={
              'owner': 'alvaro.esquivel',
              'depends_on_past': False,
              'max_active_runs': 1,
              'start_date': days_ago(1)
          },
          schedule_interval='0 1 * * *',
          catchup=False)

#Sensor que busca el archivo
file_sensor_taks = FileSensor(task_id="file_sensor_task1",
                    dag=dag,
                    fs_conn_id=FILE_CONNECTION_ID,
                    filepath=FILE_NAME,
                    poke_interval=10,
                    timeout=300)

#Proceso de transformacion

def transform_func(**kwargs):
    folder_path = FSHook(conn_id=FILE_CONNECTION_ID).get_path()
    file_path = f"{folder_path}/{FILE_NAME}"
    destination_file = f"{folder_path}/{OUTPUT_TRANSFORM_FILE}"
    df = pd.read_csv(file_path)
    nombre_columnas = df.columns[4:df.columns.shape[0]]
    id_var = df.columns[0:4]
    df_unpivot = pd.melt(df, id_vars=id_var, value_vars=nombre_columnas)
    df_unpivot.columns = ['province', 'country', 'lat', 'longitud', 'fecha', 'valor']
    df_unpivot.to_csv(destination_file, index=False)
    os.remove(file_path)
    return destination_file



transform_process = PythonOperator(task_id="transform_process",
                     python_callable=transform_func,
                     provide_context=True,
                     dag=dag
                     )

#Proceso de insertar

def insert_process(**kwargs):
    ti = kwargs['ti']
    #Extrae el archivo
    source_file = ti.xcom_pull(task_ids = 'transform_process')
    #Conexion a Base de Datos
    db_connection = MySqlHook('airflow_db').get_sqlalchemy_engine()

    df = pd.read_csv(source_file)

    with db_connection.begin() as transaction:
        #Elimina lo que existe en la tabla cada vez que se ejecuta
        transaction.execute("DELETE FROM covid.time_series_covid19_confirmed_global WHERE 1=1")
        df.to_sql("time_series_covid19_confirmed_global", #Nombre tabla
                  con=transaction, schema="covid", if_exists="append",
                  index=False)
    os.remove(source_file)

insert_process = PythonOperator(task_id="insert_process",
                     provide_context=True,
                     python_callable=insert_process,
                     dag=dag
                     )


file_sensor_taks >> transform_process >> insert_process


