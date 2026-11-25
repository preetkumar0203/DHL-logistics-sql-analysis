SELECT 
    Warehouse_ID,
    ROUND(AVG(TIMESTAMPDIFF(HOUR, Expected_Delivery_Date, Delivery_Date)), 2) AS AvgDelayHours
FROM dhl_shipments
WHERE Delivery_Date > Expected_Delivery_Date
GROUP BY Warehouse_ID
ORDER BY AvgDelayHours DESC
LIMIT 3;


SELECT 
    Warehouse_ID,
    COUNT(*) AS TotalShipments,
    SUM(CASE WHEN Delivery_Date > Expected_Delivery_Date THEN 1 ELSE 0 END) AS DelayedShipments
FROM dhl_shipments
GROUP BY Warehouse_ID
ORDER BY DelayedShipments DESC;


WITH Global_Metrics AS (
    -- CTE 1: Calculate average delay across all shipments network-wide
    SELECT 
        AVG(TIMESTAMPDIFF(HOUR, Pickup_Date, Delivery_Date)) AS Overall_Avg_Delay
    FROM dhl_shipments
),
Warehouse_Metrics AS (
    -- CTE 2: Calculate average delay per warehouse ID
    SELECT 
        Warehouse_ID,
        COUNT(Shipment_ID) AS Total_Dispatched,
        AVG(TIMESTAMPDIFF(HOUR, Pickup_Date, Delivery_Date)) AS Warehouse_Avg_Delay
    FROM dhl_shipments
    GROUP BY Warehouse_ID
)
-- Final Select: Compare facility average against global benchmark
SELECT 
    wm.Warehouse_ID,
    wm.Total_Dispatched,
    ROUND(wm.Warehouse_Avg_Delay, 2) AS Warehouse_Avg_Delay_Hours,
    ROUND(gm.Overall_Avg_Delay, 2) AS Global_Avg_Delay_Hours,
    ROUND(wm.Warehouse_Avg_Delay - gm.Overall_Avg_Delay, 2) AS Hours_Above_Global_Avg
FROM Warehouse_Metrics wm
CROSS JOIN Global_Metrics gm
WHERE wm.Warehouse_Avg_Delay > gm.Overall_Avg_Delay
ORDER BY Hours_Above_Global_Avg DESC;


SELECT 
    Warehouse_ID,
    COUNT(*) AS TotalShipments,
    SUM(CASE WHEN Delivery_Date <= Expected_Delivery_Date THEN 1 ELSE 0 END) AS OnTimeShipments,
    ROUND((SUM(CASE WHEN Delivery_Date <= Expected_Delivery_Date THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2) AS OnTimePercentage
FROM dhl_shipments
GROUP BY Warehouse_ID
ORDER BY OnTimePercentage DESC;

