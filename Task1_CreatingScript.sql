-- Task1_CreatingScript.sql

--IF EXISTS (SELECT * FROM sys.databases WHERE name = 'Shipment')
--BEGIN
--    DROP DATABASE Shipment;
--END;

--CREATE DATABASE Shipment;
--GO

--USE Shipment;
--GO

SET STATISTICS TIME ON;
SET STATISTICS IO ON;

CREATE TABLE Contact (
    Id INT IDENTITY PRIMARY KEY,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    CellPhone NVARCHAR(20) NOT NULL,
);

CREATE TABLE [State] (
    Id INT IDENTITY PRIMARY KEY,
    StateName NVARCHAR(100) NOT NULL,
    SateCode NVARCHAR(100) NOT NULL,
);

CREATE TABLE PlaceState (
    Id INT IDENTITY PRIMARY KEY,
    PlaceName NVARCHAR(100) NOT NULL,
    PlaceCode NVARCHAR(100) NOT NULL,
    StateId INT NOT NULL,
    CONSTRAINT fk_PlaceState_State FOREIGN KEY (StateId) REFERENCES [State](Id),
);

CREATE TABLE Warehouse (
    Id INT IDENTITY PRIMARY KEY,
	PlaceId INT NOT NULL,
	CONSTRAINT fk_Warehouse_PlaceState FOREIGN KEY (PlaceId) REFERENCES PlaceState(Id),
);

CREATE TABLE Driver (
    Id INT IDENTITY PRIMARY KEY,
    FirstName NVARCHAR(100) NOT NULL,
    LastName NVARCHAR(100) NOT NULL,
	BirthDate DATE NOT NULL
);

CREATE TABLE Truck (
    Id INT IDENTITY PRIMARY KEY,
    Brand NVARCHAR(50) NOT NULL,
    RegistrationNumber NVARCHAR(20) UNIQUE NOT NULL,
	[Year] INT NOT NULL,
    Payload INT NOT NULL,
    FuelConsumption DECIMAL(5,2) NOT NULL,
    VolumeCargo DECIMAL(10,2) NOT NULL,
);

CREATE TABLE DriverTruck (
    Id INT IDENTITY,
    TruckId INT NOT NULL,
    DriverId INT NOT NULL,
    CONSTRAINT pk_DriverTruck PRIMARY KEY (Id),
    CONSTRAINT uq_DriverTruck_Driver_Truck UNIQUE (DriverId, TruckId),
    CONSTRAINT fk_DriverTruck_Truck FOREIGN KEY (TruckId) REFERENCES Truck(Id),
    CONSTRAINT fk_DriverTruck_Driver FOREIGN KEY (DriverId) REFERENCES Driver(Id)
);

CREATE TABLE [Route] (
    Id INT IDENTITY PRIMARY KEY,
    Distance INT NOT NULL,
    OriginWarehouseId INT NOT NULL,
    DestinationWarehouseId INT NOT NULL,
    CONSTRAINT fk_Route_OriginWarehouse FOREIGN KEY (OriginWarehouseId) REFERENCES Warehouse(Id),
    CONSTRAINT fk_Route_DestinationWarehouse FOREIGN KEY (DestinationWarehouseId) REFERENCES Warehouse(Id),
    CONSTRAINT chk_Route_DifferentWarehouses CHECK (OriginWarehouseId <> DestinationWarehouseId)
);

CREATE TABLE Cargo (
    Id INT IDENTITY PRIMARY KEY,
    [Weight] INT NOT NULL,
    Volume DECIMAL(10,2) NOT NULL,
    RouteId INT NOT NULL,
    SenderContactId INT NOT NULL,
    RecipientContactId INT NOT NULL,
    CONSTRAINT fk_Cargo_Contact FOREIGN KEY (SenderContactId) REFERENCES Contact(Id),
    CONSTRAINT fk_Cargo_Recipient FOREIGN KEY (RecipientContactId) REFERENCES Contact(Id),
    CONSTRAINT fk_Cargo_Route FOREIGN KEY (RouteId) REFERENCES [Route](Id),
	CONSTRAINT chk_Cargo_DifferentContact CHECK (SenderContactId <> RecipientContactId)
);

CREATE TABLE Shipment (
    Id INT IDENTITY PRIMARY KEY,
    StartData DATETIME NOT NULL,
    CompletionData DATETIME NOT NULL,
    RouteId INT NOT NULL,
    DriverTruckId INT NOT NULL,
	CargoId INT NOT NULL,
    CONSTRAINT fk_Shipment_Route FOREIGN KEY (RouteId) REFERENCES Route(Id),
    CONSTRAINT fk_Shipment_Truck FOREIGN KEY (DriverTruckId) REFERENCES DriverTruck(Id),
    CONSTRAINT fk_Shipment_Cargo FOREIGN KEY (CargoId) REFERENCES Route(Id),
);







