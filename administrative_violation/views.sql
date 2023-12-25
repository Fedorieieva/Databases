-- 1 total number of vehicles per owner and owner data
CREATE OR REPLACE VIEW owner_data AS
SELECT CONCAT(name, ' ', last_name) AS full_name,
       phone_number,
       address,
       ipn_code,
       COUNT(v.vin) AS total_vehicles
FROM vehicle_owner
INNER JOIN vehicle v ON vehicle_owner.owner_id = v.owner_id
GROUP BY full_name, phone_number, address, ipn_code;

SELECT * FROM owner_data;


-- 2 driver violation and vehicle data
CREATE OR REPLACE VIEW request_driver_data AS
SELECT CONCAT(name, ' ', last_name) AS full_name,
    vi.drivers_licence,
    phone_number,
    address,
    v.vin,
    v.registration_number,
    v.brand,
    v.model,
    v.manufacture_year,
    vi.violation_type
FROM driver
INNER JOIN vehicle v ON v.vin = driver.vin
INNER JOIN violation vi ON driver.drivers_licence = vi.drivers_licence;

SELECT * FROM request_driver_data;


-- 3 violation act description, driver information and fine for their violation
CREATE OR REPLACE VIEW violation_act_information AS
SELECT va.violation_description,
    CONCAT(d.name, ' ', d.last_name) AS driver_name,
    d.drivers_licence,
    f.fine_amount,
    f.status AS fine_status
FROM violation_act va
INNER JOIN fine f ON f.fine_id = va.fine_id
INNER JOIN violation v ON v.violation_id = va.violation_id
INNER JOIN driver d ON v.drivers_licence = d.drivers_licence;

SELECT * FROM violation_act_information;


-- 4 selecting speeding drivers and their vehicles
CREATE OR REPLACE VIEW speeding_drivers_and_vehicles AS
SELECT CONCAT(d.name, ' ', d.last_name) AS driver_name,
    d.drivers_licence,
    v.vin,
    v.registration_number,
    vio.violation_type
FROM driver d
INNER JOIN vehicle v ON v.vin = d.vin
INNER JOIN violation vio ON vio.drivers_licence = d.drivers_licence
WHERE vio.violation_type = 'Speeding';

SELECT * FROM speeding_drivers_and_vehicles;