-- Create the target table if it doesn't already exist
CREATE TABLE IF NOT EXISTS hourTable (
    id INT AUTO_INCREMENT PRIMARY KEY,
    temperature FLOAT(5,2) NOT NULL,
    humidity FLOAT(5,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS bufferTable (
    id INT AUTO_INCREMENT PRIMARY KEY,
    temperature FLOAT(5,2) NOT NULL,
    humidity FLOAT(5,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DELIMITER //

CREATE PROCEDURE InsertHourlyData()
BEGIN
    -- Check if there is data for the last hour
    IF EXISTS (
        SELECT 1
        FROM bufferTable
        WHERE created_at >= NOW() - INTERVAL 1 HOUR
    ) THEN
        -- Perform the insertion
        INSERT INTO hourTable (temperature, humidity, created_at)
        SELECT
            AVG(temperature),
            AVG(humidity),
            NOW()
        FROM bufferTable
        WHERE created_at >= NOW() - INTERVAL 1 HOUR;
    ELSE
        -- Print a message if no data is found
        SELECT 'No data available in bufferTable for the last hour.' AS Message;
    END IF;
END;
//

DELIMITER ;

