ALTER TABLE Violation
ADD CONSTRAINT no_future_date CHECK (date_time <= CURRENT_TIMESTAMP);

ALTER TABLE Violation_Act
ADD CONSTRAINT no_future_date CHECK (date_time <= CURRENT_TIMESTAMP);

ALTER TABLE Violation
ADD CONSTRAINT check_status_enum CHECK (status IN ('not registered', 'registered', 'closed'));

ALTER TABLE Violation_Act
ADD CONSTRAINT check_status_enum CHECK (status IN ('active', 'closed'));

ALTER TABLE Fine
ADD CONSTRAINT check_fine_status_enum CHECK (status IN ('not payed', 'payed'));


CREATE ROLE administrator LOGIN PASSWORD 'administrator_user_password';
CREATE ROLE administrative_operator LOGIN PASSWORD 'operator_user_password';
CREATE ROLE officer LOGIN PASSWORD 'officer_user_password';

-- administrator privileges
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO administrator;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO administrator;

-- administrative_operator
GRANT SELECT, INSERT, UPDATE ON TABLE Violation, Violation_Act, Vehicle, Driver TO administrative_operator;

-- officer
GRANT SELECT, INSERT, UPDATE ON TABLE Violation_Act TO officer;


GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO administrative_operator, officer;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO administrator, administrative_operator, officer;

