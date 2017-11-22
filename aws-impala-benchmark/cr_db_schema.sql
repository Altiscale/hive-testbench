CREATE DATABASE IF NOT EXISTS aws_impala_benchmark;
USE aws_impala_benchmark;
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

