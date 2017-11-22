* Impala Performance Testing and Query Optimization
http://docs.aws.amazon.com/emr/latest/DeveloperGuide/impala-optimization.html

* Generating data http://docs.aws.amazon.com/emr/latest/DeveloperGuide/query-impala-generate-data.html

The following page summarizes the steps to run the performance benchmark done by AWS on hive and impala.  Based on the above 2 links.

Download the data generation jar
* wget http://elasticmapreduce.s3.amazonaws.com/samples/impala/dbgen-1.0-jar-with-dependencies.jar

Generate 1GB data of 3 tables  books, customers and transactions each
* java -cp dbgen-1.0-jar-with-dependencies.jar DBGen -p /mnt/dbgen -b 1 -c 1 -t 1

* copy data to HDFS
```
hadoop fs -mkdir /data/
hadoop fs -put /mnt/dbgen/* /data/
hadoop fs -ls -h -R /data/
```

* Table Size

The following table shows the row count for each table (in millions of rows). The GB value indicates the size of the text file of each table. Within an input class, the books, customers, and transactions tables always have the same size.

| Input Class (size of each table) | Books table (Million Rows) | Customers table (Million Rows) | Transactions table (Million Rows) |
| 4GB | 63|53| 87|
|8GB | 	125 | 106 | 171|
|16GB | 249 | 210 | 334|
|32GB | 497 | 419 | 659|
|64GB | 991 | 837 | 1304|
|128GB | 1967 | 1664 | 2538|
|256GB | 3919 | 3316 | 5000|

* Database schema

```
CREATE EXTERNAL TABLE books(
  id BIGINT,
  isbn STRING,
  category STRING,
  publish_date TIMESTAMP,
  publisher STRING,
  price FLOAT
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '|'
LOCATION '/data/books/';
 
CREATE EXTERNAL TABLE customers(
  id BIGINT,
  name STRING,
  date_of_birth TIMESTAMP,
  gender STRING,
  state STRING,
  email STRING,
  phone STRING
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '|'
LOCATION '/data/customers/';
 
CREATE EXTERNAL TABLE transactions(
  id BIGINT,
  customer_id BIGINT,
  book_id BIGINT,
  quantity INT,
  transaction_date TIMESTAMP
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '|'
LOCATION '/data/transactions/';
```

* 4 different queries: Q1, Q2, Q3 and Q4

