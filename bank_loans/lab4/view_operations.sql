-- a. Створення або оновлення представлення котре містить дані з декількох таблиць
-- client_balance_info, що містить інформацію про клієнтів та баланс їхніх банківських рахунків.
CREATE OR REPLACE VIEW client_balance_info AS
  SELECT c.client_id, c.name, ba.balance
  FROM clients c
  RIGHT JOIN bank_accounts ba ON c.client_id = ba.client_id
  ORDER BY c.client_id;

SELECT * FROM client_balance_info;


-- b. Створення або оновлення представлення котре містить дані з декількох таблиць та використовує представлення, котре створене в п.a
-- client_balance_loan_agreement, що містить інформацію про клієнтів, їхні банківські рахунки та кредитні угоди.
CREATE OR REPLACE VIEW client_balance_loan_agreement AS
SELECT c.client_id,
       la.loan_agreement_id,
       cbi.name,
       ba.balance,
       la.loan_amount
FROM clients c
RIGHT JOIN bank_accounts ba ON c.client_id = ba.client_id
RIGHT JOIN loan_agreements la ON ba.account_id = la.account_id
RIGHT JOIN client_balance_info cbi ON ba.client_id = cbi.client_id;

SELECT * FROM client_balance_loan_agreement;


-- c. Модифікування представлення client_balance_info, що містить інформацію про клієнтів, баланс їхніх банківських рахунків та середні кредити та штрафи.
CREATE OR REPLACE VIEW client_balance_info AS
    SELECT c.client_id,
           c.name,
           ba.balance,
           ba.currency,
           AVG(la.loan_amount) AS avg_loan_amount,
           AVG(f.fine_amount) AS avg_fine_amount
    FROM clients c
    LEFT JOIN bank_accounts ba ON c.client_id = ba.client_id
    LEFT JOIN loan_agreements la ON ba.account_id = la.account_id
    LEFT JOIN fines f ON la.loan_agreement_id = f.loan_agreement_id
    GROUP BY c.client_id, c.name, ba.balance, ba.currency;

SELECT * FROM client_balance_info;


-- d. Вибір інформації про перші два представлення у базі даних, використовуючи таблицю information_schema.views.
SELECT table_schema, table_name AS view_name, view_definition
FROM information_schema.views;
