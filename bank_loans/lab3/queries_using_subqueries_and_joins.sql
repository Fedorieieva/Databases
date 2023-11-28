\c lab2;


-- selecting bank account id and client loan amount from each account
SELECT cb.account_id,
       (SELECT i.loan_amount
        FROM loan_agreements i
        WHERE cb.account_id = i.account_id) AS client_loan_amount
FROM bank_accounts AS cb;


-- selecting payments and fines where loan agreement id
-- equals fine and payment id
SELECT aa.payments, aa.fines
FROM (
  SELECT a.payment_amount AS payments, b.fine_amount AS fines
  FROM payments a,
       fines b,
       loan_agreements c
  WHERE a.payment_id = c.loan_agreement_id
    AND b.fine_id = c.loan_agreement_id
) AS aa;


-- selecting client name and type of property where edrpou code is present
SELECT name, type_of_property
FROM clients
WHERE EXISTS (
    SELECT *
    FROM clients
    WHERE edrpou_code IS NOT NULL
    );


-- selecting client id and client name where loan amount is
-- less than 5000 and status of the loan agreement is active
SELECT client_id AS id, name AS client_name
FROM clients c
WHERE c.client_id IN (
    SELECT cb.client_id
    FROM bank_accounts cb,
         loan_agreements i,
         status_of_loan j
    WHERE cb.account_id = i.account_id
    AND i.loan_agreement_id = j.loan_agreement_id
    AND i.loan_amount < 5000
    AND j.status = 'active'
);


-- selecting all columns from clients and bank accounts using right join
SELECT *
FROM clients
RIGHT JOIN bank_accounts cb ON clients.client_id = cb.client_id;



-- selecting all columns from types of loans and loan agreements using an INNER JOIN
SELECT *
FROM types_of_loans a
JOIN loan_agreements v ON a.type_of_loan_id = v.type_of_loan_id;


-- selecting all columns from types of loans and loan agreements
-- where loan amount is less than 1000 using JOIN
SELECT *
FROM types_of_loans a
JOIN loan_agreements v ON a.type_of_loan_id = v.type_of_loan_id
WHERE v.loan_amount < 1000;


-- selecting payment id, payment amount, payment date, and loan agreement id
-- from payments where status is 'overdue' of loan using an INNER JOIN
SELECT p.payment_id, p.payment_amount, p.payment_date, p.loan_agreement_id, s.loan_agreement_id
FROM payments p
INNER JOIN status_of_loan s ON p.loan_agreement_id = s.loan_agreement_id
WHERE s.status = 'overdue';


-- selecting client id and balance from clients and bank accounts
-- using LEFT JOIN where balance is between 1000 and 2354
SELECT v.client_id, ca.balance
FROM clients v
LEFT JOIN bank_accounts ca ON v.client_id = ca.client_id
WHERE ca.balance BETWEEN 1000 AND 2354;


-- selecting client id and balance from clients and bank accounts
-- using RIGHT JOIN where balance is between 1000 and 2354
SELECT v.client_id, ca.balance
FROM clients v
RIGHT JOIN bank_accounts ca ON v.client_id = ca.client_id
WHERE ca.balance BETWEEN 1000 AND 2354;


-- selecting account balance from bank accounts and
-- payment amount from payments using UNION
SELECT balance AS account_balance
FROM bank_accounts
UNION
SELECT payment_amount
FROM payments;
Ф