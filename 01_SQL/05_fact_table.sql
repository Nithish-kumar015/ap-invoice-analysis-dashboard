USE ap_invoice_analysis;
GO

DECLARE @vendorID INT = 101;
DECLARE @invoiceID INT = 10001;
DECLARE @Month INT;

DECLARE @invoiceDate DATE;
DECLARE @DueDate DATE;
DECLARE @paymentTerms INT;
DECLARE @Category Varchar(50);
DECLARE @InvoiceAmount Decimal (18, 2);
DECLARE @InvoiceType VARCHAR(50);
DECLARE @EmployeeID INT;
DECLARE @DepartmentID INT;
DECLARE @POFlag BIT;

WHILE @vendorID <= 200
BEGIN
    SET @Month = 1;

    SELECT
        @paymentTerms = payment_terms_days,
        @Category = vendor_category
    FROM dim_vendor
    WHERE vendor_id = @vendorID;

    WHILE @Month <= 12
    BEGIN
        SET
            @invoiceDate = 
                DATEADD(
                    DAY,
                    (@vendorID + @Month * 3) % 25,
                    DATEFROMPARTS (2025, @Month, 1)   
                );

        SET @DueDate = DATEADD(DAY, @paymentTerms, @invoiceDate);
        SET @EmployeeID = 1001 + ((@vendorID + @Month) % 8);
        SET @DepartmentID = 1 + ((@vendorID + @Month) % 15);
        SET @POFlag = 
        Case
            When (@vendorID + @Month) % 5 = 0
                Then 0
            Else 1
        END;
    
    IF @Category = 'Office Supplies'
    BEGIN
        SET @InvoiceAmount = (CAST(3000 + (@vendorID * 75) + (@Month * 250) as decimal(18,2)));
        SET @InvoiceType = 'Goods';
    END

    ELSE IF @Category = 'IT Services'
    BEGIN
        SET @InvoiceAmount = (CAST(15000 + (@vendorID * 180) + (@Month * 500) AS decimal(18,2)));
        SET @InvoiceType = 'Services';
    END

    ELSE IF @Category = 'Logistics'
    BEGIN
        SET @InvoiceAmount = (CAST( 8000 + (@vendorID * 120) + (@Month * 350) as decimal(18,2)));
        SET @InvoiceType = 'Logistics';
    END

    ELSE IF @Category = 'Facilities'
    BEGIN
        SET @InvoiceAmount = (CAST(10000 + (@vendorID * 140) + (@Month * 400) as decimal (18,2)));
        SET @InvoiceType = 'Goods';
    END

    ELSE IF @Category = 'Professional Services'
    BEGIN
        SET @InvoiceAmount = (CAST(20000 + (@vendorID * 220) + (@Month * 600) as decimal (18,2)));
        SET @InvoiceType = 'Services';
    END

    ELSE IF @Category = 'Industrial'
    BEGIN
        SET @InvoiceAmount = (CAST(25000 + (@vendorID * 250) + (@Month* 750) as decimal(18,2)));
        SET @InvoiceType = 'Goods';
    END

    ELSE IF @Category = 'Telecom'
    BEGIN
        SET @InvoiceAmount = (CAST(12000 + (@vendorID * 160) + (@Month * 450) as decimal(18,2)));
        SET @InvoiceType = 'Services';
    END

    ELSE IF @Category = 'Marketing'
    BEGIN
        SET @InvoiceAmount = (CAST(7000 + (@vendorID * 110) + (@Month * 300) as decimal(18,2)));
        SET @InvoiceType = 'Services';
    END

    INSERT INTO fact_invoice (
        invoice_id,
        vendor_id,
        employee_id,
        department_id,
        Invoice_date,
        due_date,
        Invoice_amount,
        currency,
        invoice_type,
        purchase_order_flag,
        payment_terms_days
    )
    VALUES
    (
        @invoiceID,
        @vendorID,
        @EmployeeID,
        @DepartmentID,
        @invoiceDate,
        @DueDate,
        @InvoiceAmount,
        'INR',
        @InvoiceType,
        @POFlag,
        @paymentTerms
    );

    SET @invoiceID = @invoiceID + 1;
    SET @Month = @Month + 1;

    END;

    SET @vendorID = @vendorID + 1;

