USE ap_invoice_analysis;

/*#the analysis i'm going to do on the data i created*/

/*##initial_stage*/

/*stage-1*/

/*1. How many invoices were processed during the analysis period?*/

SELECT COUNT(invoice_id) as total_inovices from fact_invoice

/*2. What is the total value of invoices processed?*/

SELECT SUM(Invoice_amount) as total_invoice_value from fact_invoice;

/*3. How did invoice volume and invoice value change month by month?*/

SELECT
    DATEPART(MONTH, Invoice_date) as invoice_month,
    COUNT(invoice_id) as invoice_volume,
    SUM(Invoice_amount) as invoice_value
FROM fact_invoice
GROUP BY DATEPART(MONTH, Invoice_date)
Order BY invoice_month;

/*4. Which vendors contributed the highest invoice volume and invoice value?*/

SELECT
    COUNT(i.Invoice_id) as invoice_volume,
    SUM(i.invoice_amount) as invoice_value,
    v.vendor_id,
    v.vendor_name
FROM fact_invoice as i
JOIN dim_vendor as v
on i.vendor_id = v.vendor_id
GROUP BY v.vendor_id, v.vendor_name
ORDER BY SUM(i.invoice_amount) DESC;

/*5. Which departments handled the highest invoice volume and invoice value?*/

SELECT
    COUNT(i.invoice_id) as invoice_volume,
    SUM(i.Invoice_amount) as invoice_value,
    d.department_id,
    d.department_name
FROM fact_invoice as i
JOIN dim_department as d
ON i.department_id = d.department_id
GROUP BY d.department_id, d.department_name
ORDER BY SUM(i.invoice_amount) DESC


/*stage- 2 ## Processing Performance*/

/*6. What is the average time required to move an invoice from receipt to Ready for Payment?*/

SELECT
    AVG(processing_days) as average_processing_Days
    FROM(
        Select
            invoice_id,
            DATEDIFF(
                DAY,
                MIN(Case
                        when invoice_status ='Received'
                        Then status_date
                    End),
                    MIN(Case
                            When invoice_status = 'Ready for payment'
                                Then Status_date
                        End)
            )As processing_days
    FROM fact_invoice_status
    GROUP BY Invoice_id
    )AS invoice_processing;

    /*Just want to make sure the result is accurate, will check for it in another way'*/

SELECT distinct
    AVG(DATEDIFF(DAY, r.STATUS_date, p.STATUS_date)) as average_processing_Days
From fact_invoice_status as r
JOIN fact_invoice_status as p
ON r.Invoice_id = p.Invoice_id
Where r.Invoice_status = 'Received' and p.Invoice_status = 'Ready for payment'

/*7. What percentage of invoices fall into different processing-time ranges?*//*
i'll use subquery same as i did in Q6, but i'll bucket the code using CASE for each invoice category and then count per bucket and will write another subquery(scalar) against the fact invoice which can give me the result on percentage*/

SELECT
    processing_bucket,  /*##lets name it as*/ 
    COUNT(*) as invoice_count,
    CAST(COUNT(*) * 100.0/(SELECT COUNT(*) FROM fact_invoice) as decimal(5,2)) as 'PERCENTAGE'
FROM(
    Select
        invoice_id,
        CASE
            WHEN DATEDIFF(
                DAY,
                MIN(CASE WHEN invoice_status = 'Received' THEN status_date END),
                MIN(CASE WHEN Invoice_status = 'Ready for payment' THEN status_date END)
            ) <= 2 THEN '0-2 days'
            WHEN DATEDIFF(
                    DAY,
                    MIN(CASE WHEN invoice_status = 'Received' THEN status_date END),
                    MIN(CASE WHEN Invoice_status = 'Ready for payment' THEN status_date END)
            )<= 5 THEN '3-5 days'
        ELSE '6 or more days'
    END AS processing_bucket
FROM fact_invoice_status
GROUP BY invoice_id) as invoice_processing
GROUP BY processing_bucket
ORDER BY processing_bucket;


