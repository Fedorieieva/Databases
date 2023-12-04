-- 1a. Підрахунок кількості клієнтів з адресою, що містить 'Elm'.
SELECT COUNT(client_id) FROM clients WHERE address LIKE '%Elm%';


-- 1b. Сума балансів банківських рахунків, де баланс більший за 5000.
SELECT SUM(balance) FROM bank_accounts WHERE balance > 5000;


-- 1c. Підрахунок кількості рахунків за кожен унікальний баланс.
SELECT COUNT(balance), balance
FROM bank_accounts
GROUP BY balance;


-- 1d. Вибір індивідуальних рахунків та їхніх максимальних балансів, де максимальний баланс менший або рівний 10000.
SELECT account_id, MAX(balance) AS max_balance
FROM bank_accounts
GROUP BY account_id
HAVING MAX(balance) <= 10000;


-- 1e. Середній баланс усіх банківських рахунків, де середній баланс більший за 1.
SELECT AVG(balance)
FROM bank_accounts
HAVING AVG(balance) > 1;


-- 1f. Нумерація рядків в таблиці штрафів відсортованих за датою штрафування.
SELECT ROW_NUMBER() OVER (ORDER BY fine_date) AS  row_number, fine_id, fine_date
FROM fines;


-- 1g. Об'єднання даних про клієнтів та їхні банківські рахунки з групуванням за іменем та контактною особою клієнта,
-- впорядковане за кількістю рахунків для кожного клієнта у зменшувальному порядку.
SELECT CONCAT(c.name, ' ', c.contact_person) AS client_and_contact_person,
       c.type_of_property
FROM bank_accounts b
JOIN clients c ON b.client_id = c.client_id
GROUP BY c.name, c.contact_person, c.type_of_property
ORDER BY COUNT(c.client_id) DESC;


-- 1.h1. Визначені клієнти, які мають штрафи та
-- відсортовані в порядку спадання суми штрафу
SELECT c.client_id, c.name, j.fine_amount
FROM clients c
JOIN bank_accounts cb ON c.client_id = cb.client_id
JOIN loan_agreements i ON cb.account_id = i.account_id
JOIN fines j ON i.loan_agreement_id = j.loan_agreement_id
WHERE c.client_id IN (
    SELECT cb.client_id
    FROM bank_accounts cb
    JOIN loan_agreements i ON cb.account_id = i.account_id
    JOIN fines j ON i.loan_agreement_id = j.loan_agreement_id
    GROUP BY cb.client_id
    HAVING MAX(j.fine_amount) > 1
)
GROUP BY c.client_id, c.name, j.fine_amount
ORDER BY j.fine_amount DESC;




-- 1.h2. Підрахунок кількості видів кредитів для кожного виду, впорядкований за кількістю кожного виду у зменшувальному порядку.
-- перший рядок визначить найпопулярніший вид кредиту
SELECT name AS loan_type, COUNT(*) AS loan_count
FROM types_of_loans
GROUP BY loan_type
ORDER BY loan_count DESC;