END;
GO

DECLARE @invoiceID INT = 10001;
DECLARE @statusID INT = 1;

DECLARE @invoiceDate DATE;
DECLARE @reviewDate DATE;
DECLARE @AcceptedDate DATE;
DECLARE @PostedDate DATE;
DECLARE @ReadyDate DATE;

DECLARE @reviewDays INT;

WHILE @invoiceID <= 11200
BEGIN
    SELECT
        @invoiceDate = invoice_date
    from fact_invoice
    WHERE invoice_id = @invoiceID;

    SET @reviewDays = 
        Case
            When @invoiceID % 7 = 0 Then 3
            When @invoiceID % 3 = 0 Then 2
            Else 1
        End;

        SET @reviewDate = DATEADD(DAY, @reviewDays, @invoiceDate);
        SET @AcceptedDate = DATEADD(DAY, 1, @reviewDate);
        SET @PostedDate = DATEADD(DAY, 1, @AcceptedDate);
        SET @ReadyDate = DATEADD(DAY, 1, @PostedDate);

        INSERT INTO fact_invoice_status(
            STATUS_ID,
            Invoice_id,
            STATUS_date,
            Invoice_status,
            status_reason
        )
        VALUES(
            @statusID,
            @invoiceID,
            @invoiceDate,
            'Received',
            'Invoice Received'
        )

            SET @statusID = @statusID + 1;

        INSERT INTO fact_invoice_status(
            STATUS_ID,
            Invoice_id,
            STATUS_date,
            Invoice_status,
            status_reason
        )
        VALUES(
            @statusID,
            @invoiceID,
            @reviewDate,
            'Under Review',
            'Invoice Validation'
        )
        
        SET @statusID = @statusID + 1;

          INSERT INTO fact_invoice_status(
            STATUS_ID,
            Invoice_id,
            STATUS_date,
            Invoice_status,
            status_reason
        )
        VALUES(
            @statusID,
            @invoiceID,
            @PostedDate,
            'Posted',
            'Invoice posted'
        )

        SET @statusID = @statusID + 1;

          INSERT INTO fact_invoice_status(
            STATUS_ID,
            Invoice_id,
            STATUS_date,
            Invoice_status,
            status_reason
        )
        VALUES(
            @statusID,
            @invoiceID,
            @ReadyDate,
            'Ready for payment',
            'Payment Queue'
        );

        SET @statusID = @statusID + 1;
        SET @invoiceID = @invoiceID + 1;

        END;
GO



USE ap_invoice_analysis;
GO
    DECLARE @invoiceID INT = 10001;
    DECLARE @statusID INT = 1;

    DECLARE @reviewDate DATE;
    DECLARE @AcceptedDate DATE;

SELECT @statusID = MAX(STATUS_ID) + 1
FROM fact_invoice_status;

WHILE @invoiceID <= 11200
BEGIN
    SELECT @reviewDate = STATUS_date
    FROM fact_invoice_status
    WHERE Invoice_id = @invoiceID AND Invoice_status = 'under review';

    SET @AcceptedDate = DATEADD(DAY, 1, @reviewDate);

    INSERT INTO fact_invoice_status(
            STATUS_ID,
            Invoice_id,
            STATUS_date,
            Invoice_status,
            status_reason
        )
        VALUES(
            @statusID,
            @invoiceID,
            @AcceptedDate,
            'Approved',
            'Approval completed'
        );
        SET @statusID = @statusID + 1;
        SET @invoiceID = @invoiceID + 1;
    END;


