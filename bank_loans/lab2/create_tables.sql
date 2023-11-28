CREATE TABLE IF NOT EXISTS clients (
	client_id SERIAL PRIMARY KEY,
	name VARCHAR(255),
	type_of_property VARCHAR(255),
	edrpou_code INT,
	ipn_code INT,
	address VARCHAR(255),
	phone_number VARCHAR(12),
	contact_person VARCHAR(255),
	other_details TEXT
);

CREATE TABLE IF NOT EXISTS bank_accounts (
	account_id SERIAL PRIMARY KEY,
	currency VARCHAR(3),
	balance REAL,
	client_id INT REFERENCES clients(client_id)
);

CREATE TABLE IF NOT EXISTS types_of_loans (
	type_of_loan_id SERIAL PRIMARY KEY,
	name VARCHAR(120),
	interest_rate REAL,
	payment_term SMALLINT
);

-- CREATE TYPE loan_status AS ENUM ('active', 'closed', 'overdue');
CREATE TABLE IF NOT EXISTS loan_agreements (
	loan_agreement_id SERIAL PRIMARY KEY,
	loan_amount REAL,
	loan_issue_date DATE,
	loan_repayment_date DATE,
	account_id INT REFERENCES bank_accounts(account_id),
	type_of_loan_id INT REFERENCES types_of_loans(type_of_loan_id)
);

CREATE TABLE IF NOT EXISTS status_of_loan (
	status_id SERIAL PRIMARY KEY,
	status loan_status,
	description TEXT,
	date_of_change DATE,
	loan_agreement_id INT REFERENCES loan_agreements(loan_agreement_id)
);

CREATE TABLE IF NOT EXISTS payments (
	payment_id SERIAL PRIMARY KEY,
	payment_amount REAL,
	payment_date DATE,
	loan_agreement_id INT REFERENCES loan_agreements(loan_agreement_id)
);

CREATE TABLE IF NOT EXISTS fines (
	fine_id SERIAL PRIMARY KEY,
	fine_amount REAL,
	fine_reason TEXT,
	fine_date DATE,
	loan_agreement_id INT REFERENCES loan_agreements(loan_agreement_id)
);
