-- Connect to RealEstateDB \c RealEstateDB
-- Enable PostGIS
CREATE EXTENSION IF NOT EXISTS postgis;

--Create an initial PropertyDetails table that intentionally violates normalization principles
CREATE TABLE PropertyDetails (
    PropertyID SERIAL PRIMARY KEY,
    Address VARCHAR(255),
    City VARCHAR(100),
    State VARCHAR(50),
    Country VARCHAR(50),
    ZoningType VARCHAR(100),
    Utility VARCHAR(100),
    GeoLocation GEOMETRY(Point, 4326), -- Spatial data type
    CityPopulation INT
);

---- Query for inserting data into PropertyDetails table:
INSERT INTO PropertyDetails 
(Address, City, State, Country, ZoningType, Utility, GeoLocation, CityPopulation)
VALUES
('950 Main Street', 'Worcester', 'MA', 'USA', 'Commercial', 'Electricity', 
 ST_GeomFromText('POINT(42.2504899 -71.827456)', 4326), 
 103872)
;

INSERT INTO PropertyDetails 
(Address, City, State, Country, ZoningType, Utility, GeoLocation, CityPopulation)
VALUES
('100 Mayfield Street', 'Worcester', 'MA', 'USA', 'Commercial', 'Gas', 
 ST_GeomFromText('POINT(42.2504899 -71.827456)', 4326), 
 103872)
;

INSERT INTO PropertyDetails 
(Address, City, State, Country, ZoningType, Utility, GeoLocation, CityPopulation)
VALUES
('124 Canterbury Street', 'Worcester', 'MA', 'USA', 'Residential', 'Water supply', 
 ST_GeomFromText('POINT(42.2469458 -71.8177652)', 4326), 
 103872)
;

INSERT INTO PropertyDetails 
(Address, City, State, Country, ZoningType, Utility, GeoLocation, CityPopulation)
VALUES
('56 Birch Street', 'Worcester', 'MA', 'USA', 'Residential', 'Internet', 
 ST_GeomFromText('POINT(42.2514315 -71.8287747)', 4326), 
 103872)
;

INSERT INTO PropertyDetails 
(Address, City, State, Country, ZoningType, Utility, GeoLocation, CityPopulation)
VALUES
('69 Downing Street', 'Worcester', 'MA', 'USA', 'Residential', 'Sewage', 
 ST_GeomFromText('POINT(42.2532199 -71.8244847)', 4326), 
 103872)
;


-- Normalizing to 3NF
--Creating CityDemographics Table:
CREATE TABLE CityDemographics (
    City VARCHAR(100) PRIMARY KEY,
    State VARCHAR(50),
    Country VARCHAR(50),
    CityPopulation INT
);

---- Query for inserting data into CityDemographics Table:
SELECT DISTINCT City, State, Country, CityPopulation FROM PropertyDetails; ---Verification Command

INSERT INTO CityDemographics (City, State, Country, CityPopulation) -- Final Inertion Command
SELECT DISTINCT City, State, Country, CityPopulation FROM PropertyDetails;

--Modify PropertyDetails Table:This is to reduce duplicating the data
ALTER TABLE PropertyDetails DROP COLUMN CityPopulation, DROP COLUMN State, DROP COLUMN Country;

--Normalizing to 4NF
--Create PropertyZoning and PropertyUtilities Tables:

-- query for Creating PropertyZoning Table
CREATE TABLE PropertyZoning (
    PropertyZoningID SERIAL PRIMARY KEY,
    PropertyID INT REFERENCES PropertyDetails(PropertyID),
    ZoningType VARCHAR(100)
);

-- -- query for Creating PropertyUtilities Table
CREATE TABLE PropertyUtilities (
    PropertyUtilityID SERIAL PRIMARY KEY,
    PropertyID INT REFERENCES PropertyDetails(PropertyID),
    Utility VARCHAR(100)
);

-- Populate both the PropertyZoning and PropertyUtilities Tables:
---- Query for inserting data into PropertyZoning Table:
SELECT DISTINCT PropertyID, ZoningType FROM PropertyDetails; ---Verification Command


INSERT INTO PropertyZoning (PropertyID, ZoningType) -- Final Inertion Command
SELECT DISTINCT PropertyID, ZoningType FROM PropertyDetails;

DELETE FROM PropertyZoning -- Query to delete table (especially when the table is dublicated)

-- Query for inserting data into PropertyUtilities Table:
SELECT DISTINCT PropertyID, Utility FROM PropertyDetails; ---Verification Command

INSERT INTO PropertyUtilities (PropertyID, Utility) -- Final Inertion Command
SELECT DISTINCT PropertyID, Utility FROM PropertyDetails;

--Remove Columns from PropertyDetails:
ALTER TABLE PropertyDetails DROP COLUMN ZoningType, DROP COLUMN Utility;
--By separating ZoningType and Utility into their tables, we eliminate multi-valued dependencies in PropertyDetails.

--Spatial Data Manipulation
--Inserting and querying spatial data using PostGIS.

--Insert a Property with Geolocation: -- I accidentally inserting existing data into the PropertyDetails table
INSERT INTO PropertyDetails (Address, City, GeoLocation) VALUES 
('950 Main St', 'Worcester', ST_GeomFromText('POINT(42.2504899 -71.827456)', 4326));

DELETE FROM PropertyDetails WHERE PropertyID = 6 -- I used this query to delete the data

--Query Properties within a Radius:
SELECT Address, City
FROM PropertyDetails
WHERE ST_DWithin(
    GeoLocation,
    ST_GeomFromText('POINT(42.2504899 -71.827456)', 4326),
    0.01 -- Spatial Distance 0.01
);