SET XACT_ABORT ON;
GO
BEGIN TRY
    BEGIN TRANSACTION;
        DECLARE @invoiceID INT = 10001;
        DECLARE @exceptionID INT = 1;

        DECLARE @invoiceDate DATE;
        DECLARE @exceptiondate DATE;
        DECLARE @resolutiondate DATE;

        DECLARE @resolutiondays INT;
        DECLARE @exceptiontype VARCHAR(50);


        WHILE @invoiceID <= 11200
        BEGIN
            IF @invoiceID % 5 = 0
            BEGIN
                SELECT @invoiceDate = Invoice_date
            FROM fact_invoice
            WHERE invoice_id = @invoiceID;

            set @exceptiondate = DATEADD(DAY, 1, @invoiceDate);
            SET @resolutiondays =
                case
                    when @invoiceID % 7 = 0 Then 5
                    when @invoiceID % 3 = 0 then 3
                    else 2
                END
            
            SET @resolutiondate = DATEADD(DAY, @resolutiondays, @exceptiondate);
            SET @exceptiontype =
                Case
                    when @invoiceID % 4 = 0 then 'PO Mismatch'
                    when @invoiceID % 4 = 1 then 'Missing information'
                    when @invoiceID % 4 = 2 then 'Duplicate Invoice'
                    else 'Amount Mismatch'
                END;
        
    INSERT INTO fact_exception(
        exception_id,
        invoice_id,
        exception_date,
        exception_type,
        exception_status,
        resolution_date,
        resolution_days
    )
    VALUES(
        @exceptionID,
        @invoiceID,
        @exceptiondate,
        @exceptiontype,
        'Resolved',
        @resolutiondate,
        @resolutiondays
    );

    Set @exceptionID = @exceptionID + 1;

END;

    SET @invoiceID = @invoiceID + 1;
END;

    COMMIT TRANSACTION;

END TRY

BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

        THROW;

END CATCH;


SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    IF EXISTS(SELECT 1 FROM fact_payment)
    BEGIN
        THROW 50001, 'fact_payment is not empty. Load cancelled to prevent duplicate payments.', 1;
    END;

    DECLARE @invoiceID INT = 10001;
    DECLARE @paymentID INT = 1;

    DECLARE @DueDate DATE;
    DECLARE @InvoiceAmount DECIMAL(18,2);

    DECLARE @paymentDate DATE;
    DECLARE @paymentDelayDays INT;

    DECLARE @paymentMethod VARCHAR(30);
    DECLARE @paymentStatus VARCHAR(30);

    WHILE @invoiceID <= 11200
    BEGIN
        SELECT
            @DueDate = due_date,
            @InvoiceAmount = Invoice_amount
        From fact_invoice
        WHERE invoice_id = @invoiceID;

        IF EXISTS(
            SELECT 1
            FROM fact_exception
            Where invoice_id = @invoiceID
        )
        BEGIN
            SELECT @paymentDelayDays = resolution_days
            FROM fact_exception
            WHERE invoice_id = @invoiceID;

            SELECT
                @paymentDelayDays = 
                Case
                    when @invoiceID % 4 = 0 Then 2
                    When @invoiceID % 3 = 0 then 1
                    Else 0
                END;

    END
    ELSE
    BEGIN
        SET @paymentDelayDays =
            Case
                When @invoiceID % 10 In(0,1) then 5
                When @invoiceID % 7 = 0 then 2
                Else 0
            END;
    END;

    SET @paymentDate = DATEADD(DAY, @paymentDelayDays, @DueDate);

    SET @paymentStatus =
        Case
            When @paymentDate <= @DueDate Then 'paid on time'
            Else 'Paid Late'
        END;

    SET @paymentMethod = 
        Case
            When @invoiceID % 4 = 0 then 'Bank transfer'
            When @invoiceID % 4 = 1 Then 'ACH'
            When @invoiceID % 4 = 2 then 'wire transfer'
            Else 'Check'
        END;

        INSERT INTO fact_payment(
            payment_id,
            invoice_id,
            payment_date,
            payment_amount,
            payment_method,
            payment_status
        )
        VALUES(
            @paymentID,
            @invoiceID,
            @paymentDate,
            @InvoiceAmount,
            @paymentMethod,
            @paymentStatus
        );

        SET @paymentID = @paymentID + 1;
        SET @invoiceID = @invoiceID + 1;
    END;

    COMMIT TRANSACTION;

END TRY
    BEGIN CATCH
        If @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;



