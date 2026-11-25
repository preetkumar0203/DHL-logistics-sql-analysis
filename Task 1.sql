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
 