-- Task2_PopulateCargoAndShipment.sql
-- Importing Data using BULK INSERT

--USE Shipment;
--GO

--INSERT CUSTOMER TABLE
--BULK INSERT Customer FROM 'c:\TempC\#doNotDELETE\#dev\FUIL50\hw#1\Data\Customer.csv' WITH (FORMAT='CSV', FIRSTROW=2, FIELDTERMINATOR=';', ROWTERMINATOR='\n');
DECLARE @CounterContact INT = 0;
WHILE @CounterContact < 1000
BEGIN
    INSERT INTO Contact (FirstName, LastName, CellPhone)
    SELECT 
        LEFT(CONVERT(NVARCHAR(50), NEWID()), 5),
        LEFT(CONVERT(NVARCHAR(50), NEWID()), 5),
        '+3(' + RIGHT('000' + CAST(ROUND(RAND(CHECKSUM(NEWID())) * 999, 0) AS NVARCHAR(3)), 3) + ')8-' +
        RIGHT('000' + CAST(ROUND(RAND(CHECKSUM(NEWID())) * 999, 0) AS NVARCHAR(3)), 3) + '-' +
        RIGHT('000' + CAST(ROUND(RAND(CHECKSUM(NEWID())) * 999, 0) AS NVARCHAR(3)), 3)
    SET @CounterContact = @CounterContact + 1;
END


--INSERT PLACESTATE and ]STATE] TABLE
--BULK INSERT [Route] FROM 'c:\TempC\#doNotDELETE\#dev\FUIL50\hw#1\Data\PlaceState.csv' WITH (FORMAT='CSV', FIRSTROW=2, FIELDTERMINATOR=';', ROWTERMINATOR='\n');
CREATE TABLE #TempPlaceState (
    [STATE] NVARCHAR(100),
    STATENAME NVARCHAR(255),
    PLACECODE NVARCHAR(100),
    PLACENAME NVARCHAR(255)
);
BULK INSERT #TempPlaceState
FROM 'c:\TempC\#doNotDELETE\#dev\FUIL50\hw#1\Data\PlaceState.csv'
WITH (
    FIELDTERMINATOR = ';',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2
);
INSERT INTO [State] (StateName, SateCode)
SELECT DISTINCT statename, state
FROM #TempPlaceState
WHERE NOT EXISTS (
    SELECT 1
    FROM [State]
    WHERE [State].SateCode = #TempPlaceState.[STATE]
);
INSERT INTO PlaceState (PlaceName, PlaceCode, StateId)
SELECT DISTINCT placename, placecode, 
       (SELECT Id FROM [State] WHERE SateCode = #TempPlaceState.state)
FROM #TempPlaceState
WHERE NOT EXISTS (
    SELECT 1
    FROM PlaceState
    WHERE PlaceState.PlaceCode = #TempPlaceState.placecode
      AND PlaceState.StateId = (SELECT Id FROM [State] WHERE SateCode = #TempPlaceState.[STATE])
);
DROP TABLE #TempPlaceState;


--INSERT WAREHOUSE TABLE
--BULK INSERT Warehouse FROM 'c:\TempC\#doNotDELETE\#dev\FUIL50\hw#1\Data\Warehouses.csv' WITH (FORMAT='CSV', FIRSTROW=2, FIELDTERMINATOR=';', ROWTERMINATOR='\n');
CREATE TABLE #WarehouseStaging (
    Id INT,
    CITY NVARCHAR(100),
    [STATE] NVARCHAR(100)
);
BULK INSERT #WarehouseStaging
FROM 'c:\TempC\#doNotDELETE\#dev\FUIL50\hw#1\Data\Warehouses.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ';',
    ROWTERMINATOR = '\n'
);
INSERT INTO Warehouse (PlaceId)
SELECT PS.Id
FROM #WarehouseStaging WS
JOIN PlaceState PS ON PS.PlaceName LIKE  '%' + WS.City + '%'
JOIN [State] S ON S.StateName LIKE '%' + WS.[State] + '%' AND PS.StateId = S.Id;
DROP TABLE #WarehouseStaging;


--INSERT TRUCK TABLE
BULK INSERT Truck FROM 'c:\TempC\#doNotDELETE\#dev\FUIL50\hw#1\Data\Trucks.csv' WITH (FORMAT='CSV', FIRSTROW=2, FIELDTERMINATOR=';', ROWTERMINATOR='\n');
--INSERT DRIVER TABLE
BULK INSERT Driver FROM 'c:\TempC\#doNotDELETE\#dev\FUIL50\hw#1\Data\Drivers.csv' WITH (FORMAT='CSV', FIRSTROW=2, FIELDTERMINATOR=';', ROWTERMINATOR='\n');


--INSERT DRIVERTRUCK TABLE
--BULK INSERT DriverTruck FROM 'c:\TempC\#doNotDELETE\#dev\FUIL50\hw#1\Data\DriverTruck.csv' WITH (FORMAT='CSV', FIRSTROW=2, FIELDTERMINATOR=';', ROWTERMINATOR='\n');
CREATE TABLE #TempDriverTruck (
    TruckId INT,
    DriverId INT
);
BULK INSERT #TempDriverTruck
FROM 'c:\TempC\#doNotDELETE\#dev\FUIL50\hw#1\Data\DriverTruck.csv'
WITH (
    FIELDTERMINATOR = ';',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2
);
INSERT INTO DriverTruck (TruckId, DriverId)
SELECT TruckId, DriverId
FROM #TempDriverTruck;
DROP TABLE #TempDriverTruck;


