# I have used Joins, Nested CTEs, Multipe CTEs, Rank Functions and Aggregations in this analysis #

with cte as (SELECT sp.product,p.series,p.sales_price FROM restorders.sales_pipeline sp join products p on p.product=sp.product)
select series, round(avg(sales_price),0) as avgsales from cte group by 1 order by 2 desc;
with cte1 as (SELECT sp.product,p.series,p.sales_price FROM restorders.sales_pipeline sp join products p on p.product=sp.product)
select product, round(avg(sales_price),0) as avgsales from cte1 group by 1 order by 2 desc;
SELECT 
    sector, AVG(close_value) AS avgclosevalue
FROM
    (SELECT 
        a.sector, sp.close_value
    FROM
        sales_pipeline sp
    JOIN accounts a ON a.account = sp.account) a
GROUP BY 1
ORDER BY 2 DESC;

SELECT 
    deal_stage,
    AVG(ABS(DATEDIFF(engage_date, close_date))) AS avgdaysofengagement
FROM
    sales_pipeline
GROUP BY 1
ORDER BY 2 DESC;

SELECT 
    year(engage_date) as engage_year,
    AVG(ABS(DATEDIFF(engage_date, close_date))) AS avgdaysofengagement
FROM
    sales_pipeline
GROUP BY 1
ORDER BY 2 DESC;


sELECT 
    sales_agent, manager, AVG(close_value) as avgclosevalue
FROM
    (SELECT 
        sp.sales_agent, st.manager, sp.close_value
    FROM
        sales_pipeline sp
    JOIN sales_teams st ON sp.sales_agent = st.sales_agent) a
GROUP BY 1 , 2
ORDER BY 3 DESC
LIMIT 5;

SELECT 
    sales_agent, manager, AVG(close_value) as avgclosevalue
FROM
    (SELECT 
        sp.sales_agent, st.manager, sp.close_value
    FROM
        sales_pipeline sp
    JOIN sales_teams st ON sp.sales_agent = st.sales_agent) a
GROUP BY 1 , 2
ORDER BY 3
LIMIT 5;


	SELECT 
    sales_agent,
    round(AVG(ABS(DATEDIFF(engage_date, close_date))),2) AS avgdaysofengagement
FROM
    sales_pipeline
GROUP BY 1
ORDER BY 2 DESC limit 5;



SELECT 
    sales_agent,
    round(AVG(ABS(DATEDIFF(engage_date, close_date))),2) AS avgdaysofengagement
FROM
    sales_pipeline
GROUP BY 1
ORDER BY 2  limit 5;


select  sales_agent,manager,round(avg(totaldaysofengagement),2) as avgdaysofengagement from (SELECT 
    sp.sales_agent, 
    st.manager, 
    sp.engage_date,
    sp.close_date,
    DATEDIFF(sp.close_date, sp.engage_date) AS totaldaysofengagement
FROM
    sales_pipeline sp
JOIN 
    sales_teams st ON sp.sales_agent = st.sales_agent) a group by 1,2 order by 3  limit 5;
    
    
select  sales_agent,manager,round(avg(totaldaysofengagement),2) as avgdaysofengagement from (SELECT 
    sp.sales_agent, 
    st.manager, 
    sp.engage_date,
    sp.close_date,
    DATEDIFF(sp.close_date, sp.engage_date) AS totaldaysofengagement
FROM
    sales_pipeline sp
JOIN 
    sales_teams st ON sp.sales_agent = st.sales_agent) a group by 1,2 order by 3 desc  limit 5;
    
SELECT 
    regional_office, round(AVG(close_value),2) as avgclosevalue
FROM
    (SELECT 
        st.regional_office, close_value
    FROM
        sales_pipeline sp
    JOIN sales_teams st ON st.sales_agent = sp.sales_agent) a
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

SELECT 
    regional_office, AVG(totaldaysofengagement) avgdaysofengagement
FROM
    (SELECT 
        st.regional_office,
            sp.engage_date,
            sp.close_date,
            DATEDIFF(close_date, engage_date) AS totaldaysofengagement
    FROM
        sales_pipeline sp
    JOIN sales_teams st ON sp.sales_agent = st.sales_agent) a
GROUP BY 1
ORDER BY 2 ASC;


SELECT 
    *,
    NTILE(3) OVER (ORDER BY close_value desc) AS KPI
FROM 
    sales_pipeline;



	   select regional_office, count(*) as total_top_performers_as_per_avg_daysofengagement from (select * from (select *,ntile(3) over(order by avgdaysofengagement asc) as KPI from (select b.sales_agent,avgdaysofengagement,regional_office,manager from (select sales_agent, avg(totaldaysofengagement) as avgdaysofengagement from( sELECT 
			sp.sales_agent,
				sp.engage_date,
				sp.close_date,
				DATEDIFF(close_date, engage_date) AS totaldaysofengagement
		FROM
			sales_pipeline sp
		JOIN sales_teams st ON sp.sales_agent = st.sales_agent)a group by 1 order by 2 desc) b join sales_teams st on st.sales_agent=b.sales_agent)c)d where KPI=1)e group by 1 order by 2 desc;

