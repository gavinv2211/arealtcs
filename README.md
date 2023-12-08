# arealtcs
Arealytics - Juan the drinker project

# 1. Description
This project loads json files into AWS RDS(SQL Server Express) database, using jupyter notebooks and pandas dataframe.
The json files are sourced from the arealytics AWS S3 bucket: s3://tests.arealytics.com.au/data_engineering/test_1/,
loaded and normalized into pandas dataframes and then into staging tables in the arealtcs database. Using SQL stored procedures,
the data from staging tables gets loaded into the 3nf data model. This model can be found under the model schema in the arealtcs database.


# 2. Setting up the database
- Create RDS SQL Server Instance in AWS
- Create database arealtcs
- Run the Staging Tables.sql script
- Run the Models Tables.sql script
- Run the Stored Procs.sql script

#3. Running the jupyter notebook (google colab can also be used)
- Using latest python version:
    - install jupyter notebooks: pip install jupyter
    - install pyodbc: pip install pyodbc
    - install boto3: pip install boto3
- In Jupyter Notebooks:
- Open the file arealtcs.ipynb
- under connect to DB update the server, username and password

  ![image](https://github.com/gavinv2211/arealtcs/assets/117391530/41542af2-20fc-4f9f-9245-fa0ba01ab15f)

  You should be able to run the script now to populate your data model

