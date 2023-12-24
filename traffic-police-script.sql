DROP TRIGGER IF EXISTS applay_tax_on_fine ON violation;

DROP PROCEDURE IF EXISTS generate_violations(num_rows INT);

DROP SEQUENCE IF EXISTS violation_id;

DROP FUNCTION IF EXISTS generate_violation_fine(num DECIMAL);
DROP FUNCTION IF EXISTS generate_violation_data();
DROP FUNCTION IF EXISTS tax_on_fine();

DROP VIEW IF EXISTS citroen_owners;
DROP VIEW IF EXISTS drivers_with_penalties;
DROP VIEW IF EXISTS up_to_date_dl;

DROP TABLE IF EXISTS Vehicle;
DROP TABLE IF EXISTS Model;
DROP TABLE IF EXISTS Marks;
DROP TABLE IF EXISTS Penalty;
DROP TABLE IF EXISTS Violation;
DROP TABLE IF EXISTS Driver_licence;
DROP TABLE IF EXISTS Driver;

DROP SCHEMA IF EXISTS traffic_police;
REVOKE CONNECT ON DATABASE panina_ea_db FROM manager_traffic_ea;
REVOKE CONNECT ON DATABASE panina_ea_db FROM traffic_police_manager;
REVOKE CONNECT ON DATABASE panina_ea_db FROM admin_traffic_ea;
REVOKE CONNECT ON DATABASE panina_ea_db FROM traffic_police_admin;
DROP ROLE IF EXISTS manager_traffic_ea;
DROP ROLE IF EXISTS admin_traffic_ea;
DROP ROLE IF EXISTS traffic_police_manager;
DROP ROLE IF EXISTS traffic_police_admin;

CREATE SCHEMA IF NOT EXISTS traffic_police AUTHORIZATION panina_ea;
COMMENT ON SCHEMA traffic_police IS '���� ������ ���';

GRANT ALL ON SCHEMA traffic_police TO panina_ea;
ALTER ROLE panina_ea IN DATABASE panina_ea_db SET search_path TO traffic_police, public;
SET search_path TO traffic_police, public;

CREATE TABLE Driver (
	id INT NOT NULL,
	fio TEXT NOT NULL,
	address TEXT NOT NULL,
	phone_number TEXT NOT NULL UNIQUE,
	PRIMARY KEY (id)
);

COMMENT ON TABLE Driver is '������ ������� ������ ���������� � ��������';
COMMENT ON COLUMN Driver.id is '���������� ����������������� ����� ��������';
COMMENT ON COLUMN Driver.fio is '������� ��� �������� ��������';
COMMENT ON COLUMN Driver.address is '����� ���������� ��������';
COMMENT ON COLUMN Driver.phone_number is '����� ��������';

CREATE TABLE Driver_licence (
	id INT NOT NULL,
	fio TEXT NOT NULL,
	birth_date DATE NOT NULL,
	place_of_birth TEXT NOT NULL,
	issue_date DATE NOT NULL,
	expiration_date DATE NOT NULL,
	issuing_authority TEXT NOT NULL, 
	driver_id INT NOT NULL,
	PRIMARY KEY (id)
);

COMMENT ON TABLE Driver_licence is '������ ������� ������ ������ ������������� �������������';
COMMENT ON COLUMN Driver_licence.id is '���������� ����������������� ����� ������������� �������������';
COMMENT ON COLUMN Driver_licence.fio is '������� ��� ��������';
COMMENT ON COLUMN Driver_licence.birth_date is '���� �������� ��������';
COMMENT ON COLUMN Driver_licence.place_of_birth is '����� �������� ��������';
COMMENT ON COLUMN Driver_licence.issue_date is '���� ������ ������������� �������������';
COMMENT ON COLUMN Driver_licence.expiration_date is '���� ��������� ����� �������� ������������� �������������';
COMMENT ON COLUMN Driver_licence.issuing_authority is '������������ ������������� ����������������, ��������� �������������';
COMMENT ON COLUMN Driver_licence.driver_id is '������ �� ��������� ������������� �������������';

CREATE TABLE Vehicle (
	VIN TEXT NOT NULL,
	license_plate_number TEXT NOT NULL UNIQUE,
	model_id INT NOT NULL UNIQUE,
	color TEXT NOT NULL,
	manufacture_year DATE NOT NULL,
	registration_date DATE NOT NULL,
	deregistration_date DATE NOT NULL,
	driver INT NOT NULL,
	PRIMARY KEY (VIN)
);

