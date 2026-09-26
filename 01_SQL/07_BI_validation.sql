SELECT
    v.vendor_name,
    COUNT(p.payment_id) AS paid_late_count
FROM dbo.fact_payment AS p
INNER JOIN fact_invoice AS i
    ON p.invoice_id = i.invoice_id
INNER JOIN dim_vendor AS v
    ON i.vendor_id = v.vendor_id
WHERE LOWER(LTRIM(RTRIM(p.payment_status))) = 'paid late'
GROUP BY v.vendor_name
ORDER BY v.vendor_name;

;WITH VendorLatePaymentCounts AS
(
    SELECT
        dv.vendor_id,
        dv.vendor_name,
        dv.vendor_region,
        COUNT(fp.payment_id) AS late_payment_count
    FROM dbo.fact_payment AS fp
    INNER JOIN dbo.fact_invoice AS fi
        ON fp.invoice_id = fi.invoice_id
    INNER JOIN dbo.dim_vendor AS dv
        ON fi.vendor_id = dv.vendor_id
    WHERE LOWER(LTRIM(RTRIM(fp.payment_status))) = 'paid late'
    GROUP BY
        dv.vendor_id,
        dv.vendor_name,
        dv.vendor_region
),
RankedVendors AS
(
    SELECT
        vendor_id,
        vendor_name,
        vendor_region,
        late_payment_count,
        ROW_NUMBER() OVER
        (
            PARTITION BY vendor_region
            ORDER BY late_payment_count DESC, vendor_id ASC
        ) AS vendor_rank
    FROM VendorLatePaymentCounts
)
SELECT
    vendor_region,
    vendor_rank,
    vendor_name,
    late_payment_count
FROM RankedVendors
WHERE vendor_rank <= 10
ORDER BY vendor_region, vendor_rank;



SELECT DB_NAME() AS current_database;


;WITH InvoiceSLA AS
(
    SELECT
        invoice_id,
        CASE
            WHEN DATEDIFF(
                DAY,
                MIN(CASE WHEN invoice_status = 'Received' THEN status_date END),
                MIN(CASE WHEN invoice_status = 'Ready for payment' THEN status_date END)
            ) <= 5
            THEN 'SLA met'
            ELSE 'SLA breached'
        END AS sla_status
    FROM dbo.fact_invoice_status
    GROUP BY invoice_id
)
SELECT
    sla_status,
    COUNT(*) AS invoice_count,
    CAST(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER ()
        AS DECIMAL(5,2)
    ) AS percentage_of_invoices
FROM InvoiceSLA
GROUP BY sla_status
ORDER BY sla_status;

SELECT
    COUNT(DISTINCT i.invoice_id) AS total_invoices,
    COUNT(DISTINCT e.invoice_id) AS invoices_with_exceptions,
    CAST(
        COUNT(DISTINCT e.invoice_id) * 100.0
        / COUNT(DISTINCT i.invoice_id)
        AS DECIMAL(5,2)
    ) AS exception_rate_pct
FROM dbo.fact_invoice AS i
LEFT JOIN dbo.fact_exception AS e
    ON i.invoice_id = e.invoice_id;



;WITH InvoiceProcessing AS
(
    SELECT
        invoice_id,
        DATEDIFF(
            DAY,
            MIN(CASE WHEN invoice_status = 'Received' THEN status_date END),
            MIN(CASE WHEN invoice_status = 'Ready for payment' THEN status_date END)
        ) AS processing_days
    FROM dbo.fact_invoice_status
    GROUP BY invoice_id
)
SELECT
    COUNT(*) AS invoices_evaluated,
    CAST(
        AVG(CAST(processing_days AS DECIMAL(10,2)))
        AS DECIMAL(10,2)
    ) AS average_processing_days
FROM InvoiceProcessing
WHERE processing_days IS NOT NULL;

SELECT
    COUNT(p.payment_id) AS paid_late_count,
    CAST(
        AVG(
            CAST(
                DATEDIFF(DAY, i.due_date, p.payment_date)
                AS DECIMAL(10,2)
            )
        )
        AS DECIMAL(10,2)
    ) AS average_payment_delay_days
FROM dbo.fact_payment AS p
INNER JOIN dbo.fact_invoice AS i
    ON p.invoice_id = i.invoice_id
WHERE LTRIM(RTRIM(p.payment_status)) = 'Paid Late';



SELECT
    exception_type,
    COUNT(exception_id) AS exception_count,
    CAST(
        AVG(CAST(resolution_days AS DECIMAL(10,2)))
        AS DECIMAL(10,2)
    ) AS average_resolution_days
FROM dbo.fact_exception
GROUP BY exception_type
ORDER BY exception_count DESC;



SELECT
    COUNT(invoice_id) AS total_invoices,
    CAST(SUM(invoice_amount) AS DECIMAL(18,2)) AS total_invoice_value
FROM dbo.fact_invoice;



SELECT
    YEAR(invoice_date) AS invoice_year,
    MONTH(invoice_date) AS invoice_month,
    COUNT(invoice_id) AS invoice_count,
    CAST(SUM(invoice_amount) AS DECIMAL(18,2)) AS invoice_value
FROM dbo.fact_invoice
GROUP BY
    YEAR(invoice_date),
    MONTH(invoice_date)
ORDER BY
    invoice_year,
    invoice_month;



;WITH InvoiceSLA AS
(
    SELECT
        invoice_id,
        CASE
            WHEN DATEDIFF(
                DAY,
                MIN(CASE WHEN invoice_status = 'Received' THEN status_date END),
                MIN(CASE WHEN invoice_status = 'Ready for payment' THEN status_date END)
            ) <= 5
            THEN 0
            ELSE 1
        END AS sla_breach_flag
    FROM dbo.fact_invoice_status
    GROUP BY invoice_id
)
SELECT
    d.department_id,
    d.department_name,
    COUNT(*) AS total_invoices,
    SUM(s.sla_breach_flag) AS sla_breached,
    CAST(
        (COUNT(*) - SUM(s.sla_breach_flag)) * 100.0 / COUNT(*)
        AS DECIMAL(5,2)
    ) AS sla_compliance_pct
FROM InvoiceSLA AS s
INNER JOIN dbo.fact_invoice AS i
    ON s.invoice_id = i.invoice_id
INNER JOIN dbo.dim_department AS d
    ON i.department_id = d.department_id
GROUP BY
    d.department_id,
    d.department_name
ORDER BY
    sla_breached DESC,
    d.department_name;