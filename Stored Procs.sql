USE [arealtcs]
GO

/****** Object:  StoredProcedure [model].[LoadBars]    Script Date: 07/12/2023 22:34:15 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE OR ALTER PROCEDURE [model].[LoadBars]
AS
BEGIN

BEGIN TRY
  BEGIN TRANSACTION

    /*
	-- Possible option to merge from visists
	-- catering for "early arriving fact scenario"
	-- when bar comes in from staging.bars the address will be updated
	merge model.bar as Target
	using staging.visits as Source
	on Source.barName = Target.barName

	when not matched by Target then
	INSERT (barName, address)
	VALUES(source.barName, NULL)
	*/
	--removing duplicates
	;with stagingbar_CTE AS
	(
		SELECT distinct barname, address 
			from staging.bars
	)
	
	-- Merge from staging.bars
	merge model.bar as Target
	using stagingbar_CTE as Source
	on Source.barName = Target.barName

	-- do insert
	when not matched by Target then
	INSERT (barName, address)
	VALUES(source.barName, source.address)

	--do update
	when matched then update set
	target.barName = source.barName,
	target.address = source.address;




 COMMIT TRANSACTION

END TRY
BEGIN CATCH

    DECLARE @ErrorMessage NVARCHAR(4000),
            @ErrorSeverity INT,
            @ErrorState INT;

    SELECT @ErrorMessage = ERROR_MESSAGE(),
           @ErrorSeverity = ERROR_SEVERITY(),
           @ErrorState = ERROR_STATE();

    RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);

	IF (@@TRANCOUNT > 0)
		BEGIN
			ROLLBACK TRANSACTION
		END 

END CATCH

END

GO

