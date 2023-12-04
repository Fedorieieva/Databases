-- вибір всіх клієнтів
SELECT * FROM clients;

-- вибір всіх банківських рахунків, де валюта - UAH
SELECT *
FROM bank_accounts
WHERE currency = 'UAH';

-- вибір всіх банківських рахунків, де баланс менше 10000
SELECT *
FROM bank_accounts
WHERE balance < 10000;

-- вибір всіх банківських рахунків, де баланс менше 7000, більше 1000 і в UAH
SELECT *
FROM bank_accounts
WHERE balance > 1000 AND balance < 7000 AND currency = 'UAH';

-- вибір всіх видів кредитів, де або відсоткова ставка дорівнює 3.9, або строк платежу дорівнює 365
SELECT *
FROM types_of_loans
WHERE interest_rate = 3.9 OR payment_term = 365;

-- вибір всіх видів кредитів, де відсоткова ставка не більше 6
SELECT *
FROM types_of_loans
WHERE NOT interest_rate > 6;

-- вибір всіх клієнтів, де код ЄДРПОУ не є нульовим
SELECT *
FROM clients
WHERE edrpou_code IS NOT NULL;

-- вибір всіх видів кредитів, де або назва 'personal' і відсоткова ставка більше 5, або відсоткова ставка менше 6 і строк платежу більше 125
SELECT *
FROM types_of_loans
WHERE (name = 'Personal' AND interest_rate > 5) OR (interest_rate < 6 AND payment_term > 125);

-- вибір всіх банківських рахунків, де баланс поділений на 1000 більше 20
SELECT *
FROM bank_accounts
WHERE balance / 1000 > 20;

-- вибір всіх клієнтів, чий ідентифікатор входить у цей список (1, 2, 15, 156, 1254, 7)
SELECT *
FROM clients
WHERE client_id IN (1, 2, 15, 156, 1254, 7);

-- вибір всіх банківських рахунків, де баланс між 1000 і 15000
SELECT *
FROM bank_accounts
WHERE balance BETWEEN 1000 AND 15000;

-- вибір всіх клієнтів, чия адреса містить 'Oak'
SELECT *
FROM clients
WHERE address LIKE '%Oak%';

-- вибір всіх штрафів, які були видані між 2017-12-25 і 2019-12-14
SELECT *
FROM fines
WHERE fine_date BETWEEN DATE('2017-12-25') AND DATE('2019-12-14');