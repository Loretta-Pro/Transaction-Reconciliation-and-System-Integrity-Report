select count(distinct txnref) as app_banktransfers
from app_tranz
where transaction_type = 'bank_transfer';

select count(distinct b.transaction_id) as apptranz_in_banklink
from banklink_tranz b
join app_tranz a on b.merchantref = a.txnref
where a.transaction_type = 'bank_transfer';

select count(distinct b.transaction_id) as banklinktranz_in_nibbs
from banklink_tranz b
join nibbs_tranz n on b.transaction_id = n.transaction_id;

select count(distinct b.transaction_id) as app_banklink_nibbs
from banklink_tranz b
join app_tranz a on b.merchantref = a.txnref
join nibbs_tranz n on b.transaction_id = n.transaction_id;

select merchantref as ghost_app_transfers from banklink_tranz b
where not exists (select txnRef from app_tranz a 
			where b.merchantref = a.txnref);
            
select transaction_id as ghost_banklink_transfers, amount, status, settlement_date from nibbs_tranz n
where not exists (select b.transaction_id from banklink_tranz b 
			where n.transaction_id = b.transaction_id);
            
select txnref as orphaned_app_transfers, amount, status from app_tranz a
where not exists (select txnRef from banklink_tranz b
			where b.merchantref = a.txnref) and transaction_type = 'bank_transfer';

select merchantref as orphaned_banklink_tranz, amount, status from banklink_tranz b 
where not exists (select transaction_id from nibbs_tranz n 
			where n.transaction_id = b.transaction_id);

with orphaned_transactions as
(
select txnref, amount, status from app_tranz a
where not exists (select txnRef from banklink_tranz b
			where b.merchantref = a.txnref) and transaction_type = 'bank_transfer' 
union all
select merchantref, amount, status from banklink_tranz b 
where not exists (select transaction_id from nibbs_tranz n 
			where n.transaction_id = b.transaction_id)
)
select count(txnref) as orphaned_transfer, round(sum(amount), 0) as total_orphaned_transfer
from orphaned_transactions;



select * from app_tranz a
join coralpay_tranz c on a.txnref = c.txnref
join irecharge_tranz i on a.txnref = i.txnref;

select a.txnref as orphaned_utility, a.transaction_type, a.amount, a.status, a.provider
from app_tranz a
left join coralpay_tranz c on a.txnref = c.txnref
left join irecharge_tranz i on a.txnref = i.txnref
where a.transaction_type <> 'bank_transfer' and c.txnref is null and i.txnref is null;

select * from app_tranz a
join irecharge_tranz i on a.txnref = i.txnref
where a.transaction_type <> 'bank_transfer' and a.provider = 'coralpay';

select * from app_tranz a
join coralpay_tranz c on a.txnref = c.txnref
where a.transaction_type <> 'bank_transfer' and a.provider = 'irecharge';

select * from coralpay_tranz c
where not exists (select txnRef from app_tranz a 
			where c.txnref = a.txnref);

select * from irecharge_tranz i
where not exists (select txnRef from app_tranz a 
			where i.txnref = a.txnref);

with duplicate_app_coralpay as
(
select a.txnref as duplicate_app, count(c.txnref) as duplicate_count, sum(c.amount) as amount, a.status 
from app_tranz a
join coralpay_tranz c on a.txnref = c.txnref
where a.transaction_type <> 'bank_transfer' and a.provider = 'coralpay'
group by a.txnref, a.status
having count(c.txnref) > 1
) 
select count(duplicate_app) as duplicate_coralpay, round(sum(amount), 0) as total_duplicate_coralpay
from duplicate_app_coralpay;



with transfer_status_mismatched as
(
select * from app_tranz a 
where a.transaction_type = 'bank_transfer' and a.status = 'successful'
) select * from transfer_status_mismatched t
join banklink_tranz b on t.txnref = b.merchantref
where b.status = 'failed';

select * from banklink_tranz b
join nibbs_tranz n on b.transaction_id = n.transaction_id
where b.status = 'successful' and n.status = 'failed';

select count(txnref) as utility_status_mismatches, round(sum(amount), 0) as total_utility_mismatches from
(select a.txnref, a.amount from app_tranz a 
join coralpay_tranz c on a.txnref = c.txnref
where a.transaction_type <> 'bank_transfer' and 
(a.status = 'successful' and c.status = 'failed') or (a.status = 'failed' and c.status = 'successful')
union all
select a.txnref, a.amount from app_tranz a 
join irecharge_tranz i on a.txnref = i.txnref 
where a.transaction_type <> 'bank_transfer' and 
(a.status = 'successful' and i.status = 'failed') or (a.status = 'failed' and i.status = 'successful')) t;

