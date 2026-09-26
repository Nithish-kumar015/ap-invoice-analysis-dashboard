USE ap_invoice_analysis;

GO

CREATE TABLE dim_department (
    department_id INT PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL,
    cost_center varchar(50)
);

GO

CREATE TABLE dim_vendor (
    vendor_id INT PRIMARY KEY,
    vendor_name varchar(100) NOT NULL,
    vendor_category VARCHAR(50),
    payment_terms_days INT,
    vendor_region VARCHAR(50),
    vendor_status VARCHAR(20)
);
GO

CREATE Table dim_employee (
    employee_id INT PRIMARY KEY,
    employee_name varchar(100) NOT NULL,
    employee_role VARCHAR(50),
    department_id INT,
    FOREIGN KEY (department_id)
    REFERENCES dim_department(department_id)
);

GO

CREATE TABLE dim_date (
    Date_key INT PRIMARY KEY,
    full_date DATE NOT NULL,
    year INT,
    QUARTER INT,
    MONTH INT,
    month_name VARCHAR(20),
    week_number INT,
    day_of_week INT,
    day_name varchar(20)
);

GO

CREATE TABLE fact_invoice (
    invoice_id INT PRIMARY KEY,
    vendor_id INT NOT NULL,
    employee_id INT NOT NULL,
    department_id INT NOT NULL,
    Invoice_date DATE NOT NULL,
    due_date DATE NOT NULL,
    Invoice_amount DECIMAL(18, 2) NOT NULL,
    currency VARCHAR(10),
    invoice_type VARCHAR(50),
    purchase_order_flag BIT,
    payment_terms_days INT,

    FOREIGN KEY (vendor_id) REFERENCES dim_vendor(vendor_id),
    FOREIGN KEY(employee_id) REFERENCES dim_employee(employee_id),
    FOREIGN KEY (department_id) REFERENCES dim_department(department_id)
);

GO

CREATE TABLE fact_invoice_status (
    STATUS_ID INT primary KEY,
    Invoice_id INT NOT NULL,
    STATUS_date DATE NOT NULL,
    Invoice_status varchar(30) NOT NULL,
    status_reason VARCHAR(100),

    FOREIGN KEY(invoice_id) REFERENCES fact_invoice(invoice_id)
);

GO

CREATE TABLE fact_payment (
    payment_id INT PRIMARY KEY,
    invoice_id INT NOT NULL,
    payment_date date NOT NULL,
    payment_amount DECIMAL(18,2) NOT NULL,
    payment_method VARCHAR(30),
    payment_status VARCHAR(30),

    FOREIGN KEY(invoice_id) REFERENCES fact_invoice(invoice_id)
);

CREATE TABLE fact_exception (
    exception_id INT PRIMARY KEY,
    invoice_id INT NOT NULL,
    exception_date DATE NOT NULL,
    exception_type varchar(50) NOT NULL,
    exception_status varchar(30),
    resolution_date DATE,
    resolution_days INT,

    FOREIGN KEY(invoice_id) REFERENCES fact_invoice(invoice_id)
);
GO


SELECT * FROM dim_date
