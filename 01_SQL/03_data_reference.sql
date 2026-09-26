USE ap_invoice_analysis;

GO

INSERT INTO dim_department (department_id, department_name, cost_center)
VALUES
    (1, 'Finance', 'CC100'),
    (2, 'Procurement', 'CC200'),
    (3, 'Operations', 'CC300'),
    (4, 'IT', 'CC400'),
    (5, 'Human Resources', 'CC500');

GO

INSERT INTO dim_vendor (vendor_id, vendor_name, vendor_category, payment_terms_days, vendor_region, vendor_status)
VALUES
    (101, 'Alpha Office Supplies', 'Office Supplies', 30, 'North', 'Active'),
    (102, 'Beta Technologies', 'IT Services', 45, 'South', 'Active'),
    (103, 'Gamma Logistics', 'Logistics', 30, 'West', 'Active'),
    (104, 'Delta Facilities', 'Facilities', 60, 'East', 'Active'),
    (105, 'Epsilon Consulting', 'Professional Services', 30, 'North', 'Active'),
    (106, 'Zeta Industrial', 'Industrial', 45, 'West', 'Active'),
    (107, 'Omega Telecom', 'Telecom', 30, 'South', 'Active'),
    (108, 'Prime Marketing', 'Marketing', 30, 'East', 'Active');

GO

INSERT INTO dim_employee (employee_id, employee_name, employee_role,department_id)
VALUES
    (1001, 'Amit Sharma', 'AP Analyst', 1),
    (1002, 'Priya Rao', 'AP Analyst', 1),
    (1003, 'Rahul Mehta', 'AP Specialist', 1),
    (1004, 'Sneha Iyer', 'Procurement Analyst', 2),
    (1005, 'Arjun Kumar', 'Procurement Specialist', 2),
    (1006, 'Neha Singh', 'Operations Analyst', 3),
    (1007, 'Vikram Patel', 'IT Analyst', 4),
    (1008, 'Kavya Nair', 'HR Analyst', 5);

GO

DECLARE @startdate DATE = '2025-01-01';
DECLARE @enddate DATE = '2025-12-31';

WHILE @startdate <= @enddate
BEGIN

INSERT INTO dim_date (
    Date_key,
    full_date,
    year,
    QUARTER,
    MONTH,
    month_name,
    week_number,
    day_of_week,
    day_name
)
VALUES
(
    CONVERT(INT, FORMAT(@startdate, 'yyyyMMdd')),
    @startdate,
    YEAR(@startdate),
    DATEPART(QUARTER, @startdate),
    MONTH(@startdate),
    DATENAME(MONTH, @startdate),
    DATEPART(week, @startdate),
    DATEPART(WEEKDAY, @startdate),
    DATENAME(WEEKDAY, @startdate)
);
SET @startdate = DATEADD(Day, 1, @startdate)
END;
GO

SELECT * from dim_department

SELECT
    COUNT(*) as totaldays,
    MIN(full_date) as startdate,
    MAX(full_date) as enddate
FROM dim_date

INSERT INTO dim_department (department_id, department_name, cost_center)
VALUES
    (6, 'sales', 'CCC600'),
    (7, 'Marketing', 'CC700'),
    (8, 'Legal', 'CC800'),
    (9, 'Supply Chain', 'CC900'),
    (10, 'Customer service', 'CC1000'),
    (11, 'Research & development', 'CC1100'),
    (12, 'Quality Assurance', 'CC1200'),
    (13, 'Administration', 'CC1300'),
    (14, 'Facilities', 'CC1400'),
    (15, 'Engineering', 'CC1500');
GO

SELECT * from dim_department;

UPDATE dim_department
SET cost_center = 'CC600'
    WHERE department_id = 6;

