# arealtcs
Arealytics - Juan the drinker project

# 1. Description
This project loads json files into AWS RDS(SQL Server Express) database, using jupyter notebooks and pandas dataframe.
The json files are sourced from the arealytics AWS S3 bucket: s3://tests.arealytics.com.au/data_engineering/test_1/,
loaded and normalized into pandas dataframes and then into staging tables in the arealtcs database. Using SQL stored procedures,
the data from staging tables gets loaded into the 3nf data model. This model can be found under the model schema in the arealtcs database.


# 2. To do
- Create RDS SQL Server Instance in AWS
- Create database arealtcs