/****** Object:  StoredProcedure [model].[LoadDrinkPrice]    Script Date: 07/12/2023 22:34:15 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [model].[LoadDrinkPrice]
AS
BEGIN

    SET NOCOUNT ON;

BEGIN TRY
  BEGIN TRANSACTION

	DECLARE @barId int
	       ,@drinkId int
		   ,@price decimal(18,2)
		   ,@toDate date = dateadd(d, -1, getdate())
		    

	declare drinkprice_cursor cursor for 
	select distinct
				   b.barId
				 , d.drinkId
				 , sb.price
	from staging.bars sb
	inner join model.drink d
	on sb.drinkName = d.drinkName
	inner join model.bar b
	on sb.barName = b.barName
	left join model.drinkPrice dp
	on d.drinkId = dp.drinkId
	and b.barId = dp.barId
	where (dp.drinkPriceId is null 
			or dp.price <> sb.price)
	
	open drinkprice_cursor
		fetch next from drinkprice_cursor into @barId, @drinkId, @price
		while @@fetch_status = 0 
		begin
		    -- if bar and drink exists update price 
			if exists (select 1 from model.drinkPrice where barId = @barId and drinkId = @drinkId)
			begin
				update model.drinkPrice
				set toDate = @toDate
				where barId = @barId 
				  and drinkId = @drinkId 

				insert into model.drinkPrice (barId, drinkId, price, fromDate, toDate)
				values (@barId, @drinkId, @price, getdate(), '9999-12-31')
			  end
			  else
			  begin 
				insert into model.drinkPrice (barId, drinkId, price, fromDate, toDate)
				values (@barId, @drinkId, @price, '1900-01-01', '9999-12-31')
			  end		



		fetch next from drinkprice_cursor into @barId, @drinkId, @price
		end
	close drinkprice_cursor
	deallocate drinkprice_cursor




 COMMIT TRANSACTION

END TRY
BEGIN CATCH

    DECLARE @ErrorMessage NVARCHAR(4000),
            @ErrorSeverity INT,
            @ErrorState INT;

    SELECT @ErrorMessage = ERROR_MESSAGE(),
           @ErrorSeverity = ERROR_SEVERITY(),
           @ErrorState = ERROR_STATE();

    RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);

	IF (@@TRANCOUNT > 0)
		BEGIN
			ROLLBACK TRANSACTION
		END 

END CATCH

END

 
GO

/****** Object:  StoredProcedure [model].[LoadDrinks]    Script Date: 07/12/2023 22:34:15 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [model].[LoadDrinks]
AS
BEGIN

BEGIN TRY
  BEGIN TRANSACTION


	-- cater for bar visits with no drinks
	if not exists (select * from model.drink where drinkName = 'n/a')
	begin 
		insert into model.drink (drinkName)
		values ('n/a')
	end
	
	-- Possible option to merge from visists
	-- catering for "early arriving fact scenario" where drink comes from visits file
	-- when drinkname comes in from staging.beers the type, codebar, alcoholunits will be updated
	;with visits_CTE AS
	(
		select distinct drinkName
			from staging.visits
			where drinkName is not null
	)
	merge model.drink as Target
	using visits_CTE as Source
	on Source.drinkName = Target.drinkName

	when not matched by Target then
	INSERT (drinkName, typeId, codeBar, alcoholunits)
	VALUES(source.drinkName, NULL, NULL, NULL);


	;with beers_CTE AS (
		select distinct drinkName, codeBar, dt.typeId, alcoholUnits
			from staging.beers b
			left join model.drinkType dt
			  on b.type = dt.type )
	
	-- Merge from staging.bars
	merge model.drink as Target
	using beers_CTE as Source
	on Source.drinkName = Target.drinkName

	-- do insert
	when not matched by Target then
	INSERT (drinkName, typeId, codeBar, alcoholunits)
	VALUES(source.drinkName, source.typeId, source.codeBar, source.alcoholunits)

	--do update
	when matched then update set
	target.drinkName = source.drinkName,
	target.typeId = source.typeId,
	target.codeBar = source.codeBar,
	target.alcoholunits = source.alcoholunits;




 COMMIT TRANSACTION

END TRY
BEGIN CATCH

    DECLARE @ErrorMessage NVARCHAR(4000),
            @ErrorSeverity INT,
            @ErrorState INT;

    SELECT @ErrorMessage = ERROR_MESSAGE(),
           @ErrorSeverity = ERROR_SEVERITY(),
           @ErrorState = ERROR_STATE();

    RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);

	IF (@@TRANCOUNT > 0)
		BEGIN
			ROLLBACK TRANSACTION
		END 

END CATCH

END

 
GO

/****** Object:  StoredProcedure [model].[LoadDrinkType]    Script Date: 07/12/2023 22:34:15 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE OR ALTER PROCEDURE [model].[LoadDrinkType]
AS
BEGIN

BEGIN TRY
  BEGIN TRANSACTION

   
		insert into model.drinkType (type)
		select distinct t.type
			from staging.beers t
			left join model.drinkType dt
			  on t.type = dt.type
			where dt.type is null;
			
	
 

 COMMIT TRANSACTION

END TRY
BEGIN CATCH

    DECLARE @ErrorMessage NVARCHAR(4000),
            @ErrorSeverity INT,
            @ErrorState INT;

    SELECT @ErrorMessage = ERROR_MESSAGE(),
           @ErrorSeverity = ERROR_SEVERITY(),
           @ErrorState = ERROR_STATE();

    RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);

	IF (@@TRANCOUNT > 0)
		BEGIN
			ROLLBACK TRANSACTION
		END 

END CATCH

END

GO

/****** Object:  StoredProcedure [model].[LoadVisits]    Script Date: 07/12/2023 22:34:15 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [model].[LoadVisits]
AS
BEGIN

BEGIN TRY
  BEGIN TRANSACTION

	SET NOCOUNT ON;
 
	;with visits_CTE AS
	(
		select distinct
			   b.barId
			  ,d.drinkId
			  ,v.happyHour
			  ,cast(floor(cast(replace(v.drinks, 'nan', 0) as decimal(9,2))) as int) drinks
			  ,v.visited
			  ,uuid --including uuid for uniqueness
		from staging.visits v
		inner join model.bar b
		on v.barName = b.barName
		inner join model.drink d
		on isnull(v.drinkName, 'n/a') = d.drinkName
	)
	merge model.visits as Target
	using visits_CTE as Source
	on Source.uuid = Target.uuid

	-- insert
	when not matched by Target then
	INSERT (barId, drinkId, happyHour, drinksCount, visited, uuid)
	VALUES(source.barId, source.drinkId, source.happyHour, source.drinks, source.visited, source.uuid)


	-- update
	when matched then update set
	target.barId = source.barId,
	target.drinkId = source.drinkId,
	target.happyHour = source.happyHour,
	target.drinksCount = replace(source.drinks, 'nan', 0),
	target.visited = source.visited;



 COMMIT TRANSACTION

END TRY
BEGIN CATCH

    DECLARE @ErrorMessage NVARCHAR(4000),
            @ErrorSeverity INT,
            @ErrorState INT;

    SELECT @ErrorMessage = ERROR_MESSAGE(),
           @ErrorSeverity = ERROR_SEVERITY(),
           @ErrorState = ERROR_STATE();

    RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);

	IF (@@TRANCOUNT > 0)
		BEGIN
			ROLLBACK TRANSACTION
		END 

END CATCH

END

 
GO


