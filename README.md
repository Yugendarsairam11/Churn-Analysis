# Churn-Analysis

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
