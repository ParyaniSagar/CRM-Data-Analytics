create temporary table cust_purchase_record
select 
	CustomerID,
    min(InvoiceDate) as FirstPurchase,
    max(InvoiceDate) as RecentPurchase
from sales
group by 1;

drop table cust_total_spent;
create temporary table cust_total_spent
select 
	CustomerID, 
	sum(total) as monetory,
    count(distinct InvoiceNo) as num_purchases 
from(
	select 
		CustomerID,
		(Quantity*UnitPrice) as total,
        InvoiceNo
	from sales) sl 
group by 1;


CREATE TEMPORARY TABLE FRMData
SELECT 
	*,
    datediff(RefDate,RecentPurchase) as Recency,
    (num_purchases/TimeFrameMnths) as frequency
FROM (
	SELECT 
		cpr.FirstPurchase,

        cpr.RecentPurchase,
        cts.*,
		ROUND(DATEDIFF(RecentPurchase,FirstPurchase)/30,0) + 1 as TimeFrameMnths,
		MAX(RecentPurchase) over() + 1 as RefDate
	FROM cust_purchase_record cpr
	LEFT JOIN cust_total_spent cts
		ON cpr.CustomerID = cts.CustomerID
) myt
ORDER BY CustomerID;

drop table FinalData;
create temporary table FinalData
select
	*,
    ROUND((F + M)/ 2, 0) AS FM
from
	(SELECT
		CustomerID,
		NTILE(5) over(order by Recency desc) as R,
		NTILE(5) over(order by frequency asc) as F,
		NTILE(5) over(order by monetory asc) as M
	FROM FRMData) score;

SELECT
	CustomerID,
    R, F, M,
    FM,
	CASE 
		WHEN (R = 5 AND FM = 5) OR (R = 5 AND FM = 4) OR (R = 4 AND FM = 5)
		THEN 'Champions'
		WHEN (R = 5 AND FM =3) OR (R = 4 AND FM = 4) OR (R = 3 AND FM = 5) OR (R = 3 AND FM = 4)
		THEN 'Loyal Customers'
		WHEN (R = 5 AND FM = 2) OR (R = 4 AND FM = 2) OR (R = 3 AND FM = 3) OR (R = 4 AND FM = 3)
		THEN 'Potential Loyalists'
		WHEN R = 5 AND FM = 1 
        THEN 'Recent Customers'
		WHEN (R = 4 AND FM = 1) OR (R = 3 AND FM = 1)
		THEN 'Promising'
		WHEN (R = 3 AND FM = 2) OR (R = 2 AND FM = 3) OR (R = 2 AND FM = 2)
		THEN 'Customers Needing Attention'
		WHEN R = 2 AND FM = 1 
        THEN 'About to Sleep'
		WHEN (R = 2 AND FM = 5) OR (R = 2 AND FM = 4) OR (R = 1 AND FM = 3)
		THEN 'At Risk'
		WHEN (R = 1 AND FM = 5) OR (R = 1 AND FM = 4)       
		THEN 'Cant Lose Them'
		WHEN R = 1 AND FM = 2 
        THEN 'Hibernating'
		WHEN R = 1 AND FM = 1 
        THEN 'Lost'
   END AS rfm_segment
   FROM FinalData
