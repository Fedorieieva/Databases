\c lab2;


-- clients who were charged fines for late loan repayment.
SELECT client_id AS overude_client_payment_id, name AS client_name
FROM clients c
WHERE c.client_id IN (
    SELECT cb.account_id
    FROM bank_accounts cb,
         loan_agreements i,
         fines j
    WHERE cb.account_id = i.account_id
    AND i.loan_agreement_id = j.loan_agreement_id
    );


-- clients who took out loans in the amount of
-- more than UAH 1000 last year, repaid them on
-- time and did not take any loans in the current year.
SELECT client_id AS id, name AS client_name
From clients c
WHERE c.client_id IN (
    SELECT cb.account_id
    FROM bank_accounts cb,
         loan_agreements i,
         status_of_loan j
    WHERE cb.account_id = i.account_id
    AND i.loan_agreement_id = j.loan_agreement_id
    AND cb.currency = 'UAH'
    AND j.status = 'closed'
    AND i.loan_issue_date BETWEEN DATE('2022-01-01') AND DATE('2022-12-31')
    AND i.loan_issue_date < DATE('2023-01-01')
    );
