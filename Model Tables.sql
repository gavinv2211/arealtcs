use arealtcs
GO

IF NOT EXISTS (SELECT 1 FROM SYS.SCHEMAS WHERE [name] = 'staging')
                                begin
                                EXEC ('CREATE SCHEMA [model]')
                                end

--Data Model
-- DROP Foreign Keys
IF (OBJECT_ID('model.FK_dp_bar_barId', 'F') IS NOT NULL)
BEGIN
ALTER TABLE [model].[drinkPrice] DROP CONSTRAINT [FK_dp_bar_barId]
END
GO

IF (OBJECT_ID('model.FK_dp_drink_drinkId', 'F') IS NOT NULL)
BEGIN
ALTER TABLE [model].[drinkPrice] DROP CONSTRAINT [FK_dp_drink_drinkId]
END
GO

IF (OBJECT_ID('model.FK_v_bar_barId', 'F') IS NOT NULL)
BEGIN
ALTER TABLE [model].[visits] DROP CONSTRAINT [FK_v_bar_barId]
END
GO

IF (OBJECT_ID('model.FK_v_drink_drinkId', 'F') IS NOT NULL)
BEGIN
ALTER TABLE [model].[visits] DROP CONSTRAINT [FK_v_drink_drinkId]
END
GO

IF (OBJECT_ID('model.FK_d_drinkType_typeId', 'F') IS NOT NULL)
BEGIN
ALTER TABLE [model].[drink] DROP CONSTRAINT [FK_d_drinkType_typeId]
END
GO

-- drop & Create Tables
IF OBJECT_ID(N'model.bar', N'U') IS NOT NULL
DROP TABLE model.bar

IF OBJECT_ID(N'model.drink', N'U') IS NOT NULL
DROP TABLE model.drink

IF OBJECT_ID(N'model.drinkPrice', N'U') IS NOT NULL
DROP TABLE model.drinkPrice

IF OBJECT_ID(N'model.visits', N'U') IS NOT NULL
DROP TABLE model.visits

IF OBJECT_ID(N'model.drinkType', N'U') IS NOT NULL
DROP TABLE model.drinkType
GO

CREATE TABLE model.bar
(
barId int identity(1,1) primary key not null,
barName varchar(25) not null,
address varchar(125)
)
GO

CREATE TABLE model.drinkType
(
typeId int identity(1,1) primary key not null,
type varchar(25) not null
)

CREATE TABLE model.drink
(
drinkId int identity(1,1) primary key not null,
drinkName varchar(25) not null,
typeId int,
codeBar int,
alcoholUnits decimal(18,2),
CONSTRAINT FK_d_drinkType_typeId FOREIGN KEY (typeId) REFERENCES model.drinkType(typeId)
)
GO

CREATE TABLE model.drinkPrice
(
drinkPriceId int identity(1,1) primary key not null,
barId INT NOT NULL,
drinkId INT NOT NULL,
price decimal(18,2),
fromDate date,
toDate date,
CONSTRAINT FK_dp_bar_barId FOREIGN KEY (barId) REFERENCES model.bar(barId),
CONSTRAINT FK_dp_drink_drinkId FOREIGN KEY (drinkId) REFERENCES model.drink(drinkId)
)
GO

CREATE TABLE model.visits
(
visitId int identity(1,1) primary key not null,
barId INT NOT NULL,
drinkId INT NOT NULL,
happyHour bit,
drinksCount int,
visited date,
uuid nvarchar(255)
CONSTRAINT FK_v_bar_barId FOREIGN KEY (barId) REFERENCES model.bar(barId),
CONSTRAINT FK_v_drink_drinkId FOREIGN KEY (drinkId) REFERENCES model.drink(drinkId)
)