INSERT INTO dim_vendor (vendor_id, vendor_name, vendor_category, payment_terms_days, vendor_region, vendor_status)
VALUES
    (109, 'Apex Office Solutions', 'Office Supplies', 30, 'North', 'Active'),
    (110, 'Brightline Systems', 'IT Services', 45, 'South', 'Active'),
    (111, 'Core Logistics', 'Logistics', 30, 'West', 'Active'),
    (112, 'Vertex Facilities', 'Facilities', 60, 'East', 'Active'),
    (113, 'Nexus Consulting', 'Professional Services', 30, 'North', 'Active'),
    (114, 'Summit Industrial', 'Industrial', 45, 'West', 'Active'),
    (115, 'Orbit Telecom', 'Telecom', 30, 'South', 'Active'),
    (116, 'Insight Marketing', 'Marketing', 30, 'East', 'Active'),
    (117, 'Pioneer Supplies', 'Office Supplies', 30, 'North', 'Active'),
    (118, 'TechNova Solutions', 'IT Services', 45, 'South', 'Active'),
    (119, 'RapidRoute Logistics', 'Logistics', 30, 'West', 'Active'),
    (120, 'Urban Facilities', 'Facilities', 60, 'East', 'Active'),
    (121, 'Prime Advisory', 'Professional Services', 30, 'North', 'Active'),
    (122, 'Westline Industrial', 'Industrial', 45, 'West', 'Active'),
    (123, 'Connect Telecom', 'Telecom', 30, 'South', 'Active'),
    (124, 'MarketEdge', 'Marketing', 30, 'East', 'Active'),
    (125, 'OfficePro India', 'Office Supplies', 30, 'North', 'Active'),
    (126, 'CloudMatrix', 'IT Services', 45, 'South', 'Active'),
    (127, 'Swift Logistics', 'Logistics', 30, 'West', 'Active'),
    (128, 'EastPoint Facilities', 'Facilities', 60, 'East', 'Active'),
    (129, 'StratEdge Consulting', 'Professional Services', 30, 'North', 'Active'),
    (130, 'IronWorks India', 'Industrial', 45, 'West', 'Active'),
    (131, 'SignalNet', 'Telecom', 30, 'South', 'Active'),
    (132, 'BrandWorks', 'Marketing', 30, 'East', 'Active'),
    (133, 'Stationery Hub', 'Office Supplies', 30, 'North', 'Active'),
    (134, 'DataSphere', 'IT Services', 45, 'South', 'Active'),
    (135, 'CargoLink', 'Logistics', 30, 'West', 'Active'),
    (136, 'FacilityCare', 'Facilities', 60, 'East', 'Active'),
    (137, 'BusinessFirst', 'Professional Services', 30, 'North', 'Active'),
    (138, 'IndustrialWorks', 'Industrial', 45, 'West', 'Active'),
    (139, 'TeleLink India', 'Telecom', 30, 'South', 'Active'),
    (140, 'CreativeEdge', 'Marketing', 30, 'East', 'Active'),
    (141, 'Metro Supplies', 'Office Supplies', 30, 'North', 'Active'),
    (142, 'NextGen IT', 'IT Services', 45, 'South', 'Active'),
    (143, 'TransRoute', 'Logistics', 30, 'West', 'Active'),
    (144, 'SafeSpace Facilities', 'Facilities', 60, 'East', 'Active'),
    (145, 'ProConsult', 'Professional Services', 30, 'North', 'Active'),
    (146, 'SteelCore', 'Industrial', 45, 'West', 'Active'),
    (147, 'NetConnect', 'Telecom', 30, 'South', 'Active'),
    (148, 'MediaPoint', 'Marketing', 30, 'East', 'Active'),
    (149, 'OfficeLink', 'Office Supplies', 30, 'North', 'Active'),
    (150, 'SystemWorks', 'IT Services', 45, 'South', 'Active'),
    (151, 'LogiPro', 'Logistics', 30, 'West', 'Active'),
    (152, 'FacilityPlus', 'Facilities', 60, 'East', 'Active'),
    (153, 'Expert Advisory', 'Professional Services', 30, 'North', 'Active'),
    (154, 'Industrial Plus', 'Industrial', 45, 'West', 'Active'),
    (155, 'TelecomOne', 'Telecom', 30, 'South', 'Active'),
    (156, 'AdVision', 'Marketing', 30, 'East', 'Active'),
    (157, 'SupplyWorks', 'Office Supplies', 30, 'North', 'Active'),
    (158, 'TechBridge', 'IT Services', 45, 'South', 'Active'),
    (159, 'LogisticsOne', 'Logistics', 30, 'West', 'Active'),
    (160, 'FacilityWorks', 'Facilities', 60, 'East', 'Active'),
    (161, 'ConsultPro', 'Professional Services', 30, 'North', 'Active'),
    (162, 'MetalWorks', 'Industrial', 45, 'West', 'Active'),
    (163, 'TeleNet', 'Telecom', 30, 'South', 'Active'),
    (164, 'PromoWorks', 'Marketing', 30, 'East', 'Active'),
    (165, 'Corporate Supplies', 'Office Supplies', 30, 'North', 'Active'),
    (166, 'DigitalCore', 'IT Services', 45, 'South', 'Active'),
    (167, 'RouteMaster', 'Logistics', 30, 'West', 'Active'),
    (168, 'FacilityPro', 'Facilities', 60, 'East', 'Active'),
    (169, 'Advisory Partners', 'Professional Services', 30, 'North', 'Active'),
    (170, 'Industrial Partners', 'Industrial', 45, 'West', 'Active'),
    (171, 'Telecom Partners', 'Telecom', 30, 'South', 'Active'),
    (172, 'Marketing Partners', 'Marketing', 30, 'East', 'Active'),
    (173, 'Office Partners', 'Office Supplies', 30, 'North', 'Active'),
    (174, 'IT Partners', 'IT Services', 45, 'South', 'Active'),
    (175, 'Logistics Partners', 'Logistics', 30, 'West', 'Active'),
    (176, 'Facilities Partners', 'Facilities', 60, 'East', 'Active'),
    (177, 'Consulting Partners', 'Professional Services', 30, 'North', 'Active'),
    (178, 'Industrial Network', 'Industrial', 45, 'West', 'Active'),
    (179, 'Telecom Network', 'Telecom', 30, 'South', 'Active'),
    (180, 'Marketing Network', 'Marketing', 30, 'East', 'Active'),
    (181, 'Office Network', 'Office Supplies', 30, 'North', 'Active'),
    (182, 'Technology Network', 'IT Services', 45, 'South', 'Active'),
    (183, 'Logistics Network', 'Logistics', 30, 'West', 'Active'),
    (184, 'Facilities Network', 'Facilities', 60, 'East', 'Active'),
    (185, 'Consulting Network', 'Professional Services', 30, 'North', 'Active'),
    (186, 'Industrial Source', 'Industrial', 45, 'West', 'Active'),
    (187, 'Telecom Source', 'Telecom', 30, 'South', 'Active'),
    (188, 'Marketing Source', 'Marketing', 30, 'East', 'Active'),
    (189, 'Office Source', 'Office Supplies', 30, 'North', 'Active'),
    (190, 'Technology Source', 'IT Services', 45, 'South', 'Active'),
    (191, 'Logistics Source', 'Logistics', 30, 'West', 'Active'),
    (192, 'Facilities Source', 'Facilities', 60, 'East', 'Active'),
    (193, 'Consulting Source', 'Professional Services', 30, 'North', 'Active'),
    (194, 'Industrial Direct', 'Industrial', 45, 'West', 'Active'),
    (195, 'Telecom Direct', 'Telecom', 30, 'South', 'Active'),
    (196, 'Marketing Direct', 'Marketing', 30, 'East', 'Active'),
    (197, 'Office Direct', 'Office Supplies', 30, 'North', 'Active'),
    (198, 'Technology Direct', 'IT Services', 45, 'South', 'Active'),
    (199, 'Logistics Direct', 'Logistics', 30, 'West', 'Active'),
    (200, 'Facilities Direct', 'Facilities', 60, 'East', 'Active');

SELECT count(*) as totavendors
FROM dim_vendor;

