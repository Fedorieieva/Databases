\c lab2;


-- selecting all clients
SELECT * FROM clients;


-- selecting all bank_accounts where currency is in UAH
SELECT *
FROM bank_accounts
WHERE currency = 'UAH';


-- selecting all bank_accounts where balance is less than 10000
SELECT *
FROM bank_accounts
WHERE balance < 10000;


-- selecting all bank_accounts where balance is less
-- than 7000, grater than 1000 and in UAH
SELECT *
FROM bank_accounts
WHERE balance > 1000 AND balance <  7000 AND currency = 'UAH';


-- selecting all types_of_loans where either interest rate
-- equals 3.9 or payment term equals 365
SELECT *
FROM types_of_loans
WHERE interest_rate = 3.9 OR payment_term = 365;


-- selecting all types_of_loans where interest rate is not grater than 6
SELECT *
FROM types_of_loans
WHERE NOT interest_rate > 6;


-- select all clients where edrpou_code is not null
SELECT *
FROM clients
WHERE edrpou_code IS NOT NULL;


-- select all types_of_loans where either name is 'personal' and interest rate is grater than 5
-- or where interest rate is less than 6 and payment term is grater than 125
SELECT *
FROM types_of_loans
WHERE (name = 'Personal' AND interest_rate > 5) OR (interest_rate < 6 AND payment_term > 125);


-- select all bank accounts where balance divided by 1000 is grater than 20
SELECT *
FROM bank_accounts
WHERE balance / 1000 > 20;


-- select all clients whose id's in this list (1, 2, 15, 156, 1254, 7)
SELECT *
FROM clients
WHERE client_id IN (1, 2, 15, 156, 1254, 7);


-- select all bank accounts where balance is grater than 1000 and less than 15000
SELECT *
FROM bank_accounts
WHERE balance BETWEEN 1000 AND 15000;


-- select all clients whose address contains 'Oak'
SELECT *
FROM clients
WHERE address LIKE '%Oak%';


-- select all fines that where granted between 2017-12-25 and 2019-12-14
SELECT *
FROM fines
WHERE fine_date BETWEEN DATE('2017-12-25') AND DATE('2019-12-14');
