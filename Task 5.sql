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



