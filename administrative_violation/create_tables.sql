CREATE TABLE IF NOT EXISTS Vehicle_Owner(
    owner_id SERIAL PRIMARY KEY NOT NULL,
    name VARCHAR(25) NOT NULL,
    last_name VARCHAR(25) NOT NULL,
    address VARCHAR(255) NOT NULL,
    phone_number VARCHAR(12) NOT NULL,
    ipn_code VARCHAR(10) NOT NULL
);

CREATE TABLE IF NOT EXISTS Vehicle(
    vin VARCHAR(17) PRIMARY KEY NOT NULL,
    registration_number VARCHAR(10) NOT NULL,
    brand VARCHAR(25),
    model VARCHAR(60),
    manufacture_year VARCHAR(4),
    owner_id INT REFERENCES Vehicle_Owner(owner_id) ON DELETE CASCADE NOT NULL
);

CREATE TABLE IF NOT EXISTS Driver(
    drivers_licence VARCHAR(22) PRIMARY KEY NOT NULL,
    name VARCHAR(25) NOT NULL,
    last_name VARCHAR(25) NOT NULL,
    address VARCHAR(255) NOT NULL,
    phone_number VARCHAR(12) NOT NULL,
    vin VARCHAR(17) UNIQUE REFERENCES Vehicle(vin) ON DELETE CASCADE NOT NULL
);

CREATE TABLE IF NOT EXISTS Violation_Category(
    violation_category_id SERIAL PRIMARY KEY NOT NULL,
    name VARCHAR(70) NOT NULL,
    description TEXT
);

-- CREATE TYPE VIOLATION_STATUS AS ENUM ('not registered', 'registered', 'closed');

CREATE TABLE IF NOT EXISTS Violation(
    violation_id SERIAL PRIMARY KEY NOT NULL,
    violation_type VARCHAR(255) NOT NULL,
    date_time TIMESTAMP NOT NULL,
    status VIOLATION_STATUS NOT NULL,
    violation_category_id INT REFERENCES Violation_Category(violation_category_id) ON DELETE CASCADE NOT NULL,
    drivers_licence VARCHAR(22) REFERENCES Driver(drivers_licence) ON DELETE CASCADE NOT NULL
);

CREATE TABLE IF NOT EXISTS Police_Officer(
    officer_id SERIAL PRIMARY KEY NOT NULL,
    name VARCHAR(25) NOT NULL,
    last_name VARCHAR(25) NOT NULL,
    phone_number VARCHAR(12) NOT NULL
);

CREATE TABLE IF NOT EXISTS Violation_Location(
    location_id SERIAL PRIMARY KEY NOT NULL,
    town VARCHAR(25) NOT NULL,
    street VARCHAR(255) NOT NULL,
    building_number VARCHAR(5) NOT NULL
);

-- CREATE TYPE FINE_STATUS AS ENUM ('not payed', 'payed');

CREATE TABLE IF NOT EXISTS Fine(
    fine_id SERIAL PRIMARY KEY NOT NULL,
    fine_amount REAL NOT NULL,
    payment_term DATE NOT NULL,
    status FINE_STATUS NOT NULL
);

-- CREATE TYPE VIOLATION_ACT_STATUS AS ENUM ('active', 'closed');

CREATE TABLE IF NOT EXISTS Violation_Act(
    violation_act_id SERIAL PRIMARY KEY NOT NULL,
    violation_description TEXT NOT NULL,
    date_time TIMESTAMP NOT NULL,
    witness_testimony TEXT NOT NULL,
    status VIOLATION_ACT_STATUS NOT NULL,
    location_id INT REFERENCES Violation_Location(location_id) ON DELETE CASCADE NOT NULL,
    violation_id INT UNIQUE REFERENCES Violation(violation_id) ON DELETE CASCADE NOT NULL,
    officer_id INT REFERENCES Police_Officer(officer_id) ON DELETE CASCADE NOT NULL,
    fine_id INT UNIQUE REFERENCES Fine(fine_id) ON DELETE CASCADE NOT NULL
);

CREATE TABLE IF NOT EXISTS Witness(
    witness_id SERIAL PRIMARY KEY NOT NULL,
    name VARCHAR(25) NOT NULL,
    last_name VARCHAR(25) NOT NULL,
    phone_number VARCHAR(12) NOT NULL,
    violation_act_id INT REFERENCES Violation_Act(violation_act_id) ON DELETE CASCADE NOT NULL
);

