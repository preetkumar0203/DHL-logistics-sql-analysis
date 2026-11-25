USE dhl_logistics;

-- RENAME TABLE `dhl_delivery_agents(sheet1)` TO dhl_delivery_agents;
-- RENAME TABLE `dhl_orders(sheet1)` TO dhl_orders;
-- RENAME TABLE `dhl_routes (sheet1)` TO dhl_routes;
-- RENAME TABLE `dhl_shipments (sheet1)` TO dhl_shipments;
-- RENAME TABLE `dhl_warehouses (sheet1)` TO dhl_warehouses;

SELECT * FROM dhl_delivery_agents
WHERE Agent_ID IN (
    SELECT Agent_ID
    FROM dhl_delivery_agents
    GROUP BY Agent_ID
    HAVING COUNT(*) > 1
)
ORDER BY Agent_ID;


SELECT * FROM dhl_orders
WHERE Order_ID IN (
    SELECT Order_ID
    FROM dhl_orders
    GROUP BY Order_ID
    HAVING COUNT(*) > 1
)
ORDER BY Order_ID;

SELECT * FROM dhl_routes
WHERE Route_ID IN (
	SELECT Route_ID
    FROM dhl_routes
    GROUP BY Route_ID
    HAVING COUNT(*) > 1
)
ORDER BY Route_ID;

SELECT * FROM dhl_shipments
WHERE Shipment_ID IN (
	SELECT Shipment_ID
    FROM dhl_shipments
    GROUP BY Shipment_ID
    HAVING COUNT(*) > 1
)
ORDER BY Shipment_ID;

SELECT * FROM
dhl_shipments
WHERE Delay_Hours IS NULL;

SELECT * FROM dhl_shipments
WHERE Delivery_Date < Pickup_Date;

SELECT * FROM dhl_warehouses
WHERE Warehouse_ID IN ( 
	SELECT Warehouse_ID
    FROM dhl_warehouses
    GROUP BY Warehouse_ID
    HAVING COUNT(*) > 1
 )
 ORDER BY Warehouse_ID;
 
 
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


SELECT 
    Route_ID,
    COUNT(Shipment_ID) AS Total_Shipments,
    ROUND(AVG(TIMESTAMPDIFF(HOUR, Pickup_Date, Delivery_Date)), 2) AS Avg_Transit_Time_Hours
FROM dhl_shipments
GROUP BY Route_ID
ORDER BY Avg_Transit_Time_Hours DESC;


SELECT 
    Route_ID,
    COUNT(Shipment_ID) AS Total_Shipments,
    ROUND(AVG(TIMESTAMPDIFF(HOUR, Pickup_Date, Delivery_Date)), 2) AS Avg_Delay_Hours
FROM dhl_shipments
GROUP BY Route_ID
ORDER BY Avg_Delay_Hours DESC;


SELECT 
    r.Route_ID,
    r.Distance_KM,
    ROUND(AVG(TIMESTAMPDIFF(HOUR, s.Pickup_Date, s.Delivery_Date)), 2) AS Avg_Transit_Time_Hours,
    ROUND(r.Distance_KM / AVG(TIMESTAMPDIFF(HOUR, s.Pickup_Date, s.Delivery_Date)), 2) AS Efficiency_Ratio_KM_per_Hour
FROM dhl_routes r
LEFT JOIN dhl_shipments s ON r.Route_ID = s.Route_ID
GROUP BY r.Route_ID, r.Distance_KM
ORDER BY Efficiency_Ratio_KM_per_Hour DESC;


SELECT 
    r.Route_ID,
    r.Distance_KM,
    ROUND(AVG(TIMESTAMPDIFF(HOUR, s.Pickup_Date, s.Delivery_Date)), 2) AS Avg_Transit_Time_Hours,
    ROUND(r.Distance_KM / AVG(TIMESTAMPDIFF(HOUR, s.Pickup_Date, s.Delivery_Date)), 2) AS Efficiency_Ratio_KM_per_Hour
FROM dhl_routes r
LEFT JOIN dhl_shipments s ON r.Route_ID = s.Route_ID
GROUP BY r.Route_ID, r.Distance_KM
ORDER BY Efficiency_Ratio_KM_per_Hour ASC
LIMIT 3;


SELECT 
    Route_ID,
    COUNT(*) AS TotalShipments,
    SUM(CASE WHEN Delivery_Date > Expected_Delivery_Date THEN 1 ELSE 0 END) AS DelayedShipments,
    (SUM(CASE WHEN Delivery_Date > Expected_Delivery_Date THEN 1 ELSE 0 END) / COUNT(*)) * 100 AS DelayPercentage
FROM dhl_shipments
GROUP BY Route_ID
HAVING (SUM(CASE WHEN Delivery_Date > Expected_Delivery_Date THEN 1 ELSE 0 END) / COUNT(*)) > 0.20;


