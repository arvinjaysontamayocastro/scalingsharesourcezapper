-- Question 1 - Database Design
-- At Zapper we facilitate transactions between our customers and merchants.
-- Write SQL to define data structures which could help us track transactions.

CREATE TABLE Customers (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    LastName VARCHAR(255) NOT NULL,
    FirstName VARCHAR(255)
);

GO

CREATE TABLE CustomerSettings (
	CustomerID INT FOREIGN KEY REFERENCES Customers(ID),
    IsSMSNotificationsEnabled BIT NULL,
    IsPushNotificationsEnabled BIT NULL,
    IsBiometricsEnabled BIT NULL,
    IsCameraEnabled BIT NULL,
    IsLocationEnabled BIT NULL,
    IsNFCEnabled BIT NULL,
    IsVouchersEnabled BIT NULL,
    IsLoyaltyEnabled BIT NULL
);

GO

CREATE TABLE Merchants (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    Name VARCHAR(255) NOT NULL
);

GO

CREATE TABLE Products (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    Name VARCHAR(255) NOT NULL,
    Description VARCHAR(255) NOT NULL
);

GO

CREATE TABLE ProductVariations (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    Variation VARCHAR(100) NOT NULL,
    SubDescription VARCHAR(255) NOT NULL,
    Price INT NOT NULL
);

GO

CREATE TABLE Transactions (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    Name varchar(255) NOT NULL,
    TotalPrice INT,
    OrderDate DATE NOT NULL
);

GO

CREATE TABLE TransactionsItems (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    Quantity INT,
    TotalPrice INT,
    ProductVariationID INT FOREIGN KEY REFERENCES ProductVariations(ID)
);  

GO

-- ---------------------------------------------------------------                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         

-- Question 2 - User Settings
-- A user profile has 8 boolean settings which determines their functionality.
-- 1 - SMS Notifications Enabled
-- 2 - Push Notifications Enabled
-- 3 - Bio-metrics Enabled
-- 4 - Camera Enabled
-- 5 - Location Enabled
-- 6 - NFC Enabled
-- 7 - Vouchers Enabled
-- 8 - Loyalty Enabled

-- Question 2.1 Checking if a feature is enabled
-- If a users settings were represented as a string where each position represents a
-- different setting. Write a function which can determine if user has a specific feature
-- enabled.

CREATE OR ALTER FUNCTION IsSettingsEnabled
(
   @Settings VARCHAR(8),
   @Setting INT
)
RETURNS bit
AS
BEGIN
	DECLARE @SettingValue BIT
	SELECT @SettingValue = SUBSTRING(@Settings, @Setting, 1)

    IF @SettingValue = 1
		RETURN 1 
	RETURN 0
 
END
GO

-- Question 2.2 Storing user settings
-- Write some functions which can read and write the settings to a file in the least
-- amount of space.

CREATE OR ALTER PROC GetSettingsEnabled
(
	@CustomerID INT
)
AS
BEGIN
    DECLARE @Settings VARCHAR(8)

	DECLARE @IsSMSNotificationsEnabled BIT
	DECLARE @IsPushNotificationsEnabled BIT
	DECLARE @IsBiometricsEnabled BIT
	DECLARE @IsCameraEnabled BIT
	DECLARE @IsLocationEnabled BIT
	DECLARE @IsNFCEnabled BIT
	DECLARE @IsVouchersEnabled BIT
	DECLARE @IsLoyaltyEnabled BIT
	
	SELECT @IsSMSNotificationsEnabled = IsSMSNotificationsEnabled,
		@IsPushNotificationsEnabled = IsPushNotificationsEnabled,
		@IsBiometricsEnabled = IsBiometricsEnabled,
		@IsCameraEnabled = IsCameraEnabled,
		@IsLocationEnabled = IsLocationEnabled,
		@IsNFCEnabled = IsNFCEnabled,
		@IsVouchersEnabled = IsVouchersEnabled,
		@IsLoyaltyEnabled = IsLoyaltyEnabled
	FROM dbo.CustomerSettings
	WHERE CustomerID = @CustomerID
	
	SELECT @Settings = CONCAT(@IsSMSNotificationsEnabled,
		@IsSMSNotificationsEnabled,
		@IsPushNotificationsEnabled,
		@IsBiometricsEnabled,
		@IsCameraEnabled,
		@IsLocationEnabled,
		@IsNFCEnabled,
		@IsVouchersEnabled,
		@IsLoyaltyEnabled
		)

	RETURN @Settings
 
END
GO

CREATE OR ALTER PROC SetSettingsEnabled
(
	@CustomerID INT,
    @Settings VARCHAR(8)
)
AS
BEGIN
	IF EXISTS (SELECT * FROM CustomerSettings WHERE CustomerID = @CustomerID)
	BEGIN
		UPDATE CustomerSettings
		SET IsSMSNotificationsEnabled = dbo.IsSettingsEnabled(@Settings, 1),
			IsPushNotificationsEnabled = dbo.IsSettingsEnabled(@Settings, 2),
			IsBiometricsEnabled = dbo.IsSettingsEnabled(@Settings, 3),
			IsCameraEnabled = dbo.IsSettingsEnabled(@Settings, 4),
			IsLocationEnabled = dbo.IsSettingsEnabled(@Settings, 5),
			IsNFCEnabled = dbo.IsSettingsEnabled(@Settings, 6),
			IsVouchersEnabled = dbo.IsSettingsEnabled(@Settings, 7),
			IsLoyaltyEnabled = dbo.IsSettingsEnabled(@Settings, 8)
		WHERE CustomerID = @CustomerID
	END
	ELSE
	BEGIN
		INSERT INTO dbo.CustomerSettings VALUES (@CustomerID,
		dbo.IsSettingsEnabled(@Settings, 1),
		dbo.IsSettingsEnabled(@Settings, 2),
		dbo.IsSettingsEnabled(@Settings, 3),
		dbo.IsSettingsEnabled(@Settings, 4),
		dbo.IsSettingsEnabled(@Settings, 5),
		dbo.IsSettingsEnabled(@Settings, 6),
		dbo.IsSettingsEnabled(@Settings, 7),
		dbo.IsSettingsEnabled(@Settings, 8))
	END
 
END
GO

-- INSERT INTO dbo.Customers VALUES ('Arvin Jayson', 'Castro')

-- EXEC dbo.SetSettingsEnabled @CustomerID = 1, @Settings = '11111111'

-- DECLARE @ReturnValue VARCHAR(8); EXEC @ReturnValue = dbo.GetSettingsEnabled @CustomerID = 1; SELECT @ReturnValue AS Settings;