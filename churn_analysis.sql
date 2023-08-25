use churn_analysis;

# Checking for count of customers

-- select 
-- distinct count(CustomerID)
-- from 
-- ecommerce_data

# checking for duplicate rows

-- select 
-- CustomerId,
-- count(CustomerID)
-- from 
-- ecommerce_data
-- group by 1 
-- having count(CustomerID) > 1

# Checking for null values

-- select 
-- column_name, 
-- data_type,
-- sum(case when column_name is null then 1 else 0 end) as null_count
-- from 
-- information_schema.columns
-- where table_schema = 'churn_analysis' and table_name = 'ecommerce_data'
-- group by 1,2

-- Calculate the average value separately

-- SELECT AVG(Hourspendonapp) INTO @average_value FROM ecommerce_data;

-- Update the table using the calculated average
-- UPDATE ecommerce_data
-- SET Hourspendonapp = @average_value
-- WHERE Hourspendonapp IS NULL;

-- SELECT AVG(tenure) INTO @average_tenure_value FROM ecommerce_data;

-- UPDATE ecommerce_data
-- SET tenure = @average_tenure_value
-- WHERE tenure = ' '

# found two columns the data set which contains binary values 
# churn status and complained status
# both of these columns indicate whether the customer is churned or not and whether customer has any complaints or not
# So in order to leverage that we are going to make some new columns reflecting these changes in a better way

-- alter table ecommerce_data
-- add churn_upd_status nvarchar(25) ;

-- update ecommerce_data
-- set churn_upd_status = 
-- case when churn = 1 then 'Churned' when churn = 0 then 'stayed' end

# Now out of confusion too many columns got added will delete and add the only single status column

-- alter table ecommerce_data
-- drop column churn_status,
-- drop column churn_status_upd,
-- drop column churn_upd_status;

-- alter table ecommerce_data
-- add churn_status nvarchar(25) ;

-- update ecommerce_data
-- set churn_status = 
-- case when churn = 1 then 'Churned' when churn = 0 then 'stayed' end

# Added both churned status and complained status columns to the desired table

-- alter table ecommerce_data
-- add complaint_received nvarchar(50);

-- update ecommerce_data
-- set complaint_received = case when Complain = 0 then 'No' else 'Yes' end

# If we can clearly observe in the data 
# we have redundant data in multiple columns such as Preferred Login Device, Preferred Card payment, Preferred Order Category
# i.e they have multiple options for the same thing 
# for ex credit card and cc (both meant same but entered differently), Preferred device - (Mobile phone and phone) which meant to be
# same. So we are going to fix this making them comes under same option avoiding confusion

# Techniques to find out 

-- select 
-- distint 
-- PreferrredLogiDevice
-- from 
-- ecommerce_data

# Updating all the necessary data, fixing the redundancy

-- update ecommerce_data
-- set PreferredLoginDevice = 'phone' where PreferredLoginDevice = 'Mobile Phone'

-- update ecommerce_data
-- set PreferedOrderCat = 'Mobile Phone' where PreferedOrderCat = 'phone' or PreferedOrderCat = 'Mobile'

-- update ecommerce_data
-- set PreferredPaymentMode = 'Cash on Delivery' where PreferredPaymentMode = 'COD'

-- update ecommerce_data
-- set PreferredPaymentMode = 'Credit Card' where PreferredPaymentMode = 'CC'

# Apart from this in warehousetohome column there is fair chance of having outliers because some values might 
# be mistyped or originally high, so need to fix them

-- update ecommerce_data
-- set warehousetohome = '26' where warehousetohome = '126'

-- update ecommerce_data
-- set warehousetohome = '27' where warehousetohome = '127'

# Fixed few outliers in the data, now we are good to go on exploring the data for required insights

# What is the overall Churn rate

# Churn rate is usually calculated by the formual that total churned customers / total custmers in the data

-- select 
-- round((( select count(distinct CustomerID) from ecommerce_data where churn_status = 'Churned' )  / count(distinct CustomerID)) * 100, 2) as churn_percentage
-- from 
-- ecommerce_data


# How does the churn rate vary based on the preferred login device

-- select 
-- PreferredLoginDevice as preferred_login_device, 
-- count(distinct CustomerID) as total_customers,
-- sum(churn)  as churned_customers,
-- round(( sum(churn) / count(distinct CustomerID)) * 100, 2) 
-- as churn_percentage
-- from 
-- ecommerce_data
-- group by PreferredLoginDevice

# Distribution of Customers across different city tiers

-- select 
-- CityTier, 
-- count(distinct CustomerID) as total_customers,
-- sum(churn) as churned_customers, 
-- ( sum(churn) / count(distinct CustomerID)  ) * 100 as Churn_percentage 
-- from 
-- ecommerce_data
-- group by CityTier
-- order by 4 desc

# Is there any co-relation between the warehouse-to-home distance and customer churn

# IN order to understand the data and customer attributes much better, the numerical format data of ware house to home is not really
# ideal, so in order to make things clear we categorize the distance based upon the ware house to home integer values

-- alter table ecommerce_data
-- add ware_house_to_home_distance nvarchar(50);

-- update ecommerce_data
-- set ware_house_to_home_distance = 
-- case when WarehouseToHome <= 10 then 'Very Close Distance'
-- when WarehouseToHome > 10 and WarehouseToHome <= 20 then 'Close Distance'
-- when WarehouseToHome > 20 and WarehouseToHome <= 30 then 'Moderate Distance'
-- when WarehouseToHome > 30 then 'Far Distance'
-- end