select count(transaction_id)as count_status_discrepancies, round(sum(amount), 0) as total_status_discrepancies from
(select b.transaction_id, b.amount from app_tranz a 
join banklink_tranz b on a.txnref = b.merchantref
where a.transaction_type = 'bank_transfer' and 
(a.status = 'successful' and b.status = 'failed') or (a.status = 'failed' and b.status = 'successful')
union all
select b.transaction_id, b.amount from banklink_tranz b
join nibbs_tranz n on b.transaction_id = n.transaction_id
where (b.status = 'successful' and n.status = 'failed') or (b.status = 'failed' and n.status = 'successful')
union all
select a.txnref, a.amount from app_tranz a 
join coralpay_tranz c on a.txnref = c.txnref
where a.transaction_type <> 'bank_transfer' and 
(a.status = 'successful' and c.status = 'failed') or (a.status = 'failed' and c.status = 'successful')
union all
select a.txnref, a.amount from app_tranz a 
join irecharge_tranz i on a.txnref = i.txnref
where a.transaction_type <> 'bank_transfer' and 
(a.status = 'successful' and i.status = 'failed') or (a.status = 'failed' and i.status = 'successful')) t;



select round((select count(*) from banklink_tranz b
join app_tranz a on b.merchantref = a.txnref
join nibbs_tranz n on b.transaction_id = n.transaction_id
where b.status = 'successful' and a.status = 'successful' and n.status = 'successful') * 100/
(select count(*) as app_banklink_nibbs
from banklink_tranz b
join app_tranz a on b.merchantref = a.txnref
join nibbs_tranz n on b.transaction_id = n.transaction_id), 0) as transfers_success_rate;

select round((select count(*) from app_tranz a
join coralpay_tranz c on a.txnref = c.txnref
where a.transaction_type <> 'bank transfer' and a.status = 'successful' and c.status = 'successful') * 100/
(select count(*) from app_tranz a
join coralpay_tranz c on a.txnref = c.txnref
where a.transaction_type <> 'bank transfer'), 1) as coraypay_successrate;

select round((select count(*) from app_tranz a
join irecharge_tranz i on a.txnref = i.txnref
where a.transaction_type <> 'bank_transfer' and a.status = 'successful' and i.status = 'successful') * 100/
(select count(*) from app_tranz a
join irecharge_tranz i on a.txnref = i.txnref
where a.transaction_type <> 'bank_transfer'), 1) as irecharge_successrate;

select (select count(*) from app_tranz a
where not exists (select txnRef from coralpay_tranz c
	where a.txnref = c.txnref) and a.transaction_type <> 'bank_transfer'
    and a.provider = 'coralpay') as coralpay_mssing_tranz,
(select count(*) from app_tranz a
where not exists (select txnRef from irecharge_tranz i
	where a.txnref = i.txnref) and a.transaction_type <> 'bank_transfer'
    and a.provider = 'irecharge') as irecharge_missing_tranz;

select (select count(*) from app_tranz a 
join coralpay_tranz c on a.txnref = c.txnref
where a.transaction_type <> 'bank_transfer' and 
	(a.status = 'successful' and c.status = 'failed') or
	(a.status = 'failed' and c.status = 'successful')) as coralpay_status_mismatch,
(select count(*) from app_tranz a 
join irecharge_tranz i on a.txnref = i.txnref
where a.transaction_type <> 'bank_transfer' and 
	(a.status = 'successful' and i.status = 'failed') or
	(a.status = 'failed' and i.status = 'successful')) as irecharge_status_mismatch;



with missing_banklink_tranz as 
( 
select txnref, amount from app_tranz a
where not exists (select txnRef from banklink_tranz b where b.merchantref = a.txnref) 
	and transaction_type = 'bank_transfer'
union all
select transaction_id, amount from nibbs_tranz n
where not exists (select transaction_id from banklink_tranz b where n.transaction_id = b.transaction_id)
)
select count(txnref) as missing_banklink, round(sum(amount), 0) as total_missing_banklink
from missing_banklink_tranz;

select count(b.transaction_id) as missing_nibbs, round(sum(b.amount), 0) as total_missing_nibbs
from banklink_tranz b
left join nibbs_tranz n on b.transaction_id = n.transaction_id
where n.transaction_id is null;

select count(txnref) as missing_utility_tranz, round(sum(amount), 0) as total_missing_utility from 
(select a.txnref, a.amount from app_tranz a
left join coralpay_tranz c on a.txnref = c.txnref
left join irecharge_tranz i on a.txnref = i.txnref
where a.transaction_type <> 'bank_transfer' and c.txnref is null and i.txnref is null
union all
select txnref, amount from coralpay_tranz c
where not exists (select txnRef from app_tranz a where a.txnref = c.txnref)
union all
select txnref, amount from irecharge_tranz i
where not exists (select txnRef from app_tranz a where a.txnref = i.txnref)) m;

select count(a.txnref) as duplicate_utility_tranz, round(sum(a.amount), 0) as total_duplicate_utility
from app_tranz a
join coralpay_tranz c on a.txnref = c.txnref
join irecharge_tranz i on a.txnref = i.txnref
where a.transaction_type <> 'bank_transfer';

