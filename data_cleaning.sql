use my_project3;
select * from app_transactions;

create table app_tranz
like app_transactions;

select * from app_tranz;

insert into app_tranz
select * from app_transactions;

select distinct(txnref) from app_tranz;

alter table app_tranz
modify column `date` date;

alter table app_tranz
modify column `time` time;

create table banklink_tranz
like banklink_transactions;

select * from banklink_tranz;

insert into banklink_tranz
select * from banklink_transactions;

select distinct(status) from banklink_tranz;

alter table banklink_tranz
modify column `date` date;

alter table banklink_tranz
modify column `time` time;


create table coralpay_tranz
like coralpay_transactions;

select * from coralpay_tranz;

insert into coralpay_tranz
select * from coralpay_transactions;

select distinct(status) from coralpay_tranz;

alter table coralpay_tranz
modify column `date` date;

alter table coralpay_tranz
modify column `time` time;

create table irecharge_tranz
like irecharge_transactions;

select * from irecharge_tranz;

insert into irecharge_tranz
select * from irecharge_transactions;

select distinct(service_type) from irecharge_tranz;

alter table irecharge_tranz
modify column `date` date;

alter table irecharge_tranz
modify column `time` time;

create table nibbs_tranz
like nibbs_transactions;

select * from nibbs_tranz;

insert into nibbs_tranz
select * from nibbs_transactions;

select distinct(settlement_date) from nibbs_tranz;

alter table nibbs_tranz
modify column settlement_date date;

select count(*) from coralpay_tranz where amount is null or trim(amount) = '';


describe app_tranz;