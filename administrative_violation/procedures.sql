-- 1 returns an average fine amount for a specific violation
CREATE OR REPLACE FUNCTION average_fine_by_violation(IN violation VARCHAR(70))
RETURNS NUMERIC
AS $$
DECLARE
    avg_fine_amount NUMERIC;
BEGIN
    SELECT AVG(f.fine_amount) INTO avg_fine_amount
    FROM fine f
    INNER JOIN violation_act va ON f.fine_id = va.fine_id
    INNER JOIN violation v ON va.violation_id = v.violation_id
    WHERE v.violation_type = violation;
    RETURN avg_fine_amount;
END;
$$ LANGUAGE plpgsql;

SELECT average_fine_by_violation('Speeding');


-- 2 selecting all officers and their total penalty sum
CREATE OR REPLACE FUNCTION officer_total_penalty_sum()
RETURNS TABLE (police_officer_name TEXT, total_fine_sum REAL)
AS $$
BEGIN
    RETURN QUERY
    SELECT CONCAT(p.name, ' ', p.last_name) AS police_officer_name,
           SUM(f.fine_amount) AS total_fine_sum
    FROM police_officer p
    JOIN violation_act va ON p.officer_id = va.officer_id
    JOIN fine f ON va.fine_id = f.fine_id
    GROUP BY police_officer_name
    ORDER BY total_fine_sum DESC;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM officer_total_penalty_sum();


-- 3 getting vehicle information from violation act id
CREATE OR REPLACE FUNCTION get_vehicle_data_by_violation_id(IN v_violation_id INT)
RETURNS TABLE (
    vin VARCHAR(17) ,
    registration_number VARCHAR(10),
    brand VARCHAR(25),
    model VARCHAR(60),
    manufacture_year VARCHAR(4),
    owner_id INT,
    owner_name TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT v.vin,
           v.registration_number,
           v.brand,
           v.model,
           v.manufacture_year,
           v.owner_id,
           CONCAT(o.name, ' ', o.last_name) AS owner_name
    FROM vehicle v
    JOIN driver d ON v.vin = d.vin
    JOIN violation vio ON d.drivers_licence = vio.drivers_licence
    JOIN violation_act va ON vio.violation_id = va.violation_id
    JOIN vehicle_owner o ON v.owner_id = o.owner_id
    WHERE va.violation_act_id = v_violation_id;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM get_vehicle_data_by_violation_id(1);


-- 4 selecting all vehicle makes and count their average violation occurrence
CREATE OR REPLACE FUNCTION avg_violations_by_vehicle_make()
RETURNS TABLE (vehicle_make VARCHAR(25), avg_num_of_violations REAL)
AS $$
BEGIN
    RETURN QUERY
    SELECT v.brand AS vehicle_make,
           AVG(va.violation_act_id)::REAL AS avg_num_of_violations
    FROM violation_act va
    JOIN violation vio ON va.violation_id = vio.violation_id
    JOIN driver d ON vio.drivers_licence = d.drivers_licence
    JOIN vehicle v ON d.vin = v.vin
    WHERE v.brand IS NOT NULL
    GROUP BY v.brand
    ORDER BY avg_num_of_violations DESC;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM avg_violations_by_vehicle_make();


-- 5 selecting violation descriptions and number of violations for the past month
CREATE OR REPLACE FUNCTION violation_count_for_the_last_month()
RETURNS TABLE (violation_type VARCHAR(255), violation_count INT)
AS $$
BEGIN
    RETURN QUERY
    SELECT v.violation_type,
           COUNT(*)::INT AS violation_count
    FROM violation v
    WHERE v.date_time >= NOW() - INTERVAL '1 month'
    GROUP BY v.violation_type
    ORDER BY violation_count DESC;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM violation_count_for_the_last_month();


-- 6 selecting all police officers who did not make any
-- violation acts in the past 3 years
CREATE OR REPLACE FUNCTION officers_with_no_violation_acts_recently()
RETURNS TABLE (police_officer_name TEXT)
AS $$
BEGIN
    RETURN QUERY
    SELECT CONCAT(p.name, ' ', p.last_name) AS police_officer_name
    FROM police_officer p
    LEFT JOIN (
        SELECT DISTINCT va.officer_id
        FROM violation_act va
        WHERE va.date_time >= NOW() - INTERVAL '3 years'
    ) AS recent_violations ON p.officer_id = recent_violations.officer_id
    WHERE recent_violations.officer_id IS NULL;
END;
$$ LANGUAGE plpgsql;

SELECT officers_with_no_violation_acts_recently();


-- 7 select all witnesses that gave testimony to a violation by description
CREATE OR REPLACE FUNCTION get_witnesses_by_violation_description(violation_description_param TEXT)
RETURNS TABLE (witness_name TEXT)
AS $$
BEGIN
    RETURN QUERY
    SELECT CONCAT(w.name, ' ', w.last_name) AS witness_name
    FROM witness w
    JOIN violation_act va ON w.violation_act_id = va.violation_act_id
    JOIN violation v ON va.violation_id = v.violation_id
    WHERE v.violation_type = violation_description_param;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM get_witnesses_by_violation_description('Speeding');


-- 8 selecting vehicles that appeared in a violation in a specified city
CREATE OR REPLACE FUNCTION get_vehicles_by_violation_location(town_param VARCHAR(25))
RETURNS TABLE (vin VARCHAR(17), registration_number VARCHAR(10), brand VARCHAR(25), model VARCHAR(60))
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT v.vin, v.registration_number, v.brand, v.model
    FROM vehicle v
    JOIN driver d ON v.vin = d.vin
    JOIN violation vio ON d.drivers_licence = vio.drivers_licence
    JOIN violation_act va ON vio.violation_id = va.violation_id
    JOIN violation_location vl ON va.location_id = vl.location_id
    WHERE vl.town = town_param;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM get_vehicles_by_violation_location('Denver');


-- 9 getting violations by drivers licence
CREATE OR REPLACE FUNCTION get_violations_by_license(drivers_licence_param VARCHAR(22))
RETURNS TABLE (violation_type VARCHAR(255), date_time TIMESTAMP, status VIOLATION_ACT_STATUS, town VARCHAR(25))
AS $$
BEGIN
    RETURN QUERY
    SELECT v.violation_type, v.date_time, va.status, l.town
    FROM violation v
    JOIN violation_act va ON v.violation_id = va.violation_id
    JOIN violation_location l ON va.location_id = l.location_id
    WHERE v.drivers_licence = drivers_licence_param;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM get_violations_by_license('NU-016804-91-22');


-- 10 get vehicle owners from violation location
CREATE OR REPLACE FUNCTION get_vehicle_owners_by_location(town_param VARCHAR(25))
RETURNS TABLE (owner_name VARCHAR(25), owner_last_name VARCHAR(25))
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT o.name AS owner_name, o.last_name AS owner_last_name
    FROM vehicle_owner o
    JOIN vehicle v ON o.owner_id = v.owner_id
    JOIN driver d ON v.vin = d.vin
    JOIN violation vio ON d.drivers_licence = vio.drivers_licence
    JOIN violation_act va ON vio.violation_id = va.violation_id
    JOIN violation_location vl ON va.location_id = vl.location_id
    WHERE vl.town = town_param;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM get_vehicle_owners_by_location('Las Vegas');

















