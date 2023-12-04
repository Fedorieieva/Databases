-- PROCEDURES
-- 1a
CREATE OR REPLACE PROCEDURE create_temp_table()
AS $$
    BEGIN
        DROP TABLE IF EXISTS temp_table;
        CREATE TEMPORARY TABLE temp_table AS
        SELECT name
        FROM clients
        LIMIT 15;
END;
$$ LANGUAGE plpgsql;

CALL create_temp_table();


-- 1b, e
CREATE OR REPLACE PROCEDURE insert_new_bank_account(
    IN new_currency VARCHAR(3) DEFAULT 'UAH',
	IN new_balance REAL DEFAULT 0.0,
	IN new_client_id INT DEFAULT 1
)
AS $$
    DECLARE
        num_accounts INT;
    BEGIN
        SELECT COUNT(account_id) INTO num_accounts FROM bank_accounts;

        IF num_accounts < 1000 THEN
            INSERT INTO bank_accounts(currency, balance, client_id)
            VALUES (new_currency, new_balance, new_client_id);
        ELSE
            RAISE EXCEPTION 'Cannot add new bank account: maximum number of accounts is reached';
        END IF;
END;
$$ LANGUAGE plpgsql;

CALL insert_new_bank_account('EUR', 5000.0, 2);


-- 1c, f (not a procedure!), 2a
CREATE OR REPLACE FUNCTION count_clients(starting_client_id INT)
RETURNS INT AS $$
DECLARE
    client_count INT := 0;
    current_client_id INT := starting_client_id;
BEGIN
    WHILE EXISTS (SELECT 1 FROM clients WHERE client_id >= current_client_id) LOOP
        client_count := client_count + 1;
        current_client_id := current_client_id + 1;
    END LOOP;

    RETURN client_count;
END;
$$ LANGUAGE plpgsql;

SELECT count_clients(3);


-- 1g
CREATE OR REPLACE PROCEDURE update_client_name(
    IN client_id_number INT,
    IN new_name VARCHAR(255)
)
AS $$
BEGIN
    UPDATE clients SET name = new_name WHERE client_id = client_id_number;
END;
$$ LANGUAGE plpgsql;

CALL update_client_name(1, 'fedorieieva');
SELECT * FROM clients WHERE client_id = 1;


-- 2b
CREATE OR REPLACE FUNCTION get_client_data(client_id_num INT)
RETURNS TABLE (
    client_name VARCHAR(255),
    account_currency VARCHAR(3),
    account_balance REAL,
    loan_amount REAL,
    loan_status loan_status,
    payment_amount REAL,
    fine_amount REAL
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.name AS client_name,
        ba.currency AS account_currency,
        ba.balance AS account_balance,
        la.loan_amount,
        sl.status AS loan_status,
        p.payment_amount,
        f.fine_amount
    FROM
        clients c
    LEFT JOIN
        bank_accounts ba ON c.client_id = ba.client_id
    LEFT JOIN
        loan_agreements la ON ba.account_id = la.account_id
    LEFT JOIN
        status_of_loan sl ON la.loan_agreement_id = sl.loan_agreement_id
    LEFT JOIN
        payments p ON la.loan_agreement_id = p.loan_agreement_id
    LEFT JOIN
        fines f ON la.loan_agreement_id = f.loan_agreement_id
    WHERE
        c.client_id = client_id_num;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM get_client_data(1);


-- -- 3
-- CREATE OR REPLACE FUNCTION cursor_demo()
-- RETURNS VOID AS
-- $$
-- DECLARE
--     finished BOOLEAN DEFAULT FALSE;
--     cur_spec VARCHAR(50);
--
--     client_cursor CURSOR FOR
--         SELECT name AS client_name
--         FROM clients
--         ORDER BY name;
-- BEGIN
--     OPEN client_cursor;
--
--     WHILE NOT finished LOOP
--         FETCH client_cursor INTO cur_spec;
--         IF NOT FOUND THEN
--             finished := TRUE;
--         ELSE
--             RAISE NOTICE 'Client name: %', cur_spec;
--         END IF;
--     END LOOP;
--
--     CLOSE client_cursor;
-- END;
-- $$ LANGUAGE plpgsql;
--
-- SELECT cursor_demo();


-- 4a
CREATE OR REPLACE FUNCTION ClientDeleteTrigger()
RETURNS TRIGGER AS $$
BEGIN
    DELETE FROM clients WHERE
END;
$$ LANGUAGE plpgsql;













