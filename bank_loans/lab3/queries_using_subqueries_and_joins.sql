-- вибір ідентифікатора банківського рахунку та суми кредиту клієнта з кожного рахунку
SELECT cb.account_id,
    (SELECT i.loan_amount
    FROM loan_agreements i
    WHERE cb.account_id = i.account_id) AS client_loan_amount
FROM bank_accounts AS cb;

-- вибір платежів та штрафів, де ідентифікатор угоди про кредит дорівнює ідентифікатору штрафу та платежу
SELECT aa.payments, aa.fines
FROM (
SELECT a.payment_amount AS payments, b.fine_amount AS fines
FROM payments a,
fines b,
loan_agreements c
WHERE a.loan_agreement_id = c.loan_agreement_id
AND b.loan_agreement_id = c.loan_agreement_id
) AS aa;

-- вибір імені клієнта та типу власності, де код ЄДРПОУ присутній
SELECT name, type_of_property, edrpou_code
FROM clients c1
WHERE EXISTS (
    SELECT *
    FROM clients c2
    WHERE c2.edrpou_code IS NOT NULL
    AND c1.client_id = c2.client_id
);


-- вибір ідентифікатора клієнта та імені клієнта, де сума кредиту менше 5000 і статус угоди про кредит активний
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

-- вибір усіх колонок з клієнтів та банківських рахунків за допомогою правого з'єднання
SELECT *
FROM clients
RIGHT JOIN bank_accounts cb ON clients.client_id = cb.client_id;

-- вибір усіх колонок з видів кредитів та угод про кредит за допомогою JOIN
SELECT *
FROM types_of_loans a, loan_agreements v
WHERE a.type_of_loan_id = v.type_of_loan_id;

-- вибір усіх колонок з видів кредитів та угод про кредит, де сума кредиту менше 1000 за допомогою JOIN
SELECT *
FROM types_of_loans a, loan_agreements v
WHERE a.type_of_loan_id = v.type_of_loan_id
AND v.loan_amount < 1000;

-- вибір ідентифікатора платежу, суми платежу, дати платежу та ідентифікатора угоди про кредит
-- з платежів, де статус кредиту 'прострочений' за допомогою INNER JOIN
SELECT p.payment_id, p.payment_amount, p.payment_date, p.loan_agreement_id, s.loan_agreement_id
FROM payments p
INNER JOIN status_of_loan s ON p.loan_agreement_id = s.loan_agreement_id
WHERE s.status = 'overdue';

-- вибір ідентифікатора клієнта та балансу з клієнтів та банківських рахунків
-- за допомогою LEFT JOIN, де баланс між 1000 і 2354
SELECT v.client_id, ca.balance
FROM clients v
LEFT JOIN bank_accounts ca ON v.client_id = ca.client_id
WHERE ca.balance BETWEEN 1000 AND 2354;

-- вибір ідентифікатора клієнта та балансу з клієнтів та банківських рахунків
-- за допомогою RIGHT JOIN, де баланс між 1000 і 2354
SELECT v.client_id, ca.balance
FROM clients v
RIGHT JOIN bank_accounts ca ON v.client_id = ca.client_id
WHERE ca.balance BETWEEN 1000 AND 2354;

-- вибір балансу рахунку з банківських рахунків та суми платежу з платежів за допомогою UNION
SELECT balance AS account_balance, NULL AS payment_amount
FROM bank_accounts
UNION
SELECT NULL AS account_balance, payment_amount
FROM payments;
