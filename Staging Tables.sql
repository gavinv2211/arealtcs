USE [arealtcs]
GO


IF NOT EXISTS (SELECT 1 FROM SYS.SCHEMAS WHERE [name] = 'staging')
                                begin
                                EXEC ('CREATE SCHEMA [staging]')
                                end

IF OBJECT_ID(N'staging.bars', N'U') IS NOT NULL
DROP TABLE staging.bars
GO
IF OBJECT_ID(N'staging.beers', N'U') IS NOT NULL
DROP TABLE staging.beers
GO
IF OBJECT_ID(N'staging.visits', N'U') IS NOT NULL
DROP TABLE staging.visits
GO

CREATE TABLE [staging].[bars](
	[drinkName] [varchar](255) NULL,
	[price] [varchar](255) NULL,
	[barName] [varchar](255) NULL,
	[address] [varchar](500) NULL
) ON [PRIMARY]
GO

/****** Object:  Table [staging].[beers]    Script Date: 07/12/2023 22:51:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [staging].[beers](
	[drinkName] [varchar](255) NULL,
	[codeBar] [varchar](255) NULL,
	[type] [varchar](255) NULL,
	[alcoholUnits] [varchar](255) NULL
) ON [PRIMARY]
GO

/****** Object:  Table [staging].[visits]    Script Date: 07/12/2023 22:51:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [staging].[visits](
	[uuid] [nvarchar](255) NULL,
	[barName] [varchar](255) NULL,
	[drinks] [varchar](255) NULL,
	[drinkName] [varchar](255) NULL,
	[happyHour] [varchar](255) NULL,
	[visited] [varchar](255) NULL
) ON [PRIMARY]
GO


