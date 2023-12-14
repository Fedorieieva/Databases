-- 1 selecting all vehicle owners with at least two registered
-- violations and with their fine amount
SELECT vo.name, vo.last_name, SUM(f.fine_amount) AS total_fine_amount
FROM Vehicle_Owner vo
INNER JOIN vehicle ch ON vo.owner_id = ch.owner_id
INNER JOIN Driver d ON ch.vin = d.vin
INNER JOIN Violation v ON d.drivers_licence = v.drivers_licence
INNER JOIN Violation_Act va ON v.violation_id = va.violation_id
INNER JOIN Fine f ON va.fine_id = f.fine_id
WHERE v.status = 'registered'
GROUP BY vo.owner_id, vo.name, vo.last_name
HAVING COUNT(*) >= 2;


-- 2 information about witnesses for a violation act with a
-- specific ID, including the vehicle owner's name
SELECT CONCAT(w.name, ' ', w.last_name) AS witness_name,
       CONCAT(vo.name, ' ', vo.last_name) AS owner_name
FROM Witness w
INNER JOIN Violation_Act va ON w.violation_act_id = va.violation_act_id
INNER JOIN Violation v ON va.violation_id = v.violation_id
INNER JOIN Driver d ON v.drivers_licence = d.drivers_licence
INNER JOIN vehicle vh ON d.vin = vh.vin
INNER JOIN Vehicle_Owner vo ON vh.owner_id = vo.owner_id
WHERE va.violation_act_id = ?;


-- 3 selecting vehicle details with names of their owners
SELECT v.vin,
       v.registration_number,
       v.brand,
       v.model,
       v.manufacture_year,
       CONCAT(vo.name, ' ', vo.last_name) AS owner_name
FROM Vehicle v
JOIN Vehicle_Owner vo ON v.owner_id = vo.owner_id;


-- 4 selecting details of vehicles, their owners,
-- and the corresponding violation information
SELECT v.vin,
       v.registration_number,
       CONCAT(vo.name, ' ', vo.last_name) AS owner_name,
       vio.violation_type,
       vio.date_time
FROM Vehicle v
JOIN Vehicle_Owner vo ON v.owner_id = vo.owner_id
JOIN driver d ON v.vin = d.vin
LEFT JOIN Violation vio ON d.drivers_licence = vio.drivers_licence;


-- 5 selecting drivers who didn't pay their fine
SELECT CONCAT(d.name, ' ', d.last_name) AS driver_name,
    d.drivers_licence,
    f.fine_amount
FROM driver d
INNER JOIN violation v ON d.drivers_licence = v.drivers_licence
INNER JOIN violation_act va ON v.violation_id = va.violation_id
INNER JOIN fine f ON va.fine_id = f.fine_id
WHERE f.status = 'not payed';


-- 6 selecting all closed violation acts with their description and driver name
SELECT CONCAT(d.name, ' ', d.last_name) AS driver_name,
    d.drivers_licence,
    va.violation_description,
    va.status
FROM driver d
INNER JOIN violation v ON d.drivers_licence = v.drivers_licence
INNER JOIN violation_act va ON v.violation_id = va.violation_id
WHERE va.status = 'closed';


-- 7 selecting active violation act id's with witness name
-- and testimony and driver information
SELECT va.violation_act_id,
    CONCAT(w.name, ' ', w.last_name) AS witness_name,
    va.witness_testimony,
    va.status,
    CONCAT(d.name, ' ', d.last_name) AS driver_name,
    d.drivers_licence
FROM violation_act va
INNER JOIN witness w ON va.violation_act_id = w.violation_act_id
INNER JOIN violation v ON v.violation_id = va.violation_id
INNER JOIN driver d ON v.drivers_licence = d.drivers_licence
WHERE va.status = 'active';


-- 8 counting number of violations and average fines
-- for each violation description
SELECT va.violation_description,
    COUNT(*) AS num_violations,
    AVG(f.fine_amount) AS avg_fine_amount
FROM violation_act va
INNER JOIN fine f ON va.fine_id = f.fine_id
GROUP BY violation_description
ORDER BY num_violations DESC;


-- 9 selecting all police officers and their id's to count
-- how many active violations they registered of each type
SELECT p.officer_id,
       CONCAT(p.name, ' ', p.last_name) AS police_officer_name,
       va.violation_description,
       COUNT(*) AS num_violations
FROM police_officer p
INNER JOIN violation_act va ON va.officer_id = p.officer_id
WHERE va.status = 'active'
GROUP BY p.officer_id, va.violation_description
ORDER BY police_officer_name;


-- 10 selecting number of violation categories on each location
SELECT vc.name AS violation_category,
    CONCAT(vl.town, ' ', vl.street, ' ', vl.building_number) AS violation_location,
    COUNT(v.violation_id) AS num_violations
FROM violation_location vl
INNER JOIN violation_act va ON vl.location_id = va.location_id
INNER JOIN violation v ON va.violation_id = v.violation_id
INNER JOIN violation_category vc ON v.violation_category_id = vc.violation_category_id
GROUP BY violation_category, violation_location
ORDER BY violation_location;