-- select 
-- ware_house_to_home_distance, 
-- count(distinct CustomerID) as total_customers,
-- sum(churn) as churned_customers, 
-- ( sum(churn) / count(distinct CustomerID)  ) * 100 as Churn_percentage 
-- from 
-- ecommerce_data
-- group by ware_house_to_home_distance
-- order by 4 desc

# What is the most prferred payment mode among churned customers

-- select 
-- PreferredPaymentMode, 
-- count(distinct CustomerID) as total_customers,
-- sum(churn) as churned_customers, 
-- ( sum(churn) / count(distinct CustomerID)  ) * 100 as Churn_percentage 
-- from 
-- ecommerce_data
-- group by PreferredPaymentMode
-- order by 4 desc

# What is the typical tenure for Churned Customers 

-- alter table ecommerce_data
-- add tenure_group nvarchar(50);

-- update ecommerce_data
-- set tenure_group = 
-- case when tenure <= 6 then '6 months'
-- when tenure > 6 and tenure <= 12 then '1 year'
-- when tenure > 12 and tenure <= 24 then '2 years'
-- when tenure > 24 then 'More than 2 years'
-- end 

-- select 
-- tenure_group, 
-- count(distinct CustomerID) as total_customers,
-- sum(churn) as churned_customers, 
-- ( sum(churn) / count(distinct CustomerID)  ) * 100 as Churn_percentage 
-- from 
-- ecommerce_data
-- group by tenure_group
-- order by 4 desc

# Churn rate difference between Male and Female Customers

-- select 
-- Gender, 
-- count(distinct CustomerID) as total_customers,
-- sum(churn) as churned_customers, 
-- ( sum(churn) / count(distinct CustomerID)  ) * 100 as Churn_percentage 
-- from 
-- ecommerce_data
-- group by Gender
-- order by 4 desc


# Average time spent on App by Normal Customers vs Churned Customers

-- select 
-- count(distinct CustomerID) as normal_customers,
-- (select count(distinct CustomerID) from ecommerce_data where churn = 1) as churned_customers,
-- round(avg(HourSpendOnApp)) as hours_spend_by_normal_customer,
-- round((select avg(HourSpendOnApp) from ecommerce_data where churn = 1)) as hours_spend_by_churned_customer
-- from 
-- ecommerce_data
-- where churn = 0

# Alternative

-- select
-- churn_status,
-- round(avg(HourSpendOnApp)) as hours_spent
-- from 
-- ecommerce_data
-- group by churn_status

# Does Number of registered devices impact the churn rate

-- select 
-- NumberOfDeviceRegistered, 
-- count(distinct CustomerID) as total_customers,
-- sum(churn) as churned_customers, 
-- ( sum(churn) / count(distinct CustomerID)  ) * 100 as Churn_percentage 
-- from 
-- ecommerce_data
-- group by NumberOfDeviceRegistered
-- order by 4 desc

# Which order category is most preferred among churned customers

-- select 
-- PreferedOrderCat, 
-- count(distinct CustomerID) as total_customers,
-- sum(churn) as churned_customers, 
-- ( sum(churn) / count(distinct CustomerID)  ) * 100 as Churn_percentage 
-- from 
-- ecommerce_data
-- group by PreferedOrderCat
-- order by 4 desc

# Is there any relation between Customer Satisfaction scores and churn rate

-- select 
-- SatisfactionScore, 
-- count(distinct CustomerID) as total_customers,
-- sum(churn) as churned_customers, 
-- ( sum(churn) / count(distinct CustomerID)  ) * 100 as Churn_percentage 
-- from 
-- ecommerce_data
-- group by SatisfactionScore
-- order by 4 desc

# Does Marital Status affect the churn percentage

-- select 
-- MaritalStatus, 
-- count(distinct CustomerID) as total_customers,
-- sum(churn) as churned_customers, 
-- ( sum(churn) / count(distinct CustomerID)  ) * 100 as Churn_percentage 
-- from 
-- ecommerce_data
-- group by MaritalStatus
-- order by 4 desc

# Typically how many overall addresses and average address does the churned customers have

-- select 
-- round(avg(NumberOfAddress)) as avg_adresses
-- from 
-- ecommerce_data
-- where churn_status = 'Churned'

# Does Customer complaints affects the churn rate

-- select 
-- complaint_received,
-- count(distinct CustomerID) as total_customers,
-- sum(churn) as churned_customers,
-- (sum(churn) / count(distinct CustomerID)) * 100 as churn_percentage
-- from 
-- ecommerce_data
-- group by complaint_received
-- order by 4 desc

# How does the use of coupons differ between churned and non-churned customers

-- select 
-- churn_status,
-- sum(CouponUsed) as coupons_used
-- from 
-- ecommerce_data
-- group by churn_status

# What is the average number of days since the last order for churned customers

-- select
-- round(avg(DaySinceLastOrder)) as days_since_last_order
-- from 
-- ecommerce_data
-- where churn_status = 'Churned'

# Is there any relation between Cashback amount and Churn rate

# binning cashback amount into categories for deeper analysis

-- alter table ecommerce_data
-- add cash_back_category nvarchar(50);

-- update ecommerce_data
-- set cash_back_category = 
-- case when CashbackAmount <= 100 then 'less cashback'
-- when CashbackAmount > 100 and CashbackAmount <= 200 then 'Moderate Cash back'
-- when CashbackAmount > 200 and CashbackAmount <= 300 then 'Good Cash back'
-- when CashbackAmount > 300 then 'Very High cash back'
-- end

select 
cash_back_category,
count(distinct CustomerID) as total_customers,
sum(churn) as churned_customers,
(sum(churn) / count(distinct CustomerID)) * 100 as churn_percentage
from 
ecommerce_data
group by cash_back_category
order by 4 desc






