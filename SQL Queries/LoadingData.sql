USE ProjectDB;

SHOW VARIABLES LIKE "secure_file_priv";

create table sales (
InvoiceNo	INT,
StockCode	TEXT,
ItemDescription	TEXT,
Quantity	INT,
InvoiceDate	DATE,
UnitPrice	FLOAT,
CustomerID	FLOAT,
Country TEXT);


LOAD data infile '/Dataset/sales.csv' into table sales
fields terminated by ','
lines terminated by '\n'
ignore 1 rows;


select * from sales;

