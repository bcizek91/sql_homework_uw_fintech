--Part I 

select count(id)
from transaction

drop view cardholder_fraud_check 
create view cardholder_fraud_check as
select 
	credit_card.cardholder_id as cardholder_id
	, count(distinct transaction.id) as transaction_cnt
	, avg(transaction.amount) as avg_transation_amt
from transaction 
left join credit_card on transaction.card = credit_card.card
	left join card_holder on credit_card.cardholder_id = card_holder.id
where transaction.amount < 2
group by credit_card.cardholder_id
order by transaction_cnt desc

drop view cardholder_transactions
create view cardholder_transactions as
select 
	credit_card.cardholder_id as cardholder_id
	, count(distinct transaction.id) as transaction_cnt
	, avg(transaction.amount) as avg_transaction_amt
from transaction 
left join credit_card on transaction.card = credit_card.card
	left join card_holder on credit_card.cardholder_id = card_holder.id
where transaction.amount >= 2
group by credit_card.cardholder_id
order by transaction_cnt desc

drop view cardholder_transactions_comparison
create view cardholder_transactions_comparison as
select
	cardholder_transactions.cardholder_id as cardholder_id
	, cardholder_fraud_check.transaction_cnt as transaction_cnt_less_2
	, cardholder_transactions.transaction_cnt
	, (cast(cardholder_fraud_check.transaction_cnt as float) / cast(cardholder_transactions.transaction_cnt as float)) * 100 as pct_transactions_less_2
from cardholder_transactions 
inner join cardholder_fraud_check on cardholder_transactions.cardholder_id = cardholder_fraud_check.cardholder_id
order by pct_transactions_less_2 desc

select 
	avg(amount)
from transaction 
left join credit_card on transaction.card = credit_card.card
	left join card_holder on credit_card.cardholder_id = card_holder.id

create view suspect_transactions_7am_9am as
select 
	credit_card.cardholder_id as cardholder_id
	, transaction.amount as transaction_amt
	, cast(transaction.date as time) as timestamp
from transaction 
left join credit_card on transaction.card = credit_card.card
	left join card_holder on credit_card.cardholder_id = card_holder.id
where cast(transaction.date as time) >= '07:00:00' 
	and cast(transaction.date as time) < '09:00:00'
	and transaction.amount > 100
--group by transaction.id
order by transaction_amt desc
limit 100

create view transactions_7am_9am as
select 
	credit_card.cardholder_id as cardholder_id
	, transaction.amount as transaction_amt
	, cast(transaction.date as time) as timestamp
from transaction 
left join credit_card on transaction.card = credit_card.card
	left join card_holder on credit_card.cardholder_id = card_holder.id
where cast(transaction.date as time) >= '07:00:00' 
	and cast(transaction.date as time) < '09:00:00'
	and transaction.amount > 100

--group by transaction.id
order by transaction_amt desc
limit 100

drop view suspect_transactions_24hr
create view suspect_transactions_24hr as
select 
	credit_card.cardholder_id as cardholder_id
	, transaction.amount as transaction_amt
	, cast(transaction.date as time) as timestamp
from transaction 
left join credit_card on transaction.card = credit_card.card
	left join card_holder on credit_card.cardholder_id = card_holder.id
--where cast(transaction.date as time) >= '07:00:00' 
	--and cast(transaction.date as time) < '09:00:00'
--where transaction.amount > 100
--group by transaction.id
order by transaction_amt desc
limit 100

create view top_5_merchants_fraud
from cardholder_fraud_check
outer join suspect_transactions_7am_9am on cardholder_fraud_check

--Average transaction is 40. There are 108 transactions of 100 or more. Therefore more suspect transactions happen between 7am and 9am as a proportion than the rest of the day.

drop view cardholder_fraud_check_merchant
create view cardholder_fraud_check_merchant as
select 
	transaction.id
	, transaction.id_merchant
	--count(distinct transaction.id) as transaction_cnt
	--, avg(transaction.amount) as avg_transation_amt
from transaction 
left join credit_card on transaction.card = credit_card.card
	left join card_holder on credit_card.cardholder_id = card_holder.id
where transaction.amount < 2
--group by transaction.id_merchant
--order by transaction_cnt desc

drop view transactions_7am_9am_merchant
create view transactions_7am_9am_merchant as
select 
	transaction.id
	, transaction.id_merchant
	--credit_card.cardholder_id as cardholder_id
	--, transaction.amount as transaction_amt
	--, cast(transaction.date as time) as timestamp
from transaction 
where cast(transaction.date as time) >= '07:00:00' 
	and cast(transaction.date as time) < '09:00:00'
	and transaction.amount > 100
--group by transaction.id_merchant
--order by count(distinct transaction.id) desc
--limit 100

create view fraud_transactions as
select
	cardholder_fraud_check_merchant.id
	, cardholder_fraud_check_merchant.id_merchant
from cardholder_fraud_check_merchant
full outer join transactions_7am_9am_merchant on cardholder_fraud_check_merchant.id = transactions_7am_9am_merchant.id
where cardholder_fraud_check_merchant.id IS NOT NULL
order by cardholder_fraud_check_merchant desc

create view top_5_fraud_merchant as 
select
	merchant.name as merchant_name
	, count(distinct fraud_transactions.id) as transaction_cnt
from fraud_transactions
left join merchant on fraud_transactions.id_merchant = merchant.id
group by merchant.name
order by transaction_cnt desc
limit 5

--Part II

select
	credit_card.cardholder_id
	, transaction.date
	, transaction.amount
from transaction
left join credit_card on transaction.card = credit_card.card
where credit_card.cardholder_id IN (2, 18)

select
	cast(date as date)
from transaction

select
	credit_card.cardholder_id
	, to_char(transaction.date, 'Month') as month
	, date_part('day', transaction.date) as day
	, transaction.amount
from transaction
left join credit_card on transaction.card = credit_card.card
where credit_card.cardholder_id IN (25) and (cast(transaction.date as date) between '2018-01-01' and '2018-06-01')