-- 11 selecting clients who were supposed to pay the fine
-- within the last year, but didn't
SELECT CONCAT(d.name, ' ', d.last_name) AS driver_name,
       d.drivers_licence,
       f.payment_term
FROM driver d
INNER JOIN violation v ON v.drivers_licence = d.drivers_licence
INNER JOIN violation_act va ON v.violation_id = va.violation_id
INNER JOIN fine f ON f.fine_id = va.fine_id
WHERE f.status = 'not payed'
AND f.payment_term BETWEEN (NOW() - INTERVAL '1 year') AND NOW();


--
-- 12 count how much money is supposed to be payed for each violation description
SELECT va.violation_description,
    SUM(f.fine_amount) AS sum_fine_amount
FROM violation_act va
INNER JOIN fine f ON va.fine_id = f.fine_id
WHERE f.status = 'not payed'
GROUP BY violation_description;


--
-- 13 selecting officers and number of witnesses that gave testimony to them
SELECT p.officer_id,
    CONCAT(p.name, ' ', p.last_name) AS police_officer_name,
    COUNT(DISTINCT w.name) AS num_witness_occurrences
FROM police_officer p
JOIN violation_act va ON p.officer_id = va.officer_id
JOIN witness w ON va.violation_act_id = w.violation_act_id
GROUP BY p.officer_id, police_officer_name
ORDER BY num_witness_occurrences DESC;


--
-- 14 selecting all car brands ad counting how many times they occurred in a violation
SELECT v.brand,
    COUNT(DISTINCT vl.location_id) AS num_locations_seen
FROM Vehicle v
LEFT JOIN Driver d ON v.vin = d.vin
LEFT JOIN Violation viol ON d.drivers_licence = viol.drivers_licence
LEFT JOIN Violation_Act va ON viol.violation_id = va.violation_id
LEFT JOIN Violation_Location vl ON va.location_id = vl.location_id
WHERE v.brand IS NOT NULL
GROUP BY v.brand
ORDER BY num_locations_seen DESC;


--
-- 15 counting total number of violations in each town
SELECT vl.town,
    COUNT(v.violation_id) AS num_violations
FROM violation_location vl
INNER JOIN violation_act va ON vl.location_id = va.location_id
INNER JOIN violation v ON va.violation_id = v.violation_id
GROUP BY town
ORDER BY num_violations DESC;


-- 16 counting number of fines and their sum for each year
SELECT EXTRACT(YEAR FROM va.date_time) AS year,
    COUNT(*) AS num_fines,
    SUM(f.fine_amount) AS total_fine_amount
FROM Violation_Act va
JOIN Fine f ON va.fine_id = f.fine_id
GROUP BY year
ORDER BY year;


-- 17 select drivers and their licence, who drove during curfew
SELECT CONCAT(d.name, ' ', d.last_name) AS driver_name,
       d.drivers_licence
FROM driver d
WHERE d.drivers_licence IN (
    SELECT DISTINCT v.drivers_licence
    FROM violation v
    JOIN violation_act va ON v.violation_id = va.violation_id
    WHERE EXTRACT(HOUR FROM v.date_time) >= 0 AND EXTRACT(HOUR FROM v.date_time) < 5
);


-- 18 selecting drivers and their drivers licence whose violation
-- act is active and fine amount is less than 20
SELECT CONCAT(d.name, ' ', d.last_name) AS driver_name,
       d.drivers_licence
FROM driver d
WHERE d.drivers_licence IN (
    SELECT v.drivers_licence
    FROM violation v,
         violation_Act va,
         fine f
    WHERE va.violation_id = v.violation_id
    AND va.fine_id = f.fine_id
    AND f.fine_amount < 40
    AND va.status = 'active'
);


-- 19 selecting officer id and name with most violation acts for each violation description
SELECT officer_id,
    police_officer_name,
    violation_description,
    num_violation_acts
FROM (
    SELECT p.officer_id,
           CONCAT(p.name, ' ', p.last_name) AS police_officer_name,
           va.violation_description,
           COUNT(va.violation_act_id) AS num_violation_acts,
           ROW_NUMBER() OVER (PARTITION BY va.violation_description ORDER BY COUNT(va.violation_act_id) DESC) AS rank
    FROM Police_Officer p
    INNER JOIN Violation_Act va ON p.officer_id = va.officer_id
    GROUP BY p.officer_id, police_officer_name, va.violation_description
) AS RankedOfficers
WHERE rank = 1
ORDER BY num_violation_acts DESC;


-- 20 selecting drivers and their drivers licence, who had an administrative
-- violation last year, the violation act was closed and had no violations this year
SELECT CONCAT(d.name, ' ', d.last_name) AS driver_name,
       d.drivers_licence
FROM driver d
WHERE d.drivers_licence IN (
    SELECT DISTINCT v.drivers_licence
    FROM violation v
    JOIN violation_act va ON v.violation_id = va.violation_id
    WHERE va.status = 'closed'
    AND v.date_time BETWEEN CURRENT_DATE - INTERVAL '1 year' AND CURRENT_DATE
    AND v.drivers_licence NOT IN (
        SELECT DISTINCT v2.drivers_licence
        FROM violation v2
        WHERE EXTRACT(YEAR FROM v2.date_time) = EXTRACT(YEAR FROM CURRENT_DATE)
    )
);
