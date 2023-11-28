ALTER TABLE clients
ADD CONSTRAINT unique_edrpou_code UNIQUE (edrpou_code);

ALTER TABLE loan_agreements
ADD CONSTRAINT positive_loan_amount CHECK (loan_amount > 0);

ALTER TABLE status_of_loan
ADD CONSTRAINT no_future_date CHECK (date_of_change <= CURRENT_DATE);

ALTER TABLE payments
ADD CONSTRAINT positive_payment_amount CHECK (payment_amount > 0);

ALTER TABLE fines
ADD CONSTRAINT positive_fine_amount CHECK (fine_amount > 0);