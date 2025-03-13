--Task3_View.sql

--USE Shipment;
--GO
-- View 1: Using Standard JOINs
CREATE VIEW ShipmentInfo_Join AS
SELECT
    PS1.PlaceName AS OriginCity,
    PS2.PlaceName AS DestinationCity,
    T.Brand AS TruckBrand,
    S.StartData,
    S.CompletionData,
    SUM(C.[Weight]) AS TotalWeight,
    SUM(C.Volume) AS TotalVolume,
    (R.Distance * T.FuelConsumption / 100) AS FuelSpent
FROM Shipment S
JOIN [Route] R ON S.RouteId = R.Id
JOIN Warehouse W1 ON R.OriginWarehouseId = W1.Id
JOIN PlaceState PS1 ON W1.PlaceId = PS1.Id
JOIN Warehouse W2 ON R.DestinationWarehouseId = W2.Id
JOIN PlaceState PS2 ON W2.PlaceId = PS2.Id
JOIN DriverTruck DT ON S.DriverTruckId = DT.Id
JOIN Truck T ON DT.TruckId = T.Id
JOIN Cargo C ON S.CargoId = C.Id
GROUP BY PS1.PlaceName, PS2.PlaceName, T.Brand, S.StartData, S.CompletionData, R.Distance, T.FuelConsumption;

-- View 2: Using CTE
GO

CREATE VIEW ShipmentInfo_Join AS
SELECT
    ws.PlaceName AS OriginCity,
    wd.PlaceName AS DestinationCity,
    t.Brand AS TruckBrand,
    s.StartData AS ShipmentStartTime,
    s.CompletionData AS ShipmentEndTime,
    SUM(c.Weight) AS TotalWeight,
    SUM(c.Volume) AS TotalVolume,
    (r.Distance * t.FuelConsumption / 100) AS FuelSpent
FROM Shipment s
JOIN Cargo c ON s.CargoId = c.Id
JOIN Route r ON s.RouteId = r.Id
JOIN Warehouse wso ON r.OriginWarehouseId = wso.Id
JOIN PlaceState ws ON wso.PlaceId = ws.Id
JOIN Warehouse wdo ON r.DestinationWarehouseId = wdo.Id
JOIN PlaceState wd ON wdo.PlaceId = wd.Id
JOIN DriverTruck dt ON s.DriverTruckId = dt.Id
JOIN Truck t ON dt.TruckId = t.Id
GROUP BY 
    ws.PlaceName, 
    wd.PlaceName, 
    t.Brand, 
    s.StartData, 
    s.CompletionData, 
    r.Distance, 
    t.FuelConsumption;


-- View 3: Using CROSS APPLY
GO

CREATE VIEW ShipmentInfo_Apply AS
SELECT
    PS1.PlaceName AS OriginCity,
    PS2.PlaceName AS DestinationCity,
    T.Brand AS TruckBrand,
    S.StartData,
    S.CompletionData,
    CA.TotalWeight,
    CA.TotalVolume,
    (R.Distance * T.FuelConsumption / 100) AS FuelSpent
FROM Shipment S
JOIN [Route] R ON S.RouteId = R.Id
JOIN Warehouse W1 ON R.OriginWarehouseId = W1.Id
JOIN PlaceState PS1 ON W1.PlaceId = PS1.Id
JOIN Warehouse W2 ON R.DestinationWarehouseId = W2.Id
JOIN PlaceState PS2 ON W2.PlaceId = PS2.Id
JOIN DriverTruck DT ON S.DriverTruckId = DT.Id
JOIN Truck T ON DT.TruckId = T.Id
CROSS APPLY (
    SELECT SUM(C.[Weight]) AS TotalWeight, SUM(C.Volume) AS TotalVolume
    FROM Cargo C
    WHERE C.RouteId = R.Id
) CA;