COMMENT ON TABLE Vehicle is '������� ������� ������ ���������� � ������������ ��������';
COMMENT ON COLUMN Vehicle.VIN is 'VIN';
COMMENT ON COLUMN Vehicle.license_plate_number is '��� - ����� ����������';
COMMENT ON COLUMN Vehicle.model_id is '������ ����������';
COMMENT ON COLUMN Vehicle.color is '����';
COMMENT ON COLUMN Vehicle.manufacture_year is '��� ������� ����������';
COMMENT ON COLUMN Vehicle.registration_date is '���� ����������� � ���';
COMMENT ON COLUMN Vehicle.deregistration_date is '���� ������ � ����������� � ���';
COMMENT ON COLUMN Vehicle.driver is '������ �� ��������� ����������';

CREATE TABLE Violation (
	id INT NOT NULL,
	type TEXT NOT NULL,
	fine DECIMAL NOT NULL CHECK (fine > 0),
	PRIMARY KEY (id)
);

COMMENT ON TABLE Violation is '������ ������� ������ ���������� � ����������';
COMMENT ON COLUMN Violation.id is '��� ���������';
COMMENT ON COLUMN Violation.type is '��� ���������';
COMMENT ON COLUMN Violation.fine is '����� �� ����������� ���������';

CREATE TABLE Penalty (
	id INT NOT NULL,
	violation_id INT NOT NULL,
	date TIMESTAMP NOT NULL,
	driver_license_id INT NOT NULL,
	district TEXT NOT NULL,
	fine DECIMAL NOT NULL CHECK (fine > 0),
	PRIMARY KEY (id)
);

COMMENT ON TABLE Penalty is '������ ������� ������ ���������� � ����������� ���������';
COMMENT ON COLUMN Penalty.id is '��� ���������';
COMMENT ON COLUMN Penalty.violation_id is '������ �� ����������� ���������';
COMMENT ON COLUMN Penalty.date is '���� � ����� ���������';
COMMENT ON COLUMN Penalty.driver_license_id is '����� ������������� ������������� ����������';
COMMENT ON COLUMN Penalty.district is '����� ���������� ���������';
COMMENT ON COLUMN Penalty.fine is '������ ������';

CREATE TABLE Model (
	id INT NOT NULL,
	model_name TEXT NOT NULL,
	mark_id INT NOT NULL,
	PRIMARY KEY (id)
);

COMMENT ON TABLE Model is '������ ������� ������ ���������� � ������� ������������ �������';
COMMENT ON COLUMN Model.id is '���������� ����������������� ����� ������';
COMMENT ON COLUMN Model.model_name is '������������ ������';
COMMENT ON COLUMN Model.mark_id is '������ �� ����� ������';

CREATE TABLE Marks (
	id INT NOT NULL,
	mark_name TEXT NOT NULL,
	PRIMARY KEY (id)
);

COMMENT ON TABLE Marks is '������ ������� ������ ���������� � ������ ������������ �������';
COMMENT ON COLUMN Marks.id is '���������� ������������������ ����� �����';
COMMENT ON COLUMN Marks.mark_name is '������������ �����';

ALTER TABLE Driver_licence 
	ADD CONSTRAINT Driver_licence_fk_driver_id 
	FOREIGN KEY (driver_id) REFERENCES Driver(id)
	ON UPDATE CASCADE
	ON DELETE CASCADE;

ALTER TABLE Vehicle 
	ADD CONSTRAINT Vehicle_fk_model_id 
	FOREIGN KEY (model_id) REFERENCES Model(id)
	ON UPDATE CASCADE
	ON DELETE RESTRICT;

ALTER TABLE Vehicle
	ADD CONSTRAINT Vehicle_fk_driver 
	FOREIGN KEY (driver) REFERENCES Driver(id)
	ON UPDATE CASCADE
	ON DELETE SET NULL;

ALTER TABLE Penalty 
	ADD CONSTRAINT Penalty_fk_violation_id 
	FOREIGN KEY (violation_id) REFERENCES Violation(id)
	ON UPDATE CASCADE
	ON DELETE RESTRICT;

ALTER TABLE Penalty 
	ADD CONSTRAINT Penalty_fk_driver_licence_id 
	FOREIGN KEY (driver_license_id) REFERENCES Driver_licence(id)
	ON UPDATE CASCADE
	ON DELETE RESTRICT;

ALTER TABLE Model 
	ADD CONSTRAINT Model_fk_mark_id 
	FOREIGN KEY (mark_id) REFERENCES Marks(id)
	ON UPDATE CASCADE
	ON DELETE CASCADE;

CREATE OR REPLACE FUNCTION traffic_police.tax_on_fine()
RETURNS trigger AS $$
BEGIN
    UPDATE violation
    SET fine = fine + 200
    WHERE id = NEW.id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER applay_tax_on_fine
