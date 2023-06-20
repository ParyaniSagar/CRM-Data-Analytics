use scaler;

create temporary table cohort
SELECT 
	CustomerID,
    MIN(InvoiceDate) as FirstPurchaseDate
FROM sales
group by 1;

create table cohort_retention
SELECT 
	date_diff.*,
    year_diff*12 + month_diff + 1 as cohort_index
FROM(
	SELECT 
		Cust_Inv_Coh_Dates.*,
		InvoiceYear - CohortYear as year_diff,
		InvoiceMonth - CohortMonth as month_diff
	FROM(
		SELECT 
			ct.*,
            sl.InvoiceDate,
			YEAR(sl.InvoiceDate) as InvoiceYear,
			MONTH(sl.InvoiceDate) as InvoiceMonth,
			YEAR(ct.FirstPurchaseDate) as CohortYear,
			MONTH(ct.FirstPurchaseDate) as CohortMonth
		FROM cohort ct
		left join sales sl
			on ct.CustomerID = sl.CustomerId
		) Cust_Inv_Coh_Dates
	) date_diff
;
    
    
SELECT * FROM cohort_retention;    
SELECT
	CohortYear,
    CohortMonth,
	round(count(distinct case when cohort_index = 1 then CustomerID else Null end)*100/count(distinct CustomerID),1) as Month1,
    round(count(distinct case when cohort_index = 2 then CustomerID else Null end)*100/count(distinct CustomerID),1) as Month2,
    round(count(distinct case when cohort_index = 3 then CustomerID else Null end)*100/count(distinct CustomerID),1) as Month3,
    round(count(distinct case when cohort_index = 4 then CustomerID else Null end)*100/count(distinct CustomerID),1) as Month4,
    round(count(distinct case when cohort_index = 5 then CustomerID else Null end)*100/count(distinct CustomerID),1) as Month5,
    round(count(distinct case when cohort_index = 6 then CustomerID else Null end)*100/count(distinct CustomerID),1) as Month6,
    round(count(distinct case when cohort_index = 7 then CustomerID else Null end)*100/count(distinct CustomerID),1) as Month7,
    round(count(distinct case when cohort_index = 8 then CustomerID else Null end)*100/count(distinct CustomerID),1) as Month8,
    round(count(distinct case when cohort_index = 9 then CustomerID else Null end)*100/count(distinct CustomerID),1) as Month9,
    round(count(distinct case when cohort_index = 10 then CustomerID else Null end)*100/count(distinct CustomerID),1) as Month10,
    round(count(distinct case when cohort_index = 11 then CustomerID else Null end)*100/count(distinct CustomerID),1) as Month11,
    round(count(distinct case when cohort_index = 12 then CustomerID else Null end)*100/count(distinct CustomerID),1) as Month12
FROM cohort_retention
group by 1,2
order by 1,2
;
