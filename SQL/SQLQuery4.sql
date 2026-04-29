USE Retail_DW;
GO

IF OBJECT_ID('dbo.FactRetailSales','U') IS NOT NULL DROP TABLE dbo.FactRetailSales;
IF OBJECT_ID('dbo.DimCustomer','U') IS NOT NULL DROP TABLE dbo.DimCustomer;
IF OBJECT_ID('dbo.DimProduct','U') IS NOT NULL DROP TABLE dbo.DimProduct;
IF OBJECT_ID('dbo.DimOrderProfile','U') IS NOT NULL DROP TABLE dbo.DimOrderProfile;
IF OBJECT_ID('dbo.DimDate','U') IS NOT NULL DROP TABLE dbo.DimDate;
GO

CREATE TABLE dbo.DimDate
(
    DateKey      INT PRIMARY KEY,
    FullDate     DATE NOT NULL UNIQUE,
    DayNo        TINYINT NOT NULL,
    DayName      VARCHAR(20) NOT NULL,
    MonthNo      TINYINT NOT NULL,
    MonthName    VARCHAR(20) NOT NULL,
    QuarterNo    TINYINT NOT NULL,
    YearNo       SMALLINT NOT NULL
);
GO

CREATE TABLE dbo.DimCustomer
(
    CustomerKey        INT IDENTITY(1,1) PRIMARY KEY,
    Customer_ID        INT NOT NULL,
    Name               NVARCHAR(50) NULL,
    Email              NVARCHAR(50) NULL,
    Phone              NVARCHAR(50) NULL,
    Address            NVARCHAR(200) NULL,
    City               NVARCHAR(50) NULL,
    State              NVARCHAR(50) NULL,
    Zipcode            NVARCHAR(50) NULL,
    Country            NVARCHAR(50) NULL,
    Age                TINYINT NULL,
    Gender             NVARCHAR(50) NULL,
    Income             NVARCHAR(50) NULL,
    Customer_Segment   NVARCHAR(50) NULL,
    StartDate          DATETIME NOT NULL,
    EndDate            DATETIME NOT NULL,
    CurrentFlag        CHAR(1) NOT NULL
);
GO

CREATE TABLE dbo.DimProduct
(
    ProductKey         INT IDENTITY(1,1) PRIMARY KEY,
    Product_Category   NVARCHAR(50) NULL,
    Product_Brand      NVARCHAR(50) NULL,
    Product_Type       NVARCHAR(50) NULL,
    ProductName        NVARCHAR(50) NULL,
    InsertDate         DATETIME NOT NULL DEFAULT GETDATE(),
    ModifiedDate       DATETIME NOT NULL DEFAULT GETDATE()
);
GO

CREATE TABLE dbo.DimOrderProfile
(
    OrderProfileKey    INT IDENTITY(1,1) PRIMARY KEY,
    Feedback           NVARCHAR(50) NULL,
    Shipping_Method    NVARCHAR(50) NULL,
    Payment_Method     NVARCHAR(50) NULL,
    Order_Status       NVARCHAR(50) NULL,
    Ratings            INT NULL,
    InsertDate         DATETIME NOT NULL DEFAULT GETDATE(),
    ModifiedDate       DATETIME NOT NULL DEFAULT GETDATE()
);
GO

CREATE TABLE dbo.FactRetailSales
(
    SalesKey                 BIGINT IDENTITY(1,1) PRIMARY KEY,
    Transaction_ID           INT NOT NULL,
    DateKey                  INT NOT NULL,
    CustomerKey              INT NOT NULL,
    ProductKey               INT NOT NULL,
    OrderProfileKey          INT NOT NULL,
    Quantity                 INT NULL,
    UnitAmount               DECIMAL(18,2) NULL,
    SalesAmount              DECIMAL(18,2) NULL,
    accm_txn_create_time     DATETIME NOT NULL,
    accm_txn_complete_time   DATETIME NULL,
    txn_process_time_hours   INT NULL,

    CONSTRAINT FK_FactRetailSales_Date FOREIGN KEY(DateKey)
        REFERENCES dbo.DimDate(DateKey),
    CONSTRAINT FK_FactRetailSales_Customer FOREIGN KEY(CustomerKey)
        REFERENCES dbo.DimCustomer(CustomerKey),
    CONSTRAINT FK_FactRetailSales_Product FOREIGN KEY(ProductKey)
        REFERENCES dbo.DimProduct(ProductKey),
    CONSTRAINT FK_FactRetailSales_OrderProfile FOREIGN KEY(OrderProfileKey)
        REFERENCES dbo.DimOrderProfile(OrderProfileKey)
);
GO









