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


GO
-- View 2: Using CTE

CREATE VIEW ShipmentInfo_Cte AS
WITH ShipmentCTE AS (
    SELECT
        s.Id AS ShipmentId,
        s.StartData,
        s.CompletionData,
        c.Weight AS CargoWeight,
        c.Volume AS CargoVolume,
        sc.FirstName AS SenderFirstName,
        sc.LastName AS SenderLastName,
        sc.CellPhone AS SenderPhone,
        rc.FirstName AS RecipientFirstName,
        rc.LastName AS RecipientLastName,
        rc.CellPhone AS RecipientPhone,
        r.Distance AS RouteDistance,
        ow.Id AS OriginWarehouseId,
        dw.Id AS DestinationWarehouseId,
        ps.PlaceName AS OriginPlace,
        ps2.PlaceName AS DestinationPlace,
        st.StateName AS OriginState,
        st2.StateName AS DestinationState,
        d.FirstName AS DriverFirstName,
        d.LastName AS DriverLastName,
        t.Brand AS TruckBrand,
        t.RegistrationNumber,
        t.Year AS TruckYear
    FROM Shipment s
    JOIN Cargo c ON s.CargoId = c.Id
    JOIN Contact sc ON c.SenderContactId = sc.Id
    JOIN Contact rc ON c.RecipientContactId = rc.Id
    JOIN [Route] r ON s.RouteId = r.Id
    JOIN Warehouse ow ON r.OriginWarehouseId = ow.Id
    JOIN Warehouse dw ON r.DestinationWarehouseId = dw.Id
    JOIN PlaceState ps ON ow.PlaceId = ps.Id
    JOIN PlaceState ps2 ON dw.PlaceId = ps2.Id
    JOIN [State] st ON ps.StateId = st.Id
    JOIN [State] st2 ON ps2.StateId = st2.Id
    JOIN DriverTruck dt ON s.DriverTruckId = dt.Id
    JOIN Driver d ON dt.DriverId = d.Id
    JOIN Truck t ON dt.TruckId = t.Id
)
SELECT * FROM ShipmentCTE;


GO
-- View 3: Using CROSS APPLY

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

