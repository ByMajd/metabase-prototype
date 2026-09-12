CREATE TABLE sales (
    sale_id INTEGER PRIMARY KEY,
    order_date DATE NOT NULL,
    department VARCHAR(50),
    region VARCHAR(50),
    product VARCHAR(100),
    category VARCHAR(50),
    quantity INTEGER,
    revenue NUMERIC(12,2)
);

COPY sales (
    sale_id,
    order_date,
    department,
    region,
    product,
    category,
    quantity,
    revenue
)
FROM '/data/sales.csv'
DELIMITER ','
CSV HEADER;