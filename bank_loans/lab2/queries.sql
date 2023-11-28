ALTER TABLE clients
    ALTER COLUMN client_id SET NOT NULL,
    ALTER COLUMN name SET NOT NULL,
    ALTER COLUMN phone_number SET NOT NULL,
    ALTER COLUMN address SET NOT NULL;

ALTER TABLE bank_accounts
    ALTER COLUMN account_id SET NOT NULL,
    ALTER COLUMN currency SET DEFAULT 'uah',
    ALTER COLUMN currency SET NOT NULL,
    ALTER COLUMN balance SET DEFAULT 0.0,
    ALTER COLUMN balance SET NOT NULL,
    ALTER COLUMN client_id SET NOT NULL;

ALTER TABLE types_of_loans
    ALTER COLUMN type_of_loan_id SET NOT NULL,
    ALTER COLUMN name SET NOT NULL,
    ALTER COLUMN interest_rate SET DEFAULT 0.01,
    ALTER COLUMN interest_rate SET NOT NULL,
    ALTER COLUMN payment_term SET NOT NULL;

ALTER TABLE loan_agreements
    ALTER COLUMN loan_agreement_id SET NOT NULL,
    ALTER COLUMN loan_amount SET DEFAULT 1,
    ALTER COLUMN loan_amount SET NOT NULL,
    ALTER COLUMN loan_issue_date SET NOT NULL,
    ALTER COLUMN loan_repayment_date SET NOT NULL,
    ALTER COLUMN account_id SET NOT NULL,
    ALTER COLUMN type_of_loan_id SET NOT NULL;

ALTER TABLE status_of_loan
    ALTER COLUMN status_id SET NOT NULL,
    ALTER COLUMN status SET DEFAULT 'active',
    ALTER COLUMN status SET NOT NULL,
    ALTER COLUMN date_of_change SET NOT NULL,
    ALTER COLUMN loan_agreement_id SET NOT NULL;

ALTER TABLE payments
    ALTER COLUMN payment_id SET NOT NULL,
    ALTER COLUMN payment_amount SET DEFAULT 0.01,
    ALTER COLUMN payment_amount SET NOT NULL,
    ALTER COLUMN payment_date SET NOT NULL,
    ALTER COLUMN loan_agreement_id SET NOT NULL;

ALTER TABLE fines
    ALTER COLUMN fine_id SET NOT NULL,
    ALTER COLUMN fine_amount SET NOT NULL,
    ALTER COLUMN fine_reason SET NOT NULL,
    ALTER COLUMN fine_date SET NOT NULL,
    ALTER COLUMN loan_agreement_id SET NOT NULL;

-- CREATE ROLE finance_user LOGIN PASSWORD 'finance_user_password';
-- CREATE ROLE customer_service_user LOGIN PASSWORD 'customer_service_user_password';
-- CREATE ROLE admin_user LOGIN PASSWORD 'admin_user_password';
--
-- -- Grant privileges to roles
-- -- Finance User Role
-- GRANT SELECT ON ALL TABLES IN SCHEMA public TO finance_user;
-- GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO finance_user;
-- GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO finance_user;
--
-- -- Customer Service User Role
-- GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA public TO customer_service_user;
-- GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO customer_service_user;
-- GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO customer_service_user;
--
-- -- Admin User Role
-- GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO admin_user;
-- GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO admin_user;
-- GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO admin_user;
--
-- -- Additional permissions for all roles (optional)
-- GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO finance_user, customer_service_user, admin_user;
--
-- -- Grant specific privileges on specific tables (example)
-- GRANT SELECT, INSERT, UPDATE ON TABLE clients TO finance_user;
-- GRANT SELECT, INSERT, UPDATE ON TABLE bank_accounts TO customer_service_user;
-- GRANT ALL PRIVILEGES ON TABLE fines TO admin_user;


-- \copy clients(client_id, name, type_of_property, edrpou_code, ipn_code, address, phone_number, contact_person, other_details) FROM 'C:\\Users\\Admin\\DataGripProjects\\bank_loans\\data\\clients.txt' WITH CSV HEADER;
-- \copy bank_accounts(account_id, currency, balance, client_id) FROM 'C:\\Users\\Admin\\DataGripProjects\\bank_loans\\data\\bank_accounts.txt' WITH CSV HEADER;
-- \copy types_of_loans(type_of_loan_id,name,interest_rate,payment_term) FROM 'C:\\Users\\Admin\\DataGripProjects\\bank_loans\\data\\types_of_loans.txt' WITH CSV HEADER;
-- \copy loan_agreements(loan_agreement_id,loan_amount,loan_issue_date,loan_repayment_date,account_id,type_of_loan_id) FROM 'C:\\Users\\Admin\\DataGripProjects\\bank_loans\\data\\loan_agreements.txt' WITH CSV HEADER;
-- \copy status_of_loan(status_id,status,description,date_of_change,loan_agreement_id) FROM 'C:\\Users\\Admin\\DataGripProjects\\bank_loans\\data\\status_of_loan.txt' WITH CSV HEADER;
-- \copy payments(payment_id,payment_amount,payment_date,loan_agreement_id) FROM 'C:\\Users\\Admin\\DataGripProjects\\bank_loans\\data\\payments.txt' WITH CSV HEADER;
-- \copy fines(fine_id,fine_amount,fine_reason,fine_date,loan_agreement_id) FROM 'C:\\Users\\Admin\\DataGripProjects\\bank_loans\\data\\fines.txt' WITH CSV HEADER;

SELECT * From clients;
SELECT * FROM bank_accounts;
SELECT *FROM types_of_loans;
SELECT *FROM loan_agreements;
SELECT *FROM status_of_loan;
SELECT *FROM payments;
SELECT *FROM fines;

