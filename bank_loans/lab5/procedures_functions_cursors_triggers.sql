-- PROCEDURES
-- 1a.	запит для створення тимчасової таблиці через змінну типу TABLE;
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
-- SELECT * FROM temp_table;


-- 1b.	запит з використанням умовної конструкції IF;
-- Отримуємо кількість рахунків в банку
-- Вставляємо новий банківський рахунок, якщо кількість рахунків менше 1000
-- Викидаємо помилку, якщо досягнуто максимальну кількість рахунків
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


-- 1c.	запит з використанням циклу WHILE;
-- Вставляємо нових клієнтів, використовуючи цикл
CREATE OR REPLACE PROCEDURE insert_clients()
AS $$
DECLARE
    counter INT := 1501;
BEGIN
    WHILE counter <= 1506
    LOOP
        INSERT INTO clients (client_id, name, type_of_property, edrpou_code, ipn_code, address, phone_number, contact_person, other_details)
        VALUES (
            counter,
            'Client' || counter,
            'Property Type' || counter,
            counter * 1000,
            counter * 100,
            'Address' || counter,
            '1234567' || counter,
            'Contact Person' || counter,
            'Other Details' || counter
        );
        counter := counter + 1;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

CALL insert_clients();
SELECT * FROM clients
WHERE client_id IN (1501, 1502, 1503, 1504, 1505);


-- 1d.	створення процедури без параметрів;
-- Отримуємо кількість рахунків в банку і виводимо повідомлення
CREATE OR REPLACE PROCEDURE count_bank_accounts()
AS $$
    DECLARE
        num_accounts INT;
    BEGIN
        SELECT COUNT(account_id) INTO num_accounts FROM bank_accounts;
        RAISE NOTICE 'Number of accounts in the bank: %', num_accounts;
    END;
$$ LANGUAGE plpgsql;

CALL count_bank_accounts();


-- 1e.	створення процедури з вхідним параметром;
-- Видаляємо клієнта з таблиці "clients" за його ID
CREATE OR REPLACE PROCEDURE delete_client(client_id_number IN INT)
AS $$
BEGIN
    DELETE FROM clients WHERE client_id = client_id_number;
END;
$$ LANGUAGE plpgsql;

CALL delete_client(1505);
SELECT * FROM clients
WHERE client_id IN (1501, 1502, 1503, 1504, 1505);


-- 1g.	створення процедури оновлення даних в деякій таблиці БД;
-- Оновлюємо ім'я клієнта в таблиці "clients" за його ID
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


-- 1h.	створення процедури, в котрій робиться вибірка даних.
-- Отримуємо дані штрафу за ID
-- Перевіряємо, чи знайдено штраф за заданим ID
-- Виводимо повідомлення з інформацією про штраф
-- Якщо штраф не знайдено виводимо повідомлення
CREATE OR REPLACE PROCEDURE get_fine_data(p_fine_id INT)
LANGUAGE plpgsql
AS $$
DECLARE
    lv_string VARCHAR(255);
    rec1 RECORD;
BEGIN
    SELECT fine_id, fine_amount, fine_date
    INTO rec1
    FROM fines
    WHERE fine_id = p_fine_id;
    IF FOUND THEN
        lv_string := 'Fine ID: ' || rec1.fine_id || ', Fine amount: ' || rec1.fine_amount || ', Fine date: ' || rec1.fine_date;
        RAISE NOTICE '%', lv_string;
    ELSE
        RAISE NOTICE 'No fine found for Fine ID: %', p_fine_id;
    END IF;
END;
$$;

CALL get_fine_data(1);


-- FUNCTIONS
-- 2a.	створити функцію, котра повертає деяке скалярне значення;
-- Підраховуємо кількість клієнтів, починаючи з вказаного ID
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


-- 2b.	створити функцію, котра повертає таблицю з динамічним набором стовпців;
-- Повертаємо результат у вигляді набору записів
CREATE OR REPLACE FUNCTION dynamic_columns(query_text text)
RETURNS SETOF RECORD AS $$
BEGIN
  RETURN QUERY EXECUTE query_text;
END;
$$ LANGUAGE plpgsql STRICT;