USE Retail_DW;
GO

DECLARE @StartDate DATE = '2023-01-01';
DECLARE @EndDate   DATE = '2026-12-31';

;WITH d AS
(
    SELECT @StartDate AS dt
    UNION ALL
    SELECT DATEADD(DAY, 1, dt)
    FROM d
    WHERE dt < @EndDate
)
INSERT INTO dbo.DimDate
(
    DateKey, FullDate, DayNo, DayName, MonthNo, MonthName, QuarterNo, YearNo
)
SELECT
    CONVERT(INT, CONVERT(CHAR(8), dt, 112)),
    dt,
    DATEPART(DAY, dt),
    DATENAME(WEEKDAY, dt),
    DATEPART(MONTH, dt),
    DATENAME(MONTH, dt),
    DATEPART(QUARTER, dt),
    DATEPART(YEAR, dt)
FROM d
OPTION (MAXRECURSION 0);
GO




USE Retail_DW;
GO

SELECT TOP 10 *
FROM dbo.DimDate;
GO




USE Retail_DW;
GO

CREATE OR ALTER PROCEDURE dbo.UpdateDimProduct
    @Product_Category NVARCHAR(50),
    @Product_Brand NVARCHAR(50),
    @Product_Type NVARCHAR(50),
    @ProductName NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.DimProduct
        WHERE ISNULL(Product_Category,'') = ISNULL(@Product_Category,'')
          AND ISNULL(Product_Brand,'') = ISNULL(@Product_Brand,'')
          AND ISNULL(Product_Type,'') = ISNULL(@Product_Type,'')
          AND ISNULL(ProductName,'') = ISNULL(@ProductName,'')
    )
    BEGIN
        INSERT INTO dbo.DimProduct
        (
            Product_Category, Product_Brand, Product_Type, ProductName,
            InsertDate, ModifiedDate
        )
        VALUES
        (
            @Product_Category, @Product_Brand, @Product_Type, @ProductName,
            GETDATE(), GETDATE()
        );
    END
    ELSE
    BEGIN
        UPDATE dbo.DimProduct
        SET ModifiedDate = GETDATE()
        WHERE ISNULL(Product_Category,'') = ISNULL(@Product_Category,'')
          AND ISNULL(Product_Brand,'') = ISNULL(@Product_Brand,'')
          AND ISNULL(Product_Type,'') = ISNULL(@Product_Type,'')
          AND ISNULL(ProductName,'') = ISNULL(@ProductName,'');
    END
END;
GO

CREATE OR ALTER PROCEDURE dbo.UpdateDimOrderProfile
    @Feedback NVARCHAR(50),
    @Shipping_Method NVARCHAR(50),
    @Payment_Method NVARCHAR(50),
    @Order_Status NVARCHAR(50),
    @Ratings INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.DimOrderProfile
        WHERE ISNULL(Feedback,'') = ISNULL(@Feedback,'')
          AND ISNULL(Shipping_Method,'') = ISNULL(@Shipping_Method,'')
          AND ISNULL(Payment_Method,'') = ISNULL(@Payment_Method,'')
          AND ISNULL(Order_Status,'') = ISNULL(@Order_Status,'')
          AND ISNULL(Ratings,-1) = ISNULL(@Ratings,-1)
    )
    BEGIN
        INSERT INTO dbo.DimOrderProfile
        (
            Feedback, Shipping_Method, Payment_Method, Order_Status, Ratings,
            InsertDate, ModifiedDate
        )
        VALUES
        (
            @Feedback, @Shipping_Method, @Payment_Method, @Order_Status, @Ratings,
            GETDATE(), GETDATE()
        );
    END
    ELSE
    BEGIN
        UPDATE dbo.DimOrderProfile
        SET ModifiedDate = GETDATE()
        WHERE ISNULL(Feedback,'') = ISNULL(@Feedback,'')
          AND ISNULL(Shipping_Method,'') = ISNULL(@Shipping_Method,'')
          AND ISNULL(Payment_Method,'') = ISNULL(@Payment_Method,'')
          AND ISNULL(Order_Status,'') = ISNULL(@Order_Status,'')
          AND ISNULL(Ratings,-1) = ISNULL(@Ratings,-1);
    END
END;
GO


USE Retail_DW;
GO

SELECT name
FROM sys.tables
ORDER BY name;
GO

USE Retail_DW;
GO

SELECT name
FROM sys.procedures
ORDER BY name;
GO