SELECT 
    Route_ID,
    COUNT(*) AS TotalShipments,
    SUM(CASE WHEN Delivery_Date > Expected_Delivery_Date THEN 1 ELSE 0 END) AS DelayedShipments,
    ROUND((SUM(CASE WHEN Delivery_Date > Expected_Delivery_Date THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2) AS DelayPercentage
FROM dhl_shipments
GROUP BY Route_ID
HAVING (SUM(CASE WHEN Delivery_Date > Expected_Delivery_Date THEN 1 ELSE 0 END) / COUNT(*)) > 0.20
ORDER BY DelayPercentage DESC;


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


SELECT 
    route_id,
    agent_id,
    COUNT(*) AS total_deliveries,
    SUM(CASE WHEN Delivery_Date <= Expected_Delivery_Date THEN 1 ELSE 0 END) AS on_time_deliveries,
    ROUND(
        (SUM(CASE WHEN Delivery_Date <= Expected_Delivery_Date THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2
    ) AS on_time_percentage
FROM dhl_shipments
GROUP BY route_id, agent_id
ORDER BY route_id, on_time_percentage DESC;


SELECT a.Agent_ID,Route_ID,
       a.Agent_Name,
       COUNT(*) AS total_deliveries,
       SUM(CASE WHEN s.Delivery_Date <= s.Expected_Delivery_Date THEN 1 ELSE 0 END) AS on_time_deliveries,
       (SUM(CASE WHEN s.Delivery_Date <= s.Expected_Delivery_Date THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) AS on_time_percentage
FROM dhl_shipments as s
JOIN dhl_delivery_agents as a ON s.Agent_ID = a.Agent_ID
GROUP BY a.Agent_ID, a.Agent_Name,Route_ID
HAVING (SUM(CASE WHEN s.Delivery_Date <= s.Expected_Delivery_Date THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) < 85;


SELECT 'Top 5' AS category,
       Avg_Rating,
       Experience_Years
FROM (
    SELECT Avg_Rating, Experience_Years
    FROM dhl_delivery_agents
    ORDER BY Avg_Rating DESC
    LIMIT 5
) AS top_agents

UNION ALL

-- Bottom 5 agents by rating
SELECT 'Bottom 5' AS category,
       Avg_Rating,
       Experience_Years
FROM (
    SELECT Avg_Rating, experience_years
    FROM dhl_delivery_agents
    ORDER BY Avg_Rating ASC
    LIMIT 5
) AS bottom_agents;


SELECT s.shipment_id,
       s.Delivery_Status,
       s.Delivery_Date
FROM dhl_shipments as s
INNER JOIN (
    SELECT shipment_id, MAX(Delivery_Date) AS latest_delivery_date
    FROM dhl_shipments
    GROUP BY shipment_id
) AS latest
ON s.shipment_id = latest.shipment_id
AND s.delivery_date = latest.latest_delivery_date;


SELECT 
    Route_ID,
    COUNT(Shipment_ID) AS Total_Shipments,
    SUM(CASE WHEN Delivery_Status IN ('In Transit', 'Returned') THEN 1 ELSE 0 END) AS Unresolved_Shipments,
    ROUND(
        (SUM(CASE WHEN Delivery_Status IN ('In Transit', 'Returned') THEN 1 ELSE 0 END) / COUNT(Shipment_ID)) * 100, 
        2
    ) AS Unresolved_Percentage
FROM dhl_shipments
GROUP BY Route_ID
HAVING Unresolved_Percentage > 50.00
ORDER BY Unresolved_Percentage DESC;


SELECT delay_reason,
       COUNT(*) AS frequency
FROM dhl_shipments
WHERE delay_reason IS NOT NULL
GROUP BY delay_reason
ORDER BY frequency DESC;


SELECT Order_ID,
       Route_ID,
       Agent_ID,
       Delay_Hours,
       Delivery_Status,
       Delivery_Date,
       Expected_Delivery_Date
FROM dhl_shipments
WHERE delay_hours > 120
ORDER BY delay_hours DESC;


SELECT r.Destination_Country,
      AVG(TIMESTAMPDIFF(HOUR, s.Expected_Delivery_Date, s.Delivery_Date)) AS avg_delivery_delay_hours
FROM dhl_shipments as s 
join dhl_routes as r on s.Route_ID = r.Route_ID
WHERE s.delivery_date IS NOT NULL
GROUP BY r.Destination_Country;


SELECT 
    (SUM(CASE WHEN Delivery_Date <= Expected_Delivery_Date THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) 
    AS on_time_delivery_percentage
FROM dhl_shipments
WHERE Delivery_Date IS NOT NULL;


SELECT Route_ID,
       AVG(TIMESTAMPDIFF(HOUR, Expected_Delivery_Date, Delivery_Date)) AS avg_delay_hours
FROM dhl_shipments 
WHERE Delivery_Date IS NOT NULL
GROUP BY Route_ID
ORDER BY avg_delay_hours DESC;


SELECT w.warehouse_id,
       (COUNT(s.shipment_id) * 100.0 / w.capacity_per_day) AS warehouse_utilization_percentage
FROM dhl_shipments AS s
JOIN dhl_warehouses AS w 
     ON s.warehouse_id = w.warehouse_id
WHERE s.delivery_date IS NOT NULL
GROUP BY w.warehouse_id, w.capacity_per_day
ORDER BY warehouse_utilization_percentage DESC;

















    