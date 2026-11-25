SELECT 
 Shipment_ID, Route_ID, Delivery_Date, Pickup_Date,
 TIMESTAMPDIFF (HOUR, Pickup_Date, Delivery_Date) AS Delivery_Delay_Hours
 FROM dhl_Shipments;
 
 SELECT 
    Route_ID,
    ROUND(AVG(TIMESTAMPDIFF(HOUR, Pickup_Date, Delivery_Date)), 2) AS Avg_Delay_Hours
FROM dhl_shipments
GROUP BY Route_ID
ORDER BY Avg_Delay_Hours DESC
LIMIT 10;


SELECT 
    Warehouse_ID,
    Shipment_ID,
    Pickup_Date,
    Delivery_Date,
    TIMESTAMPDIFF(HOUR, Pickup_Date, Delivery_Date) AS Delay_Hours,
    DENSE_RANK() OVER (
        PARTITION BY Warehouse_ID 
        ORDER BY TIMESTAMPDIFF(HOUR, Pickup_Date, Delivery_Date) DESC
    ) AS Delay_Rank
FROM dhl_shipments;


WITH RankedShipments AS (
    SELECT 
        Warehouse_ID,
        Shipment_ID,
        TIMESTAMPDIFF(HOUR, Pickup_Date, Delivery_Date) AS Delay_Hours,
        DENSE_RANK() OVER (
            PARTITION BY Warehouse_ID 
            ORDER BY TIMESTAMPDIFF(HOUR, Pickup_Date, Delivery_Date) DESC
        ) AS Delay_Rank
    FROM dhl_shipments
)
SELECT * 
FROM RankedShipments
WHERE Delay_Rank = 1;


SELECT 
    o.Delivery_Type,
    COUNT(s.Shipment_ID) AS Total_Shipments,
    ROUND(AVG(TIMESTAMPDIFF(HOUR, s.Pickup_Date, s.Delivery_Date)), 2) AS Avg_Delay_Hours
FROM dhl_shipments s
LEFT JOIN dhl_orders o ON s.Order_ID = o.Order_ID
GROUP BY o.Delivery_Type
ORDER BY Avg_Delay_Hours DESC;


