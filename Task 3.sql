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