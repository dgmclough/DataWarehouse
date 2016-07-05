# DataWarehouse
Data Warehousing of a relational database of English Premiership Data from 2011/12

This project involved the Data Warehousing of several sources of data recorded about the
2011/2012 English Premiership League; and the creation of complex SQL queries to deduce
significant statistics about the players and teams included. 

The process involved creating the relational database to store and sort the raw data. 
The design and implementation of the Data Warehouse/ Dimensional model. 
The staging of the data in an ETL process before inserting into the data warehouse. 
A second ETL process to import data with some new data.
And finally, the construction of some complex SQL queries on the Data Warehouse. 

Install
*Ensure that you have MySQL installed on your computer
**This guide assumes the ability to run scripts on the MySQL command line

1. Download all of the files on to your computer to the same directory. 
2. Edit the "relational_db.sql" file at line 83 to the location you have saved "Insert.sql" 
3. Edit the "relational_db.sql" file at line 105 to the location you have saved "Premier.csv" 
4. Edit the "ETL_2.sql" file at line 28 to the location you have saved "ETL2.csv" 
5. Open MySQL Command Line
6. Run each of the scripts from the command line in the following order
    i) "relational_db.sql"
    ii) "dimensional_model.sql"
    iii) "staging_ETL.sql"
    iv) "ETL_2.sql"
7. After this the Data Warehouse is complete and ready to be mined. For an illustration,
  run one of the quer scripts included. 
    i) "querysample_1.sql"
    ii) "querysample_2.sql"
    
Thanks for reading!