select regional_office, count(*) as total_top_performers_as_per_avgclosevalue  from (select * from (select *,ntile(3) over(order by close_value desc) as KPI from (select sp.sales_agent,close_value,st.regional_office from sales_pipeline sp join sales_teams st on st.sales_agent=sp.sales_agent)a) b where KPI=1)c group by 1 order by 2 desc;

select regional_office, count(*) as total_won_deals from (select * from (select regional_office, deal_stage from sales_pipeline sp join sales_teams st on st.sales_agent=sp.sales_agent)a where deal_stage="Won")a group by 1 order by 2 desc;

SELECT 
    DATE_FORMAT(engage_date, '%M-%Y') AS engage_month_year,
    ROUND(AVG(close_value), 0) AS avg_deal_value
FROM
    sales_pipeline
GROUP BY 1;

SELECT 
    sector, round(avg(revenue),0) AS total_revenue
FROM
    (SELECT 
        sp.account, a.sector, a.revenue
    FROM
        sales_pipeline sp
    JOIN accounts a ON sp.account = a.account) a
GROUP BY 1
ORDER BY 2 DESC limit 5;


SELECT 
    DATE_FORMAT(engage_date, '%M-%Y') AS engage_month_year,
    ROUND(sumcrm_merged_tbl(close_value), 0) AS avg_deal_value
FROM
    sales_pipeline
GROUP BY 1;


CREATE TEMPORARY TABLE tempdata AS
SELECT 
    sp.product, 
    sp.sales_agent, 
    sp.deal_stage, 
    sp.engage_date, 
    sp.close_date, 
    sp.close_value, 
    p.series, 
    p.sales_price, 
    sp.account 
FROM 
    sales_pipeline sp 
JOIN 
    products p 
ON 
    p.product = sp.product;
    
with cte1 as (select final_status,count(*) as total from (SELECT 
    *,
    CASE
        WHEN discount < 0 THEN 'profit'
        ELSE 'loss'
    END AS final_status
FROM
    (SELECT 
        *, sales_price - close_value AS discount
    FROM
        tempdata where deal_stage="Won") a)c group by 1 order by 2 desc),
cte2 as (select count(*)  as totaldeals from sales_pipeline where deal_stage="Won")
select final_status, round((total/totaldeals)*100.00,0) as percent_total from cte2,cte1 order by 2 desc;


select *, round(((avg_sales_price-avg_close_value)/avg_sales_price)*100,2) as percentdiff from (SELECT 
    round(AVG(sales_price),1) AS avg_sales_price,
    round(AVG(close_value),1) AS avg_close_value
FROM
    tempdata where deal_stage="Won")a;	

SELECT 
    series, sales_price, close_value
FROM
    tempdata where deal_stage="Won";

SELECT 
    series,
    round(AVG(sales_price - close_value),2) AS avg_variation
FROM 
   tempdata
GROUP BY 1 order by 2 desc;

SELECT 
    series,
    round(AVG(sales_price - close_value),2) AS avg_variation
FROM 
   tempdata
GROUP BY 1 order by 2 desc;

SELECT 
    regional_office, ROUND(AVG(variation), 2) AS avg_variation
FROM
    (SELECT 
        *, (sales_price - close_value) AS variation
    FROM
        (SELECT 
        st.regional_office, t.sales_price, t.close_value
    FROM
        tempdata t
    JOIN sales_teams st ON st.sales_agent = t.sales_agent) a) b
GROUP BY 1
ORDER BY 2 ASC;

select sales_agent,manager,round(avg(engagement_duration),2) as avg_engagement_duration from (SELECT 
    *,
    DATEDIFF(close_date, engage_date) AS engagement_duration
FROM
    (SELECT 
        deal_stage,manager, sp.sales_agent, sp.close_date, sp.engage_date
    FROM
        sales_pipeline sp
    JOIN sales_teams st ON st.sales_agent = sp.sales_agent where deal_stage="Won") a)b group by 1,2 order by 3 asc;
 
 
 
select sales_agent,manager,round(avg(engagement_duration),2) as avg_engagement_duration from (SELECT 
    *,
    DATEDIFF(close_date, engage_date) AS engagement_duration
FROM
    (SELECT 
        deal_stage,manager, sp.sales_agent, sp.close_date, sp.engage_date
    FROM
        sales_pipeline sp
    JOIN sales_teams st ON st.sales_agent = sp.sales_agent where deal_stage="Won") a)b group by 1,2 order by 3 asc;


