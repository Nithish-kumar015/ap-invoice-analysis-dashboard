USE ap_invoice_analysis;
GO

SELECT
    Table_Name
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'Base Table'
ORDER BY TABLE_NAME;

GO

SELECT
    tc.Table_name,
    tc.Constraint_type,
    kcu.Column_name,
    tc.Constraint_Name
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS as tc
JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE as kcu
    ON tc.CONSTRAINT_NAME = kcu.CONSTRAINT_NAME
where tc.TABLE_NAME IN (
    'dim_department',
    'dim_vendor',
    'dim_employee',
    'dim_date',
    'fact_invoice',
    'fact_invoice_status',
    'fact_payment',
    'fact_exception'
)
ORDER BY tc.TABLE_NAME, tc.Constraint_type, kcu.COLUMN_NAME;

GO

(SELECT 'dim_department' as Table_name, count(*) as row_count
FROM dim_department)

UNION ALL

(SELECT 'dim_vendor' as Table_name, count(*) as row_count
FROM dim_vendor)

UNION ALL

(SELECT 'dim_employee' as Table_name, count(*) as row_count
FROM dim_employee)

UNION ALL

(SELECT 'dim_date' as Table_name, count(*) as row_count
FROM dim_date);

SELECT
    Column_name,
    DATA_type,
    Character_Maximum_Length,
    Numeric_precision,
    Numeric_Scale,
    IS_Nullable
From INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'fact_invoice'
ORDER BY ORDINAL_POSITION;
