-- клієнти, які були покарані штрафами за прострочену сплату кредиту.
SELECT name AS client_name
FROM clients c
WHERE c.client_id IN (
    SELECT cb.client_id
    FROM bank_accounts cb,
         loan_agreements i,
         fines j
    WHERE cb.account_id = i.account_id
    AND i.loan_agreement_id = j.loan_agreement_id
);

-- клієнти, які взяли кредити на суму більше 1000 гривень минулого року,
-- вчасно їх погасили та не взяли жодного кредиту в поточному році.
SELECT c.client_id AS id, c.name AS client_name
FROM clients c
WHERE c.client_id IN (
    -- Підзапит, який визначає клієнтів,
    -- що брали кредит минулого року та погасили його
    SELECT DISTINCT cb.client_id
    FROM bank_accounts cb
    JOIN loan_agreements i ON cb.account_id = i.account_id
    JOIN status_of_loan j ON i.loan_agreement_id = j.loan_agreement_id
    WHERE cb.currency = 'UAH'
    AND j.status = 'closed'
    AND i.loan_amount > 1000
    AND i.loan_issue_date BETWEEN CURRENT_DATE - INTERVAL '1 year' AND CURRENT_DATE
    AND NOT EXISTS (
        -- Перевірка, чи клієнт не брав кредит у поточному році
        -- та чи не здійснив оплату в цьому році
        SELECT 1
        FROM loan_agreements i2
        LEFT JOIN payments p ON i2.loan_agreement_id = p.loan_agreement_id
        WHERE i2.account_id = cb.account_id
        -- Кредит не повинен бути взятий в поточному році
        AND i2.loan_issue_date >= CURRENT_DATE - INTERVAL '1 year'
        AND i2.loan_issue_date < CURRENT_DATE
        -- Перевірка чи була здійснена оплата в поточному році
        AND p.payment_date IS NULL
    )
);




