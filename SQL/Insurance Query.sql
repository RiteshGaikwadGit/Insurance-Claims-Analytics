## Customer table
CREATE DATABASE insurance_analytics;
USE insurance_analytics;
select * from customer_info;

ALTER TABLE customer_info 
CHANGE `ï»¿Customer ID` customer_id TEXT;

ALTER TABLE customer_info 
MODIFY age INT;

SET GLOBAL local_infile = 1;

CREATE TABLE policy_info (
    policy_id VARCHAR(20),
    policy_type VARCHAR(50),
    coverage_amount DOUBLE,
    premium_amount DOUBLE,
    policy_start_date DATE,
    policy_end_date DATE,
    payment_frequency VARCHAR(20),
    status VARCHAR(20),
    customer_id VARCHAR(20)
);
## Policy Details Data 
SHOW VARIABLES LIKE 'secure_file_priv';

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Policy Details.csv'
INTO TABLE policy_info
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

CREATE TABLE claims (
    claim_id VARCHAR(20),
    date_of_claim DATE,
    claim_amount DOUBLE,
    claim_status VARCHAR(20),
    reason_for_claim TEXT,
    settlement_date DATE,
    policy_id VARCHAR(20)
);


## Claims Table
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Claims.csv'
INTO TABLE claims
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
claim_id,
date_of_claim,
claim_amount,
claim_status,
reason_for_claim,
@settlement_date,
policy_id
)
SET settlement_date = NULLIF(@settlement_date, '');

## Payments Table
CREATE TABLE payments (
    payment_id VARCHAR(20),
    date_of_payment DATE,
    amount_paid DOUBLE,
    payment_method VARCHAR(30),
    payment_status VARCHAR(20),
    policy_id VARCHAR(20)
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Payment History.csv'
INTO TABLE payments
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


## Additional_fields
CREATE TABLE additional_fields (
    agent_id VARCHAR(20),
    renewal_status VARCHAR(20),
    policy_discounts INT,
    risk_score INT,
    policy_id VARCHAR(20)
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Additional Fields.csv'
INTO TABLE additional_fields
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

select * from policy_info;


## All the 10 KPI With the Query
## Total Policies

create table kpi_total_policies AS
select CONCAT(ROUND(COUNT(Distinct customer_id)/1000, 0),'K') AS total_policies
from policy_info;
select* from kpi_total_policies;


## Total Customers

create table kpi_total_customers as
select concat(round(count(distinct customer_id)/1000,0),'K') as total_customers
from customer_info;
select * from kpi_total_customers;

## Age Group Analysis

Create table kpi_age_group as
Select `Age Group`,count(*) as total_customers
from customer_info
group by `Age Group`
union all
select 'Grand Total', count(*) from customer_info;
select * from kpi_age_group;

## Gender Analysis

Create table kpi_Gender as 
select gender, count(*) as total_customers
from customer_info
group by gender
union all
select 'Grand Total', count(*) from customer_info;
select * from kpi_gender;

## Policy Type distribution

Create table kpi_policy_type as 
select policy_type,count(*) as total_policy
from policy_info
group by policy_type
union all
select 'Grand Total', count(*) from customer_info;
select * from kpi_policy_type;

## Expiring Policy

Create table Kpi_Expiring_policy
select count(*) as expiring_policy
from policy_info
where year(policy_end_date)= year(current_date());
select * from kpi_expiring_policy;

## Premium Growth Rate

Create table kpi_Premium_yearly as 
select year(policy_start_date) as year,
round(sum(premium_amount),0)as total_premium
from policy_info
group by year(policy_start_date)
order by year;
select * from kpi_premium_yearly;


## Growth Rate

CREATE TABLE kpi_premium_growth AS
SELECT year,CONCAT(ROUND(total_premium/1000,1),'K') AS total_premium,
IFNULL(CONCAT(ROUND(LAG(total_premium) OVER (ORDER BY year)/1000,1),'K'),'N/A') AS previous_year,
IFNULL(CONCAT(ROUND(((total_premium - LAG(total_premium) OVER (ORDER BY year))/ LAG(total_premium) OVER (ORDER BY year)) * 100, 2),'%'),'N/A') AS growth_rate
FROM kpi_premium_yearly;
select * from kpi_premium_growth;


## Claim Status Wise Policy Count

Create Table kpi_claims_status as
select claim_status,count(*) as total_claims
from claims
group by claim_status
union all
select 'Grand total',count(*) from claims;
select * from kpi_claims_status;

## Payment Status Wise Policy Count

Create Table kpi_status_wise_policy as
select payment_status,count(policy_id) as total_policies
from payments
group by payment_status
union all
select 'Grand total',count(*) from payments;
select * from kpi_status_wise_policy;

## Total Claim Amount

Create table kpi_total_claim as
select concat(round(sum(claim_amount)/1000000,1),'M') as total_claim_amount
from claims;
select * from kpi_total_claim;


