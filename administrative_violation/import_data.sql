\COPY Vehicle_Owner FROM 'C:\Users\Admin\DataGripProjects\administrative_violation\csv_data\vehicle_owner.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',');

\COPY Vehicle FROM 'C:\Users\Admin\DataGripProjects\administrative_violation\csv_data\vehicle.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',');

\COPY Driver FROM 'C:\Users\Admin\DataGripProjects\administrative_violation\csv_data\driver.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',');

\COPY Violation_Category FROM 'C:\Users\Admin\DataGripProjects\administrative_violation\csv_data\violation_category.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',');

\COPY Violation FROM 'C:\Users\Admin\DataGripProjects\administrative_violation\csv_data\violation.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',');

\COPY Police_Officer FROM 'C:\Users\Admin\DataGripProjects\administrative_violation\csv_data\police_officer.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',');

\COPY Violation_Location FROM 'C:\Users\Admin\DataGripProjects\administrative_violation\csv_data\violation_location.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',');

\COPY Fine FROM 'C:\Users\Admin\DataGripProjects\administrative_violation\csv_data\fine.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',');

\COPY Violation_Act FROM 'C:\Users\Admin\DataGripProjects\administrative_violation\csv_data\violation_act.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',');


