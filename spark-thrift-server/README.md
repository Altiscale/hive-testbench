
* gen-allocation-file.sh

Script generates spark fair scheduler allocations file per https://spark.apache.org/docs/latest/job-scheduling.html . The default weight is 1 which is all pool are equal and minShare is 10, which means 10 cores are provided to each pool at a minimum .  By default the pool names are 'benchXXX' where XXX is 1 to 100.  Edit the script if you need to change this.

usage: `gen_allocation-file.sh > spark-fair-scheduler-allocations.xml`

* allocation-file-template.xml 

You can change the default values for weight and minShare

* Spark Thrift server

Run the STS with the following configuration to point to the fair scheduler allocations file

```
--conf spark.scheduler.allocation.file=/path/to/spark-fair-scheduler-allocations.xml
```

* JDBC/ODBC client

Add the following line in the session to set the pool for the session. E.g. if the user is bench032 then set the pool to the same.

```
SET spark.sql.thriftserver.scheduler.pool=bench032;
```
