-- 1 trigger to check if new fine amount is less than the old one
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
WHERE fine_id = 1;


-- 2 insert trigger to check fine amount
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


-- 3 trigger to not allow to delete driver with active violation act
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


-- 4 trigger that will not allow to update violation act status to closed if fine is not payed
CREATE OR REPLACE FUNCTION check_closed_status()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status = 'closed' AND (
        SELECT status FROM Fine WHERE fine_id = NEW.fine_id
    ) <> 'payed' THEN
        RAISE EXCEPTION 'Cannot set violation_act status to closed if fine status is not payed';
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


-- 5
-- trigger to automatically set the violation status to 'not registered' when a violation record is inserted
CREATE OR REPLACE FUNCTION set_default_violation_status()
RETURNS TRIGGER AS $$
BEGIN
    NEW.status := 'not registered';
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
    NEW.status := 'not payed';
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