AFTER INSERT ON violation
FOR EACH ROW
EXECUTE FUNCTION tax_on_fine();

create sequence if not exists violation_id
as integer
increment by 1
minvalue 1
no maxvalue 
start with 1
cache 1
no cycle;

INSERT INTO Driver VALUES
(1, '��������� ����� ����������', '������, �. ������, ����� ���., �. 20 ��.116' ,'+7 (966) 457-70-80'),
(2, '������ �������� ����������', '������, �. ��������, ��������� ��., �. 20 ��.208', '+7 (946) 384-70-82'),
(3, '���������� ����� ����������', '������, �. �������, ������� ��., �. 4 ��.39', '+7 (959) 640-62-77'),
(4, '�������� ����� ���������', '������, �. �������������, ������ ���., �. 17 ��.180', '+7 (924) 239-79-35'),
(5, '����� ������ �����������', '������, �. ���������, ������������ ��., �. 8 ��.122', '+7 (938) 801-86-28');

INSERT INTO Driver_licence VALUES
(1, '��������� ����� ����������', '1994-12-13', '������, �. ������', '2012-12-12', '2022-12-25', '����� 1179009', 1),
(2, '��������� ����� ����������', '1994-12-13', '������, �. ������', '2022-12-26', '2032-12-26', '����� 1179009', 1),
(3, '������ �������� ����������', '1960-10-21', '������, �. ��������', '1980-02-15', '1990-02-15', '����� 1117110', 2),
(4, '������ �������� ����������', '1960-10-21', '������, �. ��������', '1990-02-16', '2000-02-16', '����� 1117110', 2),
(5, '������ �������� ����������', '1960-10-21', '������, �. ��������', '2000-02-17', '2010-02-17', '����� 1117110', 2),
(6, '������ �������� ����������', '1960-10-21', '������, �. ��������', '2010-02-18', '2020-02-18', '����� 1117110', 2),
(7, '������ �������� ����������', '1960-10-21', '������, �. ��������', '2020-02-19', '2030-02-19', '����� 1117110', 2),
(8, '���������� ����� ����������', '1980-04-07', '������, �. �������', '1990-06-01', '2000-06-01', '����� 1120931', 3),
(9, '���������� ����� ����������', '1980-04-07', '������, �. �������', '2000-06-02', '2010-06-02', '����� 1120931', 3),
(10, '���������� ����� ����������', '1980-04-07', '������, �. �������', '2010-06-03', '2020-06-03', '����� 1120931', 3),
(11, '���������� ����� ����������', '1980-04-07', '������, �. �������', '2020-06-04', '2030-06-03', '����� 1120931', 3),
(12, '�������� ����� ���������', '1974-11-10', '������, �. �������������', '2017-03-08', '2027-03-08', '����� 1162048', 4),
(13, '����� ������ �����������', '1989-02-28', '������, �. ���������', '2013-11-11', '2023-11-11', '����� 1197031', 5);

INSERT INTO Marks VALUES
(1, 'Fiat'),
(2, 'Citroen'),
(3, 'Chevrolet'),
(4, 'Hyundai');

INSERT INTO Model VALUES 
(1, 'Sedici', 1),
(2, 'C8', 2),
(3, 'C3 Pluriel', 2),
(4, 'Epica', 3),
(5, 'Accent', 4);

INSERT INTO Vehicle VALUES
('ZJ2ZX077601548459', '�102��31', 2, '����������-����������', '2010-01-01', '2010-02-14', '2015-10-16', 3),
('ZZ4RK753684879518', '�897��70', 1, '����-����������', '2008-01-01', '2011-08-21', '2022-09-17', 2),
('PW2GV785928208889', '�016��10', 3, '����������-�������', '2009-01-01', '2019-02-16', '2023-11-06', 4),
('TW9EH264781492773', '�245��50', 4, '�����', '2007-01-01', '2016-03-04', '2020-12-15', 5),
('EH0GR082270787581', '�073��31', 5, '����������-����-����������', '2020-01-01', '2020-07-17', '2023-11-06', 1);

INSERT INTO Violation VALUES
(nextval('violation_id'), '���������� ������������ ��������� ���������, �� ������������ ������ ������������', 1000),
(nextval('violation_id'), '���������� ������������ ��������� ���������, ����������� � ��������� ���������', 30000),
(nextval('violation_id'), '���������� ������������� �������� �������� ������������� �������� �� �������� �� 41 �� 60 ��/� ������������', 1500),
(nextval('violation_id'), '������ �� ����������� ������ ��������� ��� �� ����������� ���� �������������', 1000),
(nextval('violation_id'), '���������������� ������������ � �������� ����������� ������������� ��������', 500);