/*8. Which invoice lifecycle stage has the longest average processing time?*/
SELECT 
    'Received to Under Review' as stage, 
    AVG(CAST(DATEDIFF(DAY,r.STATUS_date, u.STATUS_date)as decimal(10,2))) as avg_days
From fact_invoice_status as r
JOIN fact_invoice_status as u
ON r.Invoice_id = u.Invoice_id
WHERE r.Invoice_status = 'Received' AND u.Invoice_status = 'Under Review'

UNION ALL

SELECT 
    'Under Review to approved',
    AVG(CAST(DATEDIFF(DAY, u.status_date, a.STATUS_date)as decimal(10,2)))
FROM fact_invoice_status as u
JOIN fact_invoice_status as a
ON u.Invoice_id = a.Invoice_id
WHERE u.Invoice_status = 'Under Review' AND a.Invoice_status = 'Approved'

UNION ALL

SELECT 
    'Approved to posted',
    AVG(CAST(DATEDIFF(DAY, a.STATUS_date, p.STATUS_date)as decimal(10,2)))
from fact_invoice_status as a
JOIN fact_invoice_status as p
ON a.Invoice_id = p.Invoice_id
WHERE a.Invoice_status = 'Approved' and p.Invoice_status = 'Posted'

UNION ALL

SELECT
    'Posted to Ready for payment',
    AVG(CAST(DATEDIFF(DAY, p.status_date, rp.status_date)as decimal(10,2)))
FROM fact_invoice_status as p
JOIN fact_invoice_status as rp
ON p.Invoice_id = rp.Invoice_id
WHERE p.Invoice_status = 'Posted' AND rp.Invoice_status = 'Ready for payment'

ORDER BY avg_days DESC;

/*9. Which employees have the highest assigned invoice workload?*/
/* first let's  check if there is any null values in employeeids*/
/* since there is no nulls in emp ids we can stick to inner join then left join*/
/*Table - 1 = since we need invoice workload the first table will be fact invoice which holds the invoice data*/
/* table - 2 = dim_employees which holds employees table'*/
/*INNER JOIN because this helps drop the invoices from the result like undercounting the total volume*/

/*code/query*/

SELECT
    e.employee_id,
    e.employee_name,
    COUNT(i.invoice_id) as invoice_volume,
    SUM(i.Invoice_amount) as invoice_value
from fact_invoice as i
INNER JOIN dim_employee as e
ON i.employee_id = e.employee_id
GROUP BY e.employee_id, e.employee_name
ORDER BY invoice_volume DESC;

/*10. Which departments have the highest assigned invoice workload?*/
/*Its is the same pattern as Q(9) but here we need to find it for departments instead of employee*/
/*Table - 1 = fact invocie, table - 2 = dim department, inner join'*/

/*Query*/

SELECT
    d.department_id,
    d.department_name,
    COUNT(i.invoice_id) as invoice_volume,
    SUM(i.Invoice_amount) as invoice_value
from fact_invoice as i
INNER JOIN dim_department as d
ON i.department_id = d.department_id
GROUP BY d.department_id, d.department_name
ORDER BY invoice_volume DESC;

/*Stage3*/

/*## SLA Performance*/

/*11. How many invoices met the defined processing SLA and how many breached it?*/
SELECT
    Sla_stat,
    COUNT(*) as invoice_count,
    (Select COUNT(*) FROM fact_invoice) as total_inovices
FROM (
    Select
    invoice_id,
    CASE WHEN DATEDIFF(
                        DAY,
                        MIN(case when Invoice_status = 'Received' then STATUS_date end), 
                        MIN(case when Invoice_status = 'Ready for payment' then STATUS_date end)
                    )<= 5 then 'SLA met'
                else 'SLA breached'
            END as Sla_stat
    from fact_invoice_status
    GROUP BY Invoice_id
) as invocie_SLA
GROUP BY Sla_stat
ORDER BY Sla_stat;
/*(I have add invoice count here in q11 to have clear view of how many out of 1200 were breached and how many are met 
so we got brech 172+ met 1028 = 1200(of total invoice)*/

