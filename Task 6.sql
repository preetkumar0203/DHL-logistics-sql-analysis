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
