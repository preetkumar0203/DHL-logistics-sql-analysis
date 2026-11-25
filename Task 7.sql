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