/*12. What percentage of invoices met the processing SLA?*/
SELECT
    Sla_stat,
    COUNT(*) as invoice_count,
    CAST(COUNT(*)* 100.0/(Select COUNT(*) FROM fact_invoice) as decimal(5,2)) as 'percentage'
FROM(
    Select
        Invoice_id,
        CASE When DATEDIFF(
                            DAY,
                            MIN(case when Invoice_status = 'Received' then STATUS_date end),
                            MIN(Case when Invoice_status = 'Ready for payment' then STATUS_date end)
                        )<= 5 Then 'Sla met'
                    Else 'SLA breached'
                END as Sla_stat
    from fact_invoice_status
    GROUP BY Invoice_id
)AS invocie_SLA
GROUP BY Sla_stat
ORDER BY Sla_stat;

/*13. Which vendors have the highest SLA breach rate?*/
/* here as per the requirment, i'll the join the subquerys which i named as SLA to fact_invoice to get the vendorid and join vendor tabke for the vendor names*/
/* first join sla then will join fact invoice, then vendor table*/
/*Join type i'm going to use is INNER join*/

SELECT
    v.vendor_id,
    v.vendor_name,
    COUNT(*) as total_inovices,
    SUM(Case when s.sla_stat= 'SLA breached' then 1 else 0 end) as breached_count,
    CAST(SUM(CASE when s.sla_stat = 'SLA breached' then 1 else 0 end)* 100.0/COUNT(*) as decimal(5,2)) as breach_percent_rate
FROM /*subquery*/
(
    SELECT
        Invoice_id,
        CASE when DATEDIFF(
            DAY,
            MIN(CASE when Invoice_status = 'Received' then STATUS_date end),
            MIN(Case when Invoice_status = 'Ready for payment' then STATUS_date end)
        ) <= 5 Then 'SLA met'
        ELse 'SLA breached'
    END as Sla_stat
    from fact_invoice_status
    GROUP BY Invoice_id
) AS s
INNER JOIN fact_invoice as i
    ON s.Invoice_id = i.invoice_id
INNER JOIN dim_vendor as v
    ON i.vendor_id = v.vendor_id
GROUP BY v.vendor_id, v.vendor_name
ORDER BY breach_percent_rate DESC;

/*14. Which departments have the highest SLA breach rate?*/
/* this one need analysis on department wise instead of vendor name. so will follow the same steps*/

SELECT
    d.department_id,
    d.department_name,
    COUNT(*) as total_inovices,
    SUM(CASE when s.sla_stat = 'SLA breached' then 1 else 0 end) as breached_count,
    CAST(SUM(Case when s.sla_stat = 'SLA breached' then 1 else 0 end) * 100.0/COUNT(*) as decimal(5,2)) as breach_percent_rate
FROM(
    Select
        invoice_id,
        CASE
            When DATEDIFF(
                DAY,
                MIN(Case when Invoice_status ='Received' then STATUS_date end),
                MIN(Case when Invoice_status = 'Ready for payment' then STATUS_date end)
            )<= 5 then 'SLA Met'
            Else 'SLA breached'
        END as sla_stat
    from fact_invoice_status
    GROUP BY Invoice_id
) as s
INNER JOIN fact_invoice as i
    ON s.Invoice_id = i.invoice_id
INNER JOIN dim_department as d
    ON i.department_id = d.department_id
GROUP BY d.department_id, d.department_name
ORDER BY breach_percent_rate DESC;

/*15. Which months have the highest SLA breach rate?*/
/* here wil use the same patter SLA-subquery-join with fact invoice table then will use date part in grouped to calculte the month*/

SELECT
    DATEPART(MONTH, i.invoice_date) AS invoice_month,
    COUNT(*) as total_inovices,
    SUM(CASE WHEN sla_stat = 'SLA breached' then 1 ELSE 0 END) as breached_count,
    CAST(SUM(CASE WHEN sla_stat = 'SLA breached' then 1 ELSE 0 END) * 100.0/COUNT(*) as DECIMAL(5,2)) as breach_percent_rate
FROM(
    SELECT
        invoice_id,
        CASE when DATEDIFF(
                DAY,
                MIN(CASE when Invoice_status ='Received' then STATUS_date end),
                MIN(CASE when Invoice_status = 'Ready for payment' then status_date end)
            )<= 5 then 'SLA met'
            Else 'SLA breached'
        END as sla_stat
    from fact_invoice_status
    GROUP BY Invoice_id
) as s
INNER JOIN fact_invoice as i
    ON s.Invoice_id = i.invoice_id
GROUP BY DATEPART(MONTH, i.Invoice_date)
ORDER BY breach_percent_rate;

/*16. Which invoice characteristics are associated with SLA breaches?*/
/* will follow the same pattern but will group the data by invoice char instead of any dimension table name*/

SELECT
    i.invoice_type, /* we have in invoice table*/
    i.purchase_order_flag,
    COUNT(*) as total_inovices,
    SUM(CASE when s.Sla_stat = 'SLA breached' then 1 else 0 end) as breached_count,
    CAST(SUM(case when s.Sla_stat = 'SLA breached' then 1 else 0 end) * 100.0/COUNT(*) AS DECIMAL(5,2)) as breach_percent_rate
FROM(
    select
        invoice_id,
        Case when DATEDIFF(
            DAY,
            MIN(CASE when Invoice_status = 'Received' then STATUS_date end),
            MIN(Case when Invoice_status = 'Ready for payment' then STATUS_date end)
        )<= 5 then 'SLA met'
        Else 'SLA breached'
        ENd as Sla_stat
    FROM fact_invoice_status
    GROUP BY Invoice_id
)as s
INNER JOIN fact_invoice as i
    ON s.Invoice_id = i.invoice_id
GROUP BY i.invoice_type, i.purchase_order_flag
ORDER BY breach_percent_rate;


/*## Exception Analysis*/

/*17. What percentage of invoices have exceptions?*/

SELECT
    Count(DISTINCT(i.invoice_id)) as total_inovices,
    COUNT(DISTINCT(e.invoice_id)) as invoce_with_exceptions, /*(since we need percentage)*/
    CAST(COUNT(Distinct e.invoice_id)* 100.0/ COUNT(DISTINCT i.invoice_id) as decimal(5,2)) as exception_percent_rate
FROM fact_invoice as i
LEFT JOIN fact_exception as e
    ON i.invoice_id = e.invoice_id;

/*18. Which exception types occur most frequently?*/

SELECT
    exception_type,
    COUNT(*) as exception_count,
    CAST(COUNT(*) * 100.0/sum(COUNT(*)) over() as decimal(5,2)) as percent_of_exception
from fact_exception
GROUP BY exception_type
ORDER BY exception_count DESC;

/*19. Which vendors have the highest exception rate?*/
/* since we need vendor name with highest exception  rate, we need 3 tables (vendor,invoice, exception)*/
/*table 1 - vendor cause every vendor names is in this table*/
/*table 2- invoice because every invoice that related to a vendor is saved in this table*/
/*table 3 - exception*/ 
/*JOIN 1 - inner join*/
/*Join 2- Left join*/

SELECT
    v.vendor_name,
    COUNT(DISTINCT i.invoice_id) as total_inovices,
    COUNT(Distinct e.invoice_id) as invoice_with_exception,
    CAST(COUNT(Distinct e.invoice_id) * 100.0/ COUNT(DISTINCT i.invoice_id) as decimal(5,2)) as exception_percent_rate
FROM dim_vendor as v
INNER JOIN fact_invoice as i
    ON v.vendor_id = i.vendor_id
LEFT JOIN fact_exception as e
    ON i.invoice_id = e.invoice_id
GROUP BY v.vendor_name
ORDER BY exception_percent_rate DESC;

/*20. What is the average exception resolution time?*/

SELECT
    exception_type,
    COUNT(*) as Exception_count,
    CAST(AVG(cast(resolution_days as decimal(5,2))) as decimal(5,2)) as AVG_resolution_days
from fact_exception
GROUP BY exception_type
ORDER BY AVG_resolution_days DESC;

/*21. Which exception types take the longest to resolve?*/
SELECT
    exception_type,
    COUNT(*) as total_exception_count,
    CAST(AVG(cast(resolution_days as decimal(5,2))) as decimal(5,2)) as AVG_resolution_days,
    MAX(resolution_days) as max_resolution_days
FROM fact_exception
GROUP BY exception_type
ORDER BY max_resolution_days DESC;

/*22. Do invoices with exceptions have different processing times from invoices without exceptions?*/

WITH invoice_processing AS
(
    SELECT
        invoice_id,
        DATEDIFF(
            DAY,
            MIN(CASE WHEN invoice_status = 'Received' THEN status_date END),
            MIN(CASE WHEN invoice_status = 'Ready for payment' THEN status_date END)
        ) AS processing_days
    FROM fact_invoice_status
    GROUP BY invoice_id
),
Flagged_invoices AS
(
    SELECT
        p.invoice_id,
        p.processing_days,
        CASE
            WHEN EXISTS
            (
                SELECT 1
                FROM fact_exception AS e
                WHERE e.invoice_id = p.invoice_id
            ) THEN 'Has exception'
            ELSE 'No exception'
        END AS exception_flag
    FROM invoice_processing AS p
)
SELECT
    exception_flag,
    COUNT(*) AS total_invoice_count,
    CAST(AVG(CAST(processing_days AS decimal(5,2))) AS decimal(5,2)) AS average_processing_days
FROM Flagged_invoices
GROUP BY exception_flag;
/*## Payment Performance*/

USE ap_invoice_analysis
/*23. What is the average time between invoice approval and payment?*/

WITH invoice_approval AS (
    SELECT
        Invoice_id,
        MIN(Case when Invoice_status = 'Approved' then STATUS_date end) as approved_date
    FROM fact_invoice_status
    GROUP BY Invoice_id
)
SELECT
    COUNT(*) as total_inovices,
    CAST(AVG(CAST(DATEDIFF(DAY, a.approved_date, p.payment_date) as decimal(5,2))) as decimal(5,2)) as avg_days_to_approve_paymet
FROM invoice_approval as a
INNER JOIN fact_payment as p
ON a.Invoice_id = p.invoice_id;

/*since the approval date is too high will check the result once again in another way*/

SELECT
    a.invoice_id,
    a.approved_date,
    payment_date,
    DATEDIFF(DAY, a.approved_date, p.payment_date) as days_gap
FROM(
    Select
        Invoice_id,
        MIN(Case when Invoice_status= 'Approved' then status_date end) as approved_date
    FROM fact_invoice_status
    GROUP BY Invoice_id
) as a
INNER JOIN fact_payment p
    ON a.Invoice_id = p.invoice_id
ORDER BY days_gap DESC;

/*35.93 is the average time between invoice approval and payment*/

/*24. How many invoices were paid on time versus late?*/

SELECT
    payment_status,
    COUNT(*) as invoice_count
from fact_payment
GROUP BY payment_status

/*25. What percentage of invoices were paid late?*/

Select
    payment_status,
    COUNT(*) as invoice_count,
    CAST(COUNT(*)* 100.0/ SUM(COUNT(*)) OVER() as decimal (5,2)) as percanetage_of_invoices_paidLate
from fact_payment
GROUP BY payment_status;
/*26. Which invoices were paid after their due date, and by how many days?*/

Select
    i.invoice_id,
    i.due_date,
    p.payment_date,
    DATEDIFF(DAY, i.due_date,  p.payment_date) as days_late
from fact_invoice as i
INNER JOIN fact_payment as p
ON i.invoice_id = p.invoice_id
WHERE p.payment_date > i.due_date
ORDER BY days_late DESC;

/*27. Which vendors have the highest payment-delay rate and average payment delay?*/

SELECT
    vendor_name,
    COUNT(*) as total_inovices,
    SUM(CASE when p.payment_date> i.due_date then 1 else 0 END) as late_invoice_count,
    CAST(SUM(Case when p.payment_date > i.due_date then 1 else 0 end) * 100.0/ count(*) as decimal(5,2)) as delay_rate_percent,
    CAST(AVG(Case when p.payment_date > i.due_date then CAST(DATEDIFF(DAY, i.due_date,payment_date) as DECIMAL(5,2)) END) as DECIMAL(5,2)) as avg_days_late
from dim_vendor as v
INNER JOIN fact_invoice as i
    ON v.vendor_id = i.vendor_id
INNER JOIN fact_payment as p
    ON i.invoice_id = p.invoice_id
GROUP BY vendor_name
ORDER BY delay_rate_percent DESC;

/*28. Does having an exception correspond with higher payment delays?*/

WITH invoice_delayed AS
(
    SELECT
        i.invoice_id,
        MAX(CASE WHEN p.payment_date > i.due_date THEN 1 ELSE 0 END) AS is_late,
        MAX
        (
            CASE
                WHEN p.payment_date > i.due_date
                THEN DATEDIFF(DAY, i.due_date, p.payment_date)
            END
        ) AS days_late
    FROM fact_invoice AS i
    INNER JOIN fact_payment AS p
        ON i.invoice_id = p.invoice_id
    GROUP BY i.invoice_id
)
SELECT
    CASE WHEN e.invoice_id IS NULL THEN 'No Exception' ELSE 'Has exception' END AS exception_flag,
    COUNT(*) AS total_invoices,
    SUM(d.is_late) AS late_invoice_count,
    CAST(SUM(d.is_late) * 100.0 / COUNT(*) AS decimal(5,2)) AS delay_rate_percent,
    CAST(AVG(CAST(d.days_late AS decimal(5,2))) AS decimal(5,2)) AS avg_days_late
FROM invoice_delayed AS d
LEFT JOIN
(
    SELECT DISTINCT invoice_id
    FROM fact_exception
) AS e
    ON d.invoice_id = e.invoice_id
GROUP BY CASE WHEN e.invoice_id IS NULL THEN 'No Exception' ELSE 'Has exception' END;
/*## Root Cause & Management Analysis*/

/*29. Where are the largest bottlenecks in the invoice lifecycle?*/
/*since we need to check the whole lifecycle, i will union with multiple queries to make them into one result/output*/

SELECT
    'Received to Under Review' as processing_stage,
    AVG(CAST(DATEDIFF(DAY, r.status_date, u.status_date) as decimal(5,2))) as avg_days
FROM fact_invoice_status as r
INNER JOIN fact_invoice_status as u
ON r.Invoice_id = u.Invoice_id
WHERE r.Invoice_status = 'Received' AND u.Invoice_status = 'Under Review'

UNION ALL

SELECT
    'Under Review to Approved',
    AVG(CAST(DATEDIFF(DAY, s.status_date, t.status_date) as DECIMAL(5,2)))
FROM fact_invoice_status as s
INNER JOIN fact_invoice_status as t
ON s.Invoice_id = t.Invoice_id
WHERE  s.Invoice_status = 'Under Review' AND t.Invoice_status = 'Approved'

UNION ALL

SELECT
    'Approved to Posted',
    AVG(CAST(DATEDIFF(DAY, k.status_date, l.status_date) as DECIMAL(5,2)))
FROM fact_invoice_status as k
INNER JOIN fact_invoice_status as l
ON k.Invoice_id = l.Invoice_id
WHERE k.Invoice_status = 'Approved' and l.Invoice_status = 'Posted'

UNION ALL

SELECT 
    'Posted to Ready for payment',
    AVG(CAST(DATEDIFF(DAY, i.status_date, j.status_date) as DECIMAL(5,2)))
FROM fact_invoice_status as i
INNER JOIN fact_invoice_status as j
ON i.Invoice_id = j.Invoice_id
WHERE i.Invoice_status = 'Posted' AND j.Invoice_status = 'Ready for payment'

ORDER by avg_days DESC;

/*30. Which vendors show multiple operational risk indicators?*/