select count(transaction_id)as count_status_mismatches, round(sum(amount), 0) as total_status_mismatches from
(select b.transaction_id, b.amount from app_tranz a 
join banklink_tranz b on a.txnref = b.merchantref
where a.transaction_type = 'bank_transfer' and 
(a.status = 'successful' and b.status = 'failed') or (a.status = 'failed' and b.status = 'successful')
union all
select b.transaction_id, b.amount from banklink_tranz b
join nibbs_tranz n on b.transaction_id = n.transaction_id
where (b.status = 'successful' and n.status = 'failed') or (b.status = 'failed' and n.status = 'successful')
union all
select a.txnref, a.amount from app_tranz a 
join coralpay_tranz c on a.txnref = c.txnref
where a.transaction_type <> 'bank_transfer' and 
(a.status = 'successful' and c.status = 'failed') or (a.status = 'failed' and c.status = 'successful')
union all
select a.txnref, a.amount from app_tranz a 
join irecharge_tranz i on a.txnref = i.txnref
where a.transaction_type <> 'bank_transfer' and 
(a.status = 'successful' and i.status = 'failed') or (a.status = 'failed' and i.status = 'successful')) t;

create table Lost_revenue as
select a.txnref, a.amount, a.`date`, a.status from app_tranz a
left join banklink_tranz b on a.txnref = b.merchantref
where a.transaction_type = 'bank_transfer' and b.transaction_id is null
union all
select b.transaction_id, b.amount, b.`date`, b.status from banklink_tranz b
left join nibbs_tranz n on b.transaction_id = n.transaction_id
where n.transaction_id is null
union all
select a.txnref, a.amount, a.`date`, a.status from app_tranz a
left join coralpay_tranz c on a.txnref = c.txnref
left join irecharge_tranz i on a.txnref = i.txnref
where a.transaction_type <> 'bank_transfer' and c.txnref is null and i.txnref is null
union all
select b.transaction_id, a.amount, a.`date`, a.status from app_tranz a 
join banklink_tranz b on a.txnref = b.merchantref
where a.transaction_type = 'bank_transfer' and 
(a.status = 'successful' and b.status = 'failed') or (a.status = 'failed' and b.status = 'successful')
union all
select b.transaction_id, b.amount, b.`date`, b.status from banklink_tranz b
join nibbs_tranz n on b.transaction_id = n.transaction_id
where (b.status = 'successful' and n.status = 'failed') or (b.status = 'failed' and n.status = 'successful')
union all
select a.txnref, a.amount, a.`date`, a.status from app_tranz a 
join coralpay_tranz c on a.txnref = c.txnref
where a.transaction_type <> 'bank_transfer' and 
(a.status = 'successful' and c.status = 'failed') or (a.status = 'failed' and c.status = 'successful')
union all
select a.txnref, a.`date`, a.amount, a.status from app_tranz a 
join irecharge_tranz i on a.txnref = i.txnref
where a.transaction_type <> 'bank_transfer' and 
(a.status = 'successful' and i.status = 'failed') or (a.status = 'failed' and i.status = 'successful')
union all
select b.transaction_id, b.amount, b.`date`, b.status from banklink_tranz b
where not exists (select txnRef from app_tranz a where b.merchantref = a.txnref)
union all
select n.transaction_id, n.amount, n.settlement_date, n.status from nibbs_tranz n
where not exists (select transaction_id from banklink_tranz b where n.transaction_id = b.transaction_id)
union all
select c.txnref, c.amount, c.`date`, c.status from coralpay_tranz c
where not exists (select txnRef from app_tranz a where a.txnref = c.txnref)
union all
select i.txnref, i.amount, i.`date`, i.status from irecharge_tranz i
where not exists (select txnRef from app_tranz a where a.txnref = i.txnref);

select * from Lost_revenue;

with loss_count as(
select date(a.`date`) as day, count(l.txnref) as loss_count, count(a.txnref) as tranz_count from app_tranz a
left join lost_revenue l on a.txnref = l.txnref
group by date(`date`) order by date(`date`) desc
), 
daily_loss_rate as (select *, round((loss_count * 100/ tranz_count), 1) as loss_rate
from loss_count
) select round(avg(loss_rate), 1) as daily_average_loss_rate
from daily_loss_rate;



with daily_issues as
(select date(`date`) as `day`, dayname(`date`) as day_name, count(distinct txnref) as loss_count 
from lost_revenue
group by date(`date`), dayname(`date`)
order by date(`date`) desc
) select day_name, sum(loss_count) as no_of_issues from daily_issues
group by day_name order by no_of_issues desc;

with monthly_issues as
(select date(`date`) as `month`, monthname(`date`) as month_name, count(distinct txnref) as loss_count 
from lost_revenue
group by date(`date`), monthname(`date`)
order by date(`date`) desc
) select month_name, sum(loss_count) as no_of_issues from monthly_issues
group by month_name order by no_of_issues desc;

select hour(`time`) as hour_of_day, count(txnref) as transaction_count, round(sum(amount), 0) as total_amount, 
round(avg(amount), 1) as average_amount from app_tranz
where status = 'failed'
group by hour(`time`) order by 2 desc;

select dayname(a.date) as day, count(l.txnref) as issues_count, count(a.txnref) as transaction_count, 
round(sum(a.amount), 0) as total_value from app_tranz a
left join lost_revenue l on a.txnref = l.txnref
group by dayname(date) order by 2 desc;


