# Transaction-Reconciliation-and-System-Integrity-Report

**Author:** Loretta Chimezie   
**Date:** 2026-01-25

## Project Background
This project focuses on reconciling transaction data to evaluate the effectiveness of system controls and data integrity measures across systems. By identifying discrepancies, missing transactions, and processing errors, the report highlights recommendations for strengthening reconciliation and mitigating financial risk that ensure end-to-end system integrity, data accuracy, and operational reliability.

## Project Objective
1.	Bank transfer reconciliation: to investigate the forward/reverse flow analysis of transfers
2.	Investigation of utility transactions: identify duplicates and missing transactions
3.	Transaction status mismatches: how many transactions have status discrepancies and the total value
4.	Service provider: find out which service provider is unreliable
5.	Revenue analysis: calculate the value of all missing/mismatch transactions
6.	Trend analysis: when are these issues most common?

## Datasets Description
- **app_transactions.csv** 
- **banklink_transactions.csv**
- **coralpay_transactions.csv**
- **irecharge_transactions.csv**
- **nibbs_transactions.csv**
- **Key fields** — txnRef, merchantRef, transaction_id, transaction_type, service_type, amount, date, time, settlement_date, status

## Data Cleaning
•	Converted columns datatypes to DATE and TIME

## Key KPIs
| KPI | Value |
|-----|-------|
| Total Transactions Processed | 80000 |
| Reconciled Transactions Count | 67470 |	
| Orphaned Value | 184,382,610 |	
| Reconciliation Rate (%) | 84.3 |	
| Unreconciled transactions value | Over 270million |
| Provider Failure Rate (Coralpay vs Irecharge)% | 12.0 vs 11.8 |
| Duplicate Transactions | 93 |

	
## Sample Snippets
```sql
with monthly_issues as													        		select a.txnref as orphaned_utility, a.transaction_type, 
(			    												        					 	a.amount, a.status, a.provider from app_tranz a
select date(`date`) as `month`, monthname(`date`) as month_name, 						left join coralpay_tranz c on a.txnref = c.txnref
	count(distinct txnref) as loss_count from lost_revenue								left join irecharge_tranz i on a.txnref = i.txnref
group by date(`date`), monthname(`date`)												where a.transaction_type <> 'bank_transfer' and
order by date(`date`) desc																c.txnref is null and i.txnref is null;
)
select month_name, sum(loss_count) as no_of_issues from monthly_issues
group by month_name order by no_of_issues desc;

```

## Summary of Findings
-	28,750 bank transfers initiated in the app successfully flows through Banklink and reaches NIBBS for final settlement
-	Total value of the orphaned (app transfer) transactions is 135,193,832 (customer money that is stuck)
-	81% success rate of transactions seen across the 3 services 
-	Utility transactions are processed by either Coralpay or Irecharge. 
-	Value of missing (orphaned) utility payments is 49,188,778
-	There are 93 duplicate utility transactions that is seen in Coralpay channel. The value is 4,796,950
-	The total value of transactions with status discrepancies is 65,553,947 (money that was never actually received). 
-	Irecharge provider has the most missing transactions and the most status mismatches
-	The rate of transaction failure in coralpay is slightly higher than that of irecharge with 0.2%
-	12530 transactions have reconciliation issues. This is about 15.7% of the total transactions processed
-	Unreconciled transaction is over 270million naira in volume.
-	Transaction failure times are higher by 1pm and lowest by 6pm
-	Transaction issues do not correlate with transaction volume spike, as we have more issues on Thursdays and 
more transactions on Tuesdays


## Recommendations
-	Implement automated end-to-end transaction tracking across App → Banklink → NIBBS to immediately flag 
transactions that do not reach final settlement, in order to address orphaned & stuck fund
-	Introduce time-based escalation rules (e.g., auto-alert if a transaction is not completed within specified minutes)
-	Create an automated reversal/refund workflow for orphaned transactions to prevent prolonged customer fund lock-up.
-	Prioritize recovery of the ₦135M App-transfer orphaned funds and ₦49M missing utility payments due to 
direct customer impact and regulatory risk.
-	Set a minimum acceptable success-rate SLA (e.g., ≥97%) across all services, to improve the current 81% rate
-	Introduce retry logic with idempotency keys to reduce failures caused by transient network or provider issues.
-	Enforce duplicate transaction checks (txnref + amount + time) at the Coralpay entry point to eliminate repeat 
postings.
-	Immediately reconcile and resolve the 93 duplicate Coralpay transactions (₦4.8M) and strengthen validation 
rules.
-	Conduct a deep technical and operational review of Irecharge, as it has:
	-	the highest number of missing transactions
	-	the most status mismatches
-	Enforce stricter SLAs and penalties for reconciliation failures with Irecharge.
-	Proactively notify customers for delayed or failed transactions and provide clear timelines for resolution.
-	Implement status validation checks before marking transactions as “successful” in customer-facing channels.
-	Immediately investigate the ₦65.5M worth of transactions marked successful but never received, as this poses financial and reputational risk.
-	Increase system monitoring, capacity, and support staffing around 1pm, when failures peak.
-	Since transaction issues do not correlate with volume, shift focus from scaling capacity to process and provider reliability, especially on Thursdays

## Tools & Technologies
-	SQL (MySQL)
-	MySQL Workbench

## Project Files (included)
-	`data_cleaning.sql` — Data cleaning and transformation in SQL
-	`data_analysis.sql` — SQL script file
-	`/app_transactions/` — raw data files used for analysis (csv)
- 	`/banklink_transcations/` — raw data files used for analysis (csv)
-	`/nibbs_transactions/` — raw data files used for analysis (csv)
-	`/coralpay_transactions/` — raw data files used for analysis (csv)
-	`/irecharge_transactions/` — raw data files used for analysis (csv)
-	`Presentation.pdf` — boardroom slide deck (19 slides)
-	`README.md` — this documentation

## How to Run / View
1.	Import the datasets into your SQL environment
2.	Open script file in SQL editor
3.	Run the queries in the queries folder
4.	Review the results tables
5.	Refer to `Presentation.pdf` for a summary of insights and recommended actions

## Contact 
Loretta Chimezie   
Email: _chimezieloretta@gmail.com_    
LinkedIn: _ https://www.linkedin.com/in/loretta-chimezie/_