SELECT
    v.vendor_id,
    v.vendor_name,
    COUNT(DISTINCT i.invoice_id) AS invoice_count,
    COUNT(DISTINCT e.exception_id) AS exception_count,
    COUNT
    (
        DISTINCT CASE
            WHEN LOWER(LTRIM(RTRIM(p.payment_status))) = 'paid late'
            THEN p.invoice_id
        END
    ) AS late_payment_count
FROM fact_invoice AS i
INNER JOIN dim_vendor AS v
    ON i.vendor_id = v.vendor_id
LEFT JOIN fact_exception AS e
    ON i.invoice_id = e.invoice_id
INNER JOIN fact_payment AS p
    ON i.invoice_id = p.invoice_id
GROUP BY v.vendor_id, v.vendor_name
ORDER BY exception_count DESC, late_payment_count DESC;

/*31. Which departments show the greatest processing workload and SLA pressure?*/

;WITH InvoiceLifecycle AS
(
    SELECT
        invoice_id,
        MIN(CASE WHEN invoice_status = 'Received' THEN status_date END) AS received_date,
        MIN(CASE WHEN invoice_status = 'Ready for payment' THEN status_date END) AS ready_date
    FROM fact_invoice_status
    GROUP BY invoice_id
)
SELECT
    d.department_id,
    d.department_name,
    COUNT(i.invoice_id) AS invoice_volume,
    SUM(CASE WHEN DATEDIFF(DAY, l.received_date, l.ready_date) > 5 THEN 1 ELSE 0 END) AS sla_breaches
FROM fact_invoice AS i
INNER JOIN dim_department AS d
    ON i.department_id = d.department_id
INNER JOIN InvoiceLifecycle AS l
    ON i.invoice_id = l.invoice_id
WHERE l.received_date IS NOT NULL
  AND l.ready_date IS NOT NULL
GROUP BY d.department_id, d.department_name
ORDER BY invoice_volume DESC, sla_breaches DESC;

/*32. Which exception categories show both high frequency and longer resolution time?*/

SELECT
    exception_type,
    COUNT(exception_id) as exception_count,
    AVG(resolution_days) as AVG_resolution_days
From fact_exception
GROUP BY exception_type
ORDER BY exception_count DESC, AVG_resolution_days DESC;

/*33. What operational areas should AP investigate based on the observed data?*/

;WITH InvoiceLifecycle AS
(
    SELECT
        invoice_id,
        MIN(CASE WHEN invoice_status = 'Received' THEN status_date END) AS received_date,
        MIN(CASE WHEN invoice_status = 'Ready for payment' THEN status_date END) AS ready_date
    FROM fact_invoice_status
    GROUP BY invoice_id
),
ExceptionsByInvoice AS
(
    SELECT
        invoice_id,
        COUNT(*) AS exception_count
    FROM fact_exception
    GROUP BY invoice_id
),
PaymentsByInvoice AS
(
    SELECT
        invoice_id,
        MAX
        (
            CASE
                WHEN LOWER(LTRIM(RTRIM(payment_status))) = 'paid late' THEN 1
                ELSE 0
            END
        ) AS late_payment_flag
    FROM fact_payment
    GROUP BY invoice_id
)
SELECT
    d.department_name,
    COUNT(i.invoice_id) AS invoice_volume,
    SUM(CASE WHEN DATEDIFF(DAY, l.received_date, l.ready_date) > 5 THEN 1 ELSE 0 END) AS sla_breaches,
    SUM(COALESCE(e.exception_count, 0)) AS exception_count,
    SUM(COALESCE(p.late_payment_flag, 0)) AS late_payment_count
FROM fact_invoice AS i
INNER JOIN dim_department AS d
    ON i.department_id = d.department_id
INNER JOIN InvoiceLifecycle AS l
    ON i.invoice_id = l.invoice_id
LEFT JOIN ExceptionsByInvoice AS e
    ON i.invoice_id = e.invoice_id
LEFT JOIN PaymentsByInvoice AS p
    ON i.invoice_id = p.invoice_id
WHERE l.received_date IS NOT NULL
  AND l.ready_date IS NOT NULL
GROUP BY d.department_name
ORDER BY invoice_volume DESC;