with cte1 as (with cte as (SELECT 
        deal_stage, manager
    FROM
        sales_pipeline sp
    JOIN sales_teams st ON st.sales_agent = sp.sales_agent)
SELECT 
    manager,
    count(CASE WHEN deal_stage = 'Won' THEN 1 END) AS won_deals,
    COUNT(CASE WHEN deal_stage = 'Lost' THEN 1 END) AS lost_deals,
    COUNT(deal_stage) AS total_deals from cte group by 1)
    select manager, round((won_deals/total_deals)*100 ,2)as winpercentage from cte1 order by 2 desc;


with cte1 as (with cte as (SELECT 
        deal_stage, manager
    FROM
        sales_pipeline sp
    JOIN sales_teams st ON st.sales_agent = sp.sales_agent)
SELECT 
    manager,
    count(CASE WHEN deal_stage = 'Won' THEN 1 END) AS won_deals,
    COUNT(CASE WHEN deal_stage = 'Lost' THEN 1 END) AS lost_deals,
    COUNT(deal_stage) AS total_deals from cte group by 1)
    select manager,won_deals,lost_deals, round((lost_deals/total_deals)*100 ,2)as losspercentage, round((won_deals/total_deals)*100 ,2)as winpercentage from cte1 order by 2 desc;
    
    
with cte1 as (with cte as (SELECT 
        deal_stage, manager
    FROM
        sales_pipeline sp
    JOIN sales_teams st ON st.sales_agent = sp.sales_agent)
SELECT 
    manager,
    count(CASE WHEN deal_stage = 'Won' THEN 1 END) AS won_deals,
    COUNT(CASE WHEN deal_stage = 'Lost' THEN 1 END) AS lost_deals,
    COUNT(deal_stage) AS total_deals from cte group by 1)
    select *,round((won_deals/total_deals)*100,2) as won_percentage, round((lost_deals/total_deals)*100,2) as lost_percentage from cte1;
    
with cte2 as (with cte1 as (with cte as (select manager,final_status from (select manager,close_value,sales_price, case when close_value < sales_price then "Loss" else "Profit" end as final_status from (SELECT 
    sp.deal_stage, st.manager, sp.close_value, p.sales_price
FROM
    sales_pipeline sp
        JOIN
    sales_teams st ON st.sales_agent = sp.sales_agent
        JOIN
    products p ON p.product = sp.product
WHERE
    deal_stage = 'Won')a)b)
select manager, sum(case when final_status="Loss" then 1 else 0 end) as Losscount, sum(case when final_status="Profit" then 1 else 0 end) as Profitcount from cte group by 1)
select *,Losscount+Profitcount as total_won_deals from cte1)
select manager,round((Losscount/total_won_deals)*100,2) as Negative_ROI_deals,round((Profitcount/total_won_deals)*100,2) as Positve_ROI_deals from cte2;

SELECT 
       DATE_FORMAT(engage_date, '%M-%Y') AS engage_month_year, COUNT(*) AS totalwondeals
FROM
    (SELECT 
        *
    FROM
        sales_pipeline
    WHERE
        deal_stage = 'Won') a
GROUP BY 1;


SELECT 
       DATE_FORMAT(engage_date, '%M-%Y') AS engage_month_year,round(avg(close_value),1) as avg_close_value
FROM
    (SELECT 
        *
    FROM
        sales_pipeline
    WHERE
        deal_stage = 'Won') a	
GROUP BY 1;

with cte3 as (with cte as (select sector, employees,close_value,deal_stage,engage_date,close_date,revenue from sales_pipeline sp join accounts a on a.account=sp.account),
cte1 as (select  sector,count(*) as total_deals from cte group by 1),
cte2 as (select  sector,count(*) as total_won_deals  from cte where deal_stage="Won" group by 1)
select cte1.sector as sector,total_deals,total_won_deals from cte1 join cte2 on cte1.sector=cte2.sector)
select sector, total_deals,total_won_deals,(total_won_deals/total_deals)*100 as conversion_rate from cte3 group by 1,2 order by 4 desc;


with cte3 as (with cte as (select st.regional_office,sp.deal_stage from sales_pipeline sp join sales_teams st on st.sales_agent=sp.sales_agent),
cte1 as (select regional_office, count(*) as total_deals from cte group by 1),
cte2 as (select  regional_office,count(*) as won_deals from cte where deal_stage="Won" group by 1)
select cte1.regional_office,cte1.total_deals,cte2.won_deals from cte1 join cte2 on cte1.regional_office=cte2.regional_office)
select regional_office,total_deals,won_deals,round((won_deals/total_deals )*100,2) as conversion_rate from cte3 order by 4 desc;


