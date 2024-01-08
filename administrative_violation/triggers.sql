-- 1
-- trigger to check if new fine amount is less than the old one
CREATE OR REPLACE FUNCTION fine_update_check_function()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.fine_amount < OLD.fine_amount THEN
        RAISE EXCEPTION 'New fine amount cannot be less, than old fine amount';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER FineAmountCheck
AFTER UPDATE ON fine
FOR EACH ROW
EXECUTE FUNCTION fine_update_check_function();

UPDATE fine
SET fine_amount = 38
WHERE fine_id = 11;


-- 2
-- insert trigger to check fine amount
CREATE OR REPLACE FUNCTION fine_insert_trigger_function()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.fine_amount <= 0 THEN
        RAISE EXCEPTION 'Fine amount cannot be less than 0';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER FinesInsertTrigger
AFTER INSERT ON fine
FOR EACH ROW
EXECUTE FUNCTION fine_insert_trigger_function();

INSERT INTO fine(fine_id, fine_amount, payment_term, status)
VALUES (1501, -1, '2023-12-07', 'not payed');


-- 3
-- trigger to not allow to delete driver with active violation act
CREATE OR REPLACE FUNCTION prevent_delete_if_active_violation()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM Violation_Act va
        JOIN Violation v ON va.violation_id = v.violation_id
        WHERE v.drivers_licence = OLD.drivers_licence AND va.status = 'active'
    ) THEN
        RAISE EXCEPTION 'Cannot delete driver with active violations';
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER CheckToDeleteDriver
BEFORE DELETE ON driver
FOR EACH ROW
EXECUTE FUNCTION prevent_delete_if_active_violation();

DELETE FROM driver WHERE drivers_licence = 'BK-549847-63-37';

select d.drivers_licence,
       va.status,
       va.violation_description
from driver d
JOIN public.violation v on d.drivers_licence = v.drivers_licence
JOIN public.violation_act va on v.violation_id = va.violation_id
where d.drivers_licence = 'BK-549847-63-37';


-- 4
-- trigger that will not allow to update violation act status to closed if fine is not payed
CREATE OR REPLACE FUNCTION check_closed_status()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status = 'closed' AND (
        SELECT status FROM Fine WHERE fine_id = NEW.fine_id
    ) <> 'payed' THEN
        RAISE EXCEPTION 'Cannot set violation_act status ',
            'to closed if fine status is not payed';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER CheckClosedStatusTrigger
BEFORE UPDATE ON Violation_Act
FOR EACH ROW
EXECUTE FUNCTION check_closed_status();

UPDATE violation_act
SET status = 'closed'
WHERE violation_act_id = 11;

select va.violation_act_id,
       va.status,
       f. status AS fine_status
from violation_act va
join public.fine f on va.fine_id = f.fine_id
where violation_act_id = 11;


-- 5
-- trigger to automatically set the violation status to 'not registered' when a violation record is inserted
CREATE OR REPLACE FUNCTION set_default_violation_status()
RETURNS TRIGGER AS $$
BEGIN
    NEW.status = 'not registered';
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER DefaultViolationStatusTrigger
BEFORE INSERT ON violation
FOR EACH ROW
WHEN (NEW.status IS NULL)
EXECUTE FUNCTION set_default_violation_status();

INSERT INTO violation(violation_id, violation_type, date_time, status, violation_category_id, drivers_licence)
VALUES (1501, 'Speeding', '2023-12-07, 11:15:25', NULL, 1, 'BK-549847-63-37');

SELECT *
FROM violation
WHERE violation_id = 1501;


-- 6
-- trigger to automatically set the fine status to 'not payed' when a Fine record is inserted
CREATE OR REPLACE FUNCTION set_default_fine_status()
RETURNS TRIGGER AS $$
BEGIN
    NEW.status = 'not payed';
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER DefaultFineStatusTrigger
BEFORE INSERT ON fine
FOR EACH ROW
WHEN (NEW.status IS NULL)
EXECUTE FUNCTION set_default_fine_status();

INSERT INTO fine(fine_id, fine_amount, payment_term, status)
VALUES (1501, 100, '2023-12-18', NULL);

SELECT *
FROM fine
WHERE fine_id = 1501;