SELECT * FROM dynamic_columns('SELECT client_id, name, address FROM clients')
AS t (client_id INT, name VARCHAR(255), address VARCHAR(255));


-- 2c.	створити функцію, котра повертає таблицю заданої структури.
-- Вибираємо дані про типи кредитів та їх кількість
CREATE OR REPLACE FUNCTION select_data()
RETURNS TABLE (loan_type VARCHAR(120), loan_status_count BIGINT) AS $$
BEGIN
    RETURN QUERY
    SELECT name AS loan_type, COUNT(*) AS loan_status_count
    FROM types_of_loans
    GROUP BY loan_type;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM select_data();


-- 2c.	створити функцію, котра повертає таблицю заданої структури.
-- Вибираємо дані про клієнта, його банківський рахунок, кредит та інші відомості
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


-- 3 cursor
-- a.	створити курсор;
-- b.	відкрити курсор;
-- c.	вибірка даних, робота з курсорами.
-- Формуємо рядок з інформацією про штраф і виводимо повідомлення
CREATE OR REPLACE FUNCTION cursor_demo()
RETURNS VOID AS $$
DECLARE
    lv_string VARCHAR(255);
    rec1 RECORD;
    cur1 CURSOR FOR
        SELECT fine_id, fine_amount, fine_date
        FROM fines
        ORDER BY fine_id;
BEGIN
  OPEN cur1;
  LOOP
      FETCH cur1 INTO rec1;
      EXIT WHEN NOT FOUND;
      lv_string := 'Fine ID: ' || rec1.fine_id || ', Fine amount: ' || rec1.fine_amount || ', Fine date: ' || rec1.fine_date;
      RAISE NOTICE '%', lv_string;
  end loop;
END;
$$ LANGUAGE plpgsql STRICT;

SELECT cursor_demo();


-- TRIGGERS
-- 4a.	створити тригер, котрий буде спрацьовувати при видаленні даних;
-- Перевіряємо, чи сума штрафу менше 100
-- Якщо так, то виводимо EXCEPTION
-- Інакше видаляємо рядок з таблиці "fines" за вказаним ID
CREATE OR REPLACE FUNCTION fine_delete_trigger_function()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.fine_amount < 100 THEN
        RAISE EXCEPTION 'Сума штрафу менше 100';
    END IF;
    DELETE FROM fines WHERE fine_id = OLD.fine_id;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER FinesDeleteTrigger
AFTER DELETE ON fines
FOR EACH ROW
EXECUTE FUNCTION fine_delete_trigger_function();

DELETE FROM fines WHERE fine_id = 465;


-- 4b.	створити тригер, котрий буде спрацьовувати при модифікації даних;
-- Перевіряємо, чи номер телефону починається з "+3"
-- Якщо так, то виводимо EXCEPTION
-- Інакше повертаємо модифікований рядок
DROP TRIGGER IF EXISTS ClientPhoneNumberCheck ON clients;
DROP FUNCTION IF EXISTS client_phone_number_check_function();


CREATE OR REPLACE FUNCTION client_phone_number_check_function()
RETURNS TRIGGER AS $$
BEGIN
    IF LEFT(NEW.phone_number, 2) != '+3' THEN
        RAISE EXCEPTION 'Некоректний номер телефону, повинен починатися з "+3"';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER ClientPhoneNumberCheck
AFTER UPDATE ON clients
FOR EACH ROW
EXECUTE FUNCTION client_phone_number_check_function();

UPDATE clients
SET phone_number = '+44583982585'
WHERE client_id = 1;


-- 4c.	створити тригер, котрий буде спрацьовувати при додаванні даних.
-- Перевіряємо, чи сума штрафу менше 0
-- Якщо так, то виводимо EXCEPTION
-- Інакше повертаємо доданий рядок
CREATE OR REPLACE FUNCTION fine_insert_trigger_function()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.fine_amount <= 0 THEN
        RAISE EXCEPTION 'Сума штрафу має бути більше 0';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER FinesInsertTrigger
AFTER INSERT ON fines
FOR EACH ROW
EXECUTE FUNCTION fine_insert_trigger_function();

INSERT INTO fines(fine_id, fine_amount, fine_reason, fine_date, loan_agreement_id)
VALUES (466, -1, 'payment_overdue', '2023-12-07', 1);