with cte3 as (with cte as (select manager,deal_stage from sales_pipeline sp join sales_teams st on st.sales_agent=sp.sales_agent),
cte1 as (select manager, count(*) as total_deals from cte group by 1),
cte2 as (select manager, count(*) as won_deals from cte where deal_stage="Won" group by 1)
select cte1.manager,total_deals,won_deals from cte1 join cte2 on cte1.manager=cte2.manager)
select manager,total_deals,won_deals,round((won_deals/total_deals )*100,2) as conversion_rate from cte3 order by 4 desc;


SELECT 
    sales_price, close_value
FROM
    sales_pipeline sp
        JOIN
    products p ON p.product = sp.product
WHERE
    deal_stage = 'Won';
    
SELECT 
        st.regional_office, close_value
    FROM
        sales_pipeline sp
    JOIN sales_teams st ON st.sales_agent = sp.sales_agent;


with cte as (select *, case when difference<0 then "Loss" else "Profit" end as finalstatus from (select *,(close_value-sales_price) as difference from (SELECT p.sales_price,sp.close_value 
FROM sales_pipeline sp
JOIN products p ON p.product = sp.product where deal_stage="Won")a)b),
cte1 as (select finalstatus, count(*) as totaldealsbycadre from cte group by 1),
cte2 as (select count(*) as totaldeals from cte)
select *, finalstatus, round((totaldealsbycadre/totaldeals )*100.00,2) as percent_total from cte1,cte2;


SELECT 
    *,
    ROUND((avg_revenue - avg_close_value), 2) AS net_revenue_contribution
FROM
    (SELECT 
        sector,
            ROUND(AVG(revenue), 2) AS avg_revenue,
            ROUND(AVG(close_value), 2) AS avg_close_value
    FROM
        (SELECT 
        sector, revenue, close_value
    FROM
        sales_pipeline sp
    JOIN accounts a ON a.account = sp.account) a
    GROUP BY 1) b
ORDER BY 2 DESC;


SELECT 
    year_established,
    COUNT(*) AS total_customer_by_year_established
FROM
    (SELECT DISTINCT
        year_established, a.account
    FROM
        sales_pipeline sp
    JOIN accounts a ON a.account = sp.account) b
GROUP BY 1;

#RFM analysis for customer segmentation#
CREATE TEMPORARY TABLE rfmsegments1 AS (
    WITH rfm_table AS (
        -- Step 1: Calculate Recency, Frequency, and Monetary values for each account
        SELECT
            account,
            MAX(engage_date) AS last_purchase_date,
            COUNT(opportunity_id) AS frequency,
            AVG(close_value) AS monetary_value
        FROM
            sales_pipeline
        GROUP BY
            account
    ),
    cte1 AS (
        -- Step 2: Calculate Recency by finding the difference between the latest engage date and each account's last purchase date
        SELECT
            *,
            DATEDIFF((SELECT MAX(engage_date) FROM sales_pipeline), last_purchase_date) AS recency
        FROM
            rfm_table
    ),
    cte2 AS (
        -- Step 3: Assign quantile scores for recency, frequency, and monetary value
        SELECT
            *,
            NTILE(5) OVER (ORDER BY recency ASC) AS recency_score,
            NTILE(5) OVER (ORDER BY frequency DESC) AS frequency_score,
            NTILE(5) OVER (ORDER BY monetary_value DESC) AS monetary_score
        FROM
            cte1
    )
    -- Step 4: Assign customer segments based on RFM scores and select all columns
    SELECT
        *,
        CASE 
    WHEN recency_score <= 2 AND frequency_score >= 4 AND monetary_score >= 4 THEN "Loyal customers"
    WHEN recency_score = 3 AND frequency_score = 3 AND monetary_score = 3 THEN 'Potential Loyalists'
    WHEN recency_score >= 4 AND (frequency_score <= 2 OR monetary_score <= 2) THEN 'At Risk'
    ELSE "Need attention"
END AS customer_segments

    FROM
        cte2
);
select * from rfmsegments1;
SELECT 
    manager, COUNT(*) AS total_loyal_customers
FROM
    (SELECT 
        *
    FROM
        (SELECT 
        rf.*, sp.sales_agent, st.manager
    FROM
        rfmsegments1 rf
    LEFT JOIN sales_pipeline sp ON sp.account = rf.account
    LEFT JOIN sales_teams st ON st.sales_agent = sp.sales_agent) a
    WHERE
        customer_segments = 'Loyal Customers') a
GROUP BY 1
ORDER BY 2 DESC;

with cte2 as (with cte1 as (select year(engage_date) as engage_year, count(*) as total_deals from sales_pipeline group by 1),
cte2 as (select year(engage_date) as engage_year, count(*) as total_won_deals from sales_pipeline where deal_stage="Won" group by 1)
select cte1.engage_year,total_deals, total_won_deals from cte1 join cte2 on cte1.engage_year=cte2.engage_year)
select *,(total_won_deals/total_deals)*100 as conversion_rate from cte2;






    
    