DELETE FROM violation
WHERE violation_id = (SELECT MAX(violation_id) FROM violation);


-- 7
-- trigger to to automatically set the violation status to 'registered' if violation act is inserted
CREATE OR REPLACE FUNCTION update_violation_status()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status = 'active' THEN
        UPDATE violation
        SET status = 'registered'
        WHERE violation_id = NEW.violation_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER ViolationActInsertTrigger
AFTER INSERT
ON violation_act
FOR EACH ROW
EXECUTE FUNCTION update_violation_status();

INSERT INTO violation (violation_id, violation_type, date_time, status, violation_category_id, drivers_licence)
VALUES (1501, 'Speeding', NOW(), 'not registered', 1, 'UU-882641-07-23');

INSERT INTO fine (fine_id, fine_amount, payment_term, status)
VALUES (1501, 100.00, '2024-01-05', 'not payed');

INSERT INTO violation_act (violation_act_id, violation_description, date_time, witness_testimony, status, location_id, violation_id, officer_id, fine_id)
VALUES (1501, 'Excessive Speeding', NOW(), 'I saw the car speeding', 'active', 1, 1501, 1, 1501);

SELECT va.status AS violation_act_status,
       v.status AS violation_status
FROM violation_act va
JOIN public.violation v on v.violation_id = va.violation_id
WHERE va.violation_act_id = 1501;


-- 8
-- trigger to to automatically set the violation and violation_act status to 'closed' if fine is payed
CREATE OR REPLACE FUNCTION update_statuses_on_fine_payment()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status = 'payed' THEN
        UPDATE violation_act
        SET status = 'closed'
        WHERE fine_id = NEW.fine_id;

        UPDATE violation
        SET status = 'closed'
        WHERE violation_id = (SELECT violation_id
                              FROM violation_act
                              WHERE fine_id = NEW.fine_id);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER FineUpdateTrigger
AFTER UPDATE
ON fine
FOR EACH ROW
EXECUTE FUNCTION update_statuses_on_fine_payment();

UPDATE fine
SET status = 'payed'
WHERE fine_id = 1501;

SELECT f.fine_id,
       f.status AS fine_status,
       va.status AS violation_act_status,
       v.status AS violation_status
FROM fine f
JOIN violation_act va ON f.fine_id = va.fine_id
JOIN public.violation v ON va.violation_id = v.violation_id
WHERE f.fine_id = 1501;


-- 9
-- trigger that will ensure that payment term is after violation_act.date_time
CREATE OR REPLACE FUNCTION check_payment_term() RETURNS TRIGGER AS $$
BEGIN
    IF NEW.payment_term <= NOW() + INTERVAL '2 days' THEN
        RAISE EXCEPTION 'Payment term must be at least 2 days later than NOW()';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER EnsurePaymentTermTrigger
BEFORE INSERT OR UPDATE
ON Fine
FOR EACH ROW
EXECUTE FUNCTION check_payment_term();


-- 10
-- trigger that will ensure that violation_act.date_time is after violation.date_time
CREATE OR REPLACE FUNCTION check_violation_act_date_time() RETURNS TRIGGER AS $$
BEGIN
    IF NEW.date_time <= (SELECT date_time FROM violation WHERE violation_id = NEW.violation_id) THEN
        RAISE EXCEPTION 'Violation_Act date_time must be after Violation date_time';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER EnsureViolationActDateTimeTrigger
BEFORE INSERT OR UPDATE
ON violation_act
FOR EACH ROW
EXECUTE FUNCTION check_violation_act_date_time();


INSERT INTO violation (violation_id, violation_type, date_time, status, violation_category_id, drivers_licence)
VALUES (1502, 'Speeding', NOW(), 'not registered', 1, 'UU-882641-07-23');

INSERT INTO fine (fine_id, fine_amount, payment_term, status)
VALUES (1502, 100.00, '2024-01-04', 'not payed');

INSERT INTO violation_act (violation_act_id, violation_description, date_time, witness_testimony, status, location_id, violation_id, officer_id, fine_id)
VALUES (1502, 'Excessive Speeding', '2024-01-05', 'I saw the car speeding', 'active', 1, 1502, 1, 1502);