--INSERT [ROUTE] TABLE
--BULK INSERT [Route] FROM 'c:\TempC\#doNotDELETE\#dev\FUIL50\hw#1\Data\Routes.csv' WITH (FORMAT='CSV', FIRSTROW=2, FIELDTERMINATOR=';', ROWTERMINATOR='\n');
CREATE TABLE #TempRouteData (
    state1 NVARCHAR(50),
    place1 NVARCHAR(50),
    mi_to_place FLOAT,
    state2 NVARCHAR(50),
    place2 NVARCHAR(50)
);
BULK INSERT #TempRouteData
FROM 'c:\TempC\#doNotDELETE\#dev\FUIL50\hw#1\Data\Routes.csv' 
WITH (
    FIELDTERMINATOR = ';',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2
);
INSERT INTO [Route] (Distance, OriginWarehouseId, DestinationWarehouseId)
SELECT 
    CAST(mi_to_place AS INT),
    OriginWarehouse.Id AS OriginWarehouseId,
    DestinationWarehouse.Id AS DestinationWarehouseId
FROM #TempRouteData AS t
INNER JOIN Warehouse AS OriginWarehouse
    ON OriginWarehouse.PlaceId = (
        SELECT ps.Id
        FROM PlaceState ps
        INNER JOIN [State] s ON ps.StateId = s.Id
        WHERE ps.PlaceCode = t.place1 AND s.SateCode = t.state1
    )
INNER JOIN Warehouse AS DestinationWarehouse
    ON DestinationWarehouse.PlaceId = (
        SELECT ps.Id
        FROM PlaceState ps
        INNER JOIN [State] s ON ps.StateId = s.Id
        WHERE ps.PlaceCode = t.place2 AND s.SateCode = t.state2
    );
DROP TABLE #TempRouteData;
UPDATE [Route]
SET Distance = CAST((100 + (RAND(CHECKSUM(NEWID())) * 2900)) AS INT);


--INSERT CONTACT TABLE
--BULK INSERT Cargo FROM 'c:\TempC\#doNotDELETE\#dev\FUIL50\hw#1\Data\Cargo.csv' WITH (FORMAT='CSV', FIRSTROW=2, FIELDTERMINATOR=';', ROWTERMINATOR='\n');
DECLARE @CounterCargo INT = 0;
IF NOT EXISTS (SELECT 1 FROM Contact)
BEGIN
    PRINT 'Contact table is empty. Please insert data into Contact first.';
    RETURN;
END;
WHILE @CounterCargo < 10000
BEGIN
    INSERT INTO Cargo (Weight, Volume, RouteId, SenderContactId, RecipientContactId)
    SELECT 
        CAST((1 + (RAND(CHECKSUM(NEWID())) * 500)) AS INT),  
        CAST((1 + (RAND(CHECKSUM(NEWID())) * 100)) AS DECIMAL(10, 2)),
        (SELECT TOP 1 Id FROM [Route] ORDER BY NEWID()),  
        (SELECT TOP 1 Id FROM Contact ORDER BY NEWID()), 
        (SELECT TOP 1 Id FROM Contact ORDER BY NEWID());
    SET @CounterCargo = @CounterCargo + 1;
END


--INSERT SHIPMABNT TABLE
--BULK INSERT Shipment FROM 'c:\TempC\#doNotDELETE\#dev\FUIL50\hw#1\Data\Shipment.csv' WITH (FORMAT='CSV', FIRSTROW=2, FIELDTERMINATOR=';', ROWTERMINATOR='\n');
DECLARE @CounterShipment INT = 0;
IF NOT EXISTS (SELECT 1 FROM Cargo)
BEGIN
    PRINT 'Cargo table is empty. Please insert data into Cargo first.';
    RETURN;
END;
IF NOT EXISTS (SELECT 1 FROM Route)
BEGIN
    PRINT 'Route table is empty. Please insert data into Route first.';
    RETURN;
END
WHILE @CounterShipment < 1000
BEGIN
    INSERT INTO Shipment (StartData, CompletionData, RouteId, DriverTruckId, CargoId)
    SELECT 
        DATEADD(DAY, (RAND(CHECKSUM(NEWID())) * (DATEDIFF(DAY, '2023-01-01', GETDATE()))), '2023-01-01'),
        DATEADD(DAY, (RAND(CHECKSUM(NEWID())) * 5), 
        DATEADD(DAY, (RAND(CHECKSUM(NEWID())) * (DATEDIFF(DAY, '2023-01-01', GETDATE()))), '2023-01-01')), 
        (SELECT TOP 1 Id FROM [Route] ORDER BY NEWID()),
        (SELECT TOP 1 Id FROM Truck ORDER BY NEWID()),
        (SELECT TOP 1 Id FROM Cargo ORDER BY NEWID());
    SET @CounterShipment = @CounterShipment + 1;
END