INSERT INTO Penalty VALUES
(1, 2, '2021-08-17 20:38', 2, '��������� �����', 30000),
(2, 4, '2023-11-03 7:41', 7, '��������� �����', 1000),
(3, 3, '2005-12-31 19:33', 9, '��������������� �����', 1500),
(4, 1, '2017-09-16 14:12', 12, '����������� �����', 1000),
(5, 5, '2022-07-15 6:15', 13, '��������� �����', 500);

CREATE OR REPLACE VIEW citroen_owners
 AS
 SELECT d.fio,
    v.license_plate_number,
    v.color,
    mo.model_name,
    ma.mark_name
   FROM vehicle v
     JOIN driver d ON d.id = v.driver
     JOIN model mo ON mo.id = v.model_id
     JOIN marks ma ON ma.id = mo.mark_id
  WHERE ma.mark_name = 'Citroen';

CREATE OR REPLACE VIEW drivers_with_penalties
 AS
 SELECT d.fio,
    p.date,
    p.district,
    v.type,
    v.fine
   FROM penalty p
     JOIN violation v ON p.violation_id = v.id
     JOIN driver_licence dl ON p.driver_license_id = dl.id
     JOIN driver d ON d.id = dl.driver_id;

CREATE OR REPLACE VIEW up_to_date_dl
 AS
 SELECT dl.fio,
    d.phone_number,
    dl.expiration_date,
    dl.issuing_authority
   FROM driver_licence dl
     JOIN driver d ON d.id = dl.driver_id
 WHERE dl.expiration_date >= now();

CREATE OR REPLACE FUNCTION generate_violation_data() RETURNS TEXT AS
$$
BEGIN
    RETURN md5(random()::text);
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION generate_violation_fine(num DECIMAL) RETURNS DECIMAL AS
$$
BEGIN
    RETURN ROUND((RANDOM() * num)::DECIMAL, 2);
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE PROCEDURE generate_violations(num_rows integer) AS 
$$
DECLARE
    i INT;
BEGIN
    FOR i IN 1..num_rows LOOP   
        INSERT INTO violation (id, type, fine)
        VALUES (
			nextval('violation_id'),
            generate_violation_data(),
            generate_violation_fine(10000::DECIMAL)
        );
    END LOOP;
END;
$$ LANGUAGE 'plpgsql';

--role 1
CREATE ROLE traffic_police_manager WITH
NOSUPERUSER
NOCREATEDB
NOCREATEROLE
NOLOGIN
NOREPLICATION
NOBYPASSRLS
CONNECTION LIMIT 5
PASSWORD NULL
VALID UNTIL '2024-12-13';
GRANT SELECT on citroen_owners to traffic_police_manager;
GRANT SELECT on drivers_with_penalties to traffic_police_manager;
GRANT CONNECT ON DATABASE panina_ea_db TO traffic_police_manager;
GRANT USAGE ON SCHEMA traffic_police TO traffic_police_manager;

--user 1
CREATE ROLE manager_traffic_ea WITH
NOSUPERUSER
NOCREATEDB
NOCREATEROLE
LOGIN
NOREPLICATION
NOBYPASSRLS
PASSWORD 'manager'
VALID UNTIL '2024-12-31'
IN ROLE traffic_police_manager;
ALTER ROLE manager_traffic_ea IN DATABASE panina_ea_db
    SET search_path TO traffic_police, public;

--role 2
CREATE ROLE traffic_police_admin WITH
NOSUPERUSER
NOCREATEDB
NOCREATEROLE
NOLOGIN
NOREPLICATION
NOBYPASSRLS
CONNECTION LIMIT 5
PASSWORD NULL
VALID UNTIL '2024-12-31';
GRANT SELECT on driver to traffic_police_admin;
GRANT SELECT on driver_licence to traffic_police_admin;
GRANT SELECT on marks to traffic_police_admin;
GRANT SELECT on model to traffic_police_admin;
GRANT SELECT on penalty to traffic_police_admin;
GRANT SELECT on vehicle to traffic_police_admin;
GRANT SELECT on violation to traffic_police_admin;
GRANT CONNECT ON DATABASE panina_ea_db TO traffic_police_admin;
GRANT USAGE ON SCHEMA traffic_police TO traffic_police_admin;

--user 2
CREATE ROLE admin_traffic_ea WITH
NOSUPERUSER
NOCREATEDB
NOCREATEROLE
LOGIN
NOREPLICATION
NOBYPASSRLS
PASSWORD 'admin'
VALID UNTIL '2024-12-31'
IN ROLE traffic_police_admin;
ALTER ROLE admin_traffic_ea IN DATABASE panina_ea_db
    SET search_path TO traffic_police, public;