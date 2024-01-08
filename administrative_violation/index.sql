CREATE INDEX vehicle_owner_idx ON vehicle_owner(name, last_name, address, phone_number, ipn_code);

CREATE INDEX vehicle_idx ON vehicle(vin, registration_number, brand, model, manufacture_year);

CREATE INDEX driver_idx ON driver(name,last_name,address,phone_number);

CREATE INDEX violation_category_idx ON violation_category(name,description);

CREATE INDEX violation_idx ON violation(violation_type,date_time,status);

CREATE INDEX police_officer_idx ON police_officer(name,last_name,phone_number);

CREATE INDEX violation_location_idx ON violation_location(town,street,building_number);

CREATE INDEX fine_idx ON fine(fine_amount,payment_term,status);

CREATE INDEX violation_act_idx ON violation_act(violation_description,date_time,witness_testimony,status);

CREATE INDEX witness_idx ON witness(name,last_name,phone_number);

EXPLAIN ANALYZE SELECT vo.name,
       vo.last_name,
       SUM(f.fine_amount) AS total_fine_amount
FROM vehicle_owner vo
INNER JOIN vehicle ch ON vo.owner_id = ch.owner_id
INNER JOIN driver d ON ch.vin = d.vin
INNER JOIN violation v ON d.drivers_licence = v.drivers_licence
INNER JOIN violation_act va ON v.violation_id = va.violation_id
INNER JOIN fine f ON va.fine_id = f.fine_id
WHERE v.status = 'registered'
GROUP BY vo.owner_id, vo.name, vo.last_name
HAVING COUNT(*) >= 2;