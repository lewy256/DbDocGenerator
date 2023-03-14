USE[master]
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[CountShift]
(
	@idPrinter int
)
RETURNS int
AS
BEGIN
	DECLARE @result int
	DECLARE @startTime datetime;
	DECLARE @endTime datetime;

	set  @startTime=(
	SELECT        TOP (1) SpecMalfunction.StartDate
	FROM            SpecMalfunction INNER JOIN
							 Malfunction ON SpecMalfunction.idMalfunction = Malfunction.idMalfunction INNER JOIN
							 Printer ON Malfunction.idPrinter = Printer.idPrinter
	WHERE        (Malfunction.idPrinter = @idPrinter)
	ORDER BY SpecMalfunction.StartDate)

	set @endTime=(
	SELECT        TOP (1) SpecMalfunction.EndDate
	FROM            SpecMalfunction INNER JOIN
                         Malfunction ON SpecMalfunction.idMalfunction = Malfunction.idMalfunction INNER JOIN
                         Printer ON Malfunction.idPrinter = Printer.idPrinter
	WHERE         (Malfunction.idPrinter = @idPrinter)
	ORDER BY SpecMalfunction.EndDate DESC)
	
	SET @result=DATEDIFF(day, @startTime, @endTime) - (DATEDIFF(wk, @startTime, @endTime)*2)

	SET @result=@result*3
	RETURN @result

END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[ElementsOrder]
(
	@idDivison int
)
RETURNS int
AS
BEGIN
	DECLARE @printers int
	DECLARE @elementsSet int
	DECLARE @elements int
	DECLARE @result int

	set @printers=(select sum(case when [dbo].[WhatStatus](idPrinter) is null then 1 else 0 end) as DostępneDrukarki
	from Printer where idDivision=@idDivison)
	
	set @elementsSet=(
	SELECT       COUNT(SpecElementSet.idElement) AS ElementyZestawu
	FROM            SpecPrinterElementOrder INNER JOIN
							 Printer ON SpecPrinterElementOrder.idPrinter = Printer.idPrinter INNER JOIN
							 Division ON Printer.idDivision = Division.idDivision INNER JOIN
							 [Set] ON SpecPrinterElementOrder.idSet = [Set].idSet INNER JOIN
							 SpecElementSet ON [Set].idSet = SpecElementSet.idSet
	WHERE        (Printer.idDivision =@idDivison)
	GROUP BY Printer.idDivision)

	set @elements=(
	SELECT       TOP(1) COUNT(SpecPrinterElementOrder.idElement) AS Elementy
	FROM            SpecPrinterElementOrder INNER JOIN
							 Printer ON SpecPrinterElementOrder.idPrinter = Printer.idPrinter INNER JOIN
							 Division ON Printer.idDivision = Division.idDivision
	WHERE        (Printer.idDivision = @idDivison))

	if @elementsSet is null
		set @elementsSet=0
	else if @elements is null
		set @elements=0
	
	set @result= CEILING((@elementsSet+@elements)*1.0/@printers)*10
	
	RETURN @result

END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[WhatShiftEnd]
(
	@idPrinter int
)
RETURNS varchar(max)
AS
BEGIN
	declare @date datetime
	DECLARE @result varchar(max)
	declare @d datetime
	declare @h int

	set  @date=(
	SELECT     TOP(1) SpecMalfunction.EndDate
	FROM            SpecMalfunction INNER JOIN
                         Malfunction ON SpecMalfunction.idMalfunction = Malfunction.idMalfunction INNER JOIN
                         Printer ON Malfunction.idPrinter = Printer.idPrinter
	WHERE         (SpecMalfunction.idStatus = 5) AND (Malfunction.idPrinter = @idPrinter)
	ORDER BY SpecMalfunction.EndDate DESC)


	set @d = Convert(datetime, @date,102)

	set @h = datepart(hh,@d)


	if @h>=6 and @h<14
		set @result = 'zmiana 1'
	else if @h>=14 and @h<22
		set @result = 'zmiana 2'
	else 
		set @result = 'zmiana 3'

	return @result

END

GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[WhatShiftStart]
(
	@idPrinter int
)
RETURNS varchar(max)
AS
BEGIN
	declare @date datetime
	DECLARE @result varchar(max)
	declare @d datetime
	declare @h int

	set  @date=(
	SELECT     TOP(1) SpecMalfunction.StartDate
	FROM            SpecMalfunction INNER JOIN
                         Malfunction ON SpecMalfunction.idMalfunction = Malfunction.idMalfunction INNER JOIN
                         Printer ON Malfunction.idPrinter = Printer.idPrinter
	WHERE         (SpecMalfunction.idStatus = 1) AND (Malfunction.idPrinter = @idPrinter)
	ORDER BY SpecMalfunction.StartDate)


	set @d = Convert(datetime, @date,102)

	set @h = datepart(hh,@d)


	if @h>=6 and @h<14
		set @result= 'zmiana 1'
	else if @h>=14 and @h<22
		set @result = 'zmiana 2'
	else 
		set @result = 'zmiana 3'

	-- Return the result of the function
	return @result

END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[WhatStatus]
(
	@idPrinter int
)
RETURNS int
AS
BEGIN
	DECLARE @lastStatus int;

	set  @lastStatus=(
	SELECT        TOP (1) SpecMalfunction.idStatus
	FROM            SpecMalfunction INNER JOIN
							 Malfunction ON SpecMalfunction.idMalfunction = Malfunction.idMalfunction INNER JOIN
							 Printer ON Malfunction.idPrinter = Printer.idPrinter
	WHERE        (Malfunction.idPrinter = @idPrinter)
	GROUP BY SpecMalfunction.idStatus, SpecMalfunction.EndDate
	ORDER BY SpecMalfunction.EndDate DESC)

	RETURN @lastStatus

END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[WhatTime]
(
	@startDate datetime,
	@endDate datetime,
	@id int
)
RETURNS int
AS
BEGIN
	DECLARE @result int
	DECLARE @startTime datetime;
	DECLARE @endTime datetime;


	set  @startTime=(
	SELECT        TOP (1) SpecMalfunction.StartDate
	FROM            SpecMalfunction INNER JOIN
                         Malfunction ON SpecMalfunction.idMalfunction = Malfunction.idMalfunction INNER JOIN
                         Printer ON Malfunction.idPrinter = Printer.idPrinter
	WHERE        (SpecMalfunction.StartDate >= @startDate) AND (Malfunction.idPrinter = @id)
	ORDER BY SpecMalfunction.StartDate)

	set @endTime=(
	SELECT        TOP (1) SpecMalfunction.EndDate
	FROM            SpecMalfunction INNER JOIN
                         Malfunction ON SpecMalfunction.idMalfunction = Malfunction.idMalfunction INNER JOIN
                         Printer ON Malfunction.idPrinter = Printer.idPrinter
	WHERE        (SpecMalfunction.EndDate<= @endDate) AND (Malfunction.idPrinter = @id)
	ORDER BY SpecMalfunction.EndDate DESC)

	SET @result=DATEDIFF(day, @startTime, @endTime)

	RETURN @result

END

GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[WhatTime2020]
(
	@idPrinter int
)
RETURNS int
AS
BEGIN
	DECLARE @result int
	DECLARE @startTime datetime;
	DECLARE @endTime datetime;

	set  @startTime=(
	SELECT        TOP (1) SpecMalfunction.StartDate
	FROM            SpecMalfunction INNER JOIN
							 Malfunction ON SpecMalfunction.idMalfunction = Malfunction.idMalfunction INNER JOIN
							 Printer ON Malfunction.idPrinter = Printer.idPrinter
	WHERE        (YEAR(SpecMalfunction.StartDate) = 2020) AND (Malfunction.idPrinter = @idPrinter)
	ORDER BY SpecMalfunction.StartDate)

	set @endTime=(
	SELECT        TOP (1) SpecMalfunction.EndDate
	FROM            SpecMalfunction INNER JOIN
							 Malfunction ON SpecMalfunction.idMalfunction = Malfunction.idMalfunction INNER JOIN
							 Printer ON Malfunction.idPrinter = Printer.idPrinter
	WHERE        (YEAR(SpecMalfunction.EndDate) = 2020) AND (Malfunction.idPrinter = @idPrinter)
	ORDER BY SpecMalfunction.EndDate DESC)

	if @endTime is null
		set @endTime='2020-12-31 23:59:59.000'

	SET @result=DATEDIFF(day, @startTime, @endTime)  - (DATEDIFF(wk, @startTime, @endTime)*2)

	RETURN @result

END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[WhatTimeWithoutWeekends]
(
	@startDate datetime,
	@endDate datetime,
	@id int
)
RETURNS int
AS
BEGIN
	DECLARE @result int
	DECLARE @startTime datetime;
	DECLARE @endTime datetime;

	set  @startTime=(
	SELECT        TOP (1) SpecMalfunction.StartDate
	FROM            SpecMalfunction INNER JOIN
                         Malfunction ON SpecMalfunction.idMalfunction = Malfunction.idMalfunction INNER JOIN
                         Printer ON Malfunction.idPrinter = Printer.idPrinter
	WHERE        (SpecMalfunction.StartDate >= @startDate) AND (Malfunction.idPrinter = @id)
	ORDER BY SpecMalfunction.StartDate)

	set @endTime=(
	SELECT        TOP (1) SpecMalfunction.EndDate
	FROM            SpecMalfunction INNER JOIN
                         Malfunction ON SpecMalfunction.idMalfunction = Malfunction.idMalfunction INNER JOIN
                         Printer ON Malfunction.idPrinter = Printer.idPrinter
	WHERE        (SpecMalfunction.EndDate<= @endDate) AND (Malfunction.idPrinter = @id)
	ORDER BY SpecMalfunction.EndDate DESC)

	SET @result=DATEDIFF(day, @startTime, @endTime) - (DATEDIFF(wk, @startTime, @endTime)*2)

	RETURN @result

END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Country](
	[idCountry] [int] IDENTITY(1,1) NOT NULL,
	[CountryName] [nvarchar](max) NOT NULL,
 CONSTRAINT [PK_Country] PRIMARY KEY CLUSTERED 
(
	[idCountry] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Division](
	[idDivision] [int] IDENTITY(1,1) NOT NULL,
	[idCountry] [int] NOT NULL,
	[DivisionName] [nvarchar](max) NULL,
 CONSTRAINT [PK_Division] PRIMARY KEY CLUSTERED 
(
	[idDivision] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Element](
	[idElement] [int] IDENTITY(1,1) NOT NULL,
	[ElementName] [nvarchar](max) NULL,
 CONSTRAINT [PK_Element] PRIMARY KEY CLUSTERED 
(
	[idElement] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Malfunction](
	[idMalfunction] [int] IDENTITY(1,1) NOT NULL,
	[idPrinter] [int] NOT NULL,
	[MalfunctionDesc] [nvarchar](max) NULL,
 CONSTRAINT [PK_Malfunction_1] PRIMARY KEY CLUSTERED 
(
	[idMalfunction] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Order](
	[idOrder] [int] IDENTITY(1,1) NOT NULL,
	[OrderName] [nvarchar](max) NULL,
 CONSTRAINT [PK_Order] PRIMARY KEY CLUSTERED 
(
	[idOrder] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Printer](
	[idPrinter] [int] IDENTITY(1,1) NOT NULL,
	[PrinterName] [nchar](26) NOT NULL,
	[idDivision] [int] NOT NULL,
 CONSTRAINT [PK_Printer] PRIMARY KEY CLUSTERED 
(
	[idPrinter] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Set](
	[idSet] [int] IDENTITY(1,1) NOT NULL,
	[SetName] [nvarchar](max) NULL,
 CONSTRAINT [PK_Set] PRIMARY KEY CLUSTERED 
(
	[idSet] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Shift](
	[idShift] [int] IDENTITY(1,1) NOT NULL,
	[StartTime] [int] NOT NULL,
	[EndTime] [int] NOT NULL,
	[ShiftName] [nchar](10) NOT NULL,
 CONSTRAINT [PK_Shift] PRIMARY KEY CLUSTERED 
(
	[idShift] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SpecElementSet](
	[idSpecElementSet] [int] IDENTITY(1,1) NOT NULL,
	[idElement] [int] NOT NULL,
	[idSet] [int] NOT NULL,
 CONSTRAINT [PK_SpecElementSet] PRIMARY KEY CLUSTERED 
(
	[idSpecElementSet] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SpecMalfunction](
	[idSpecMalfunction] [int] IDENTITY(1,1) NOT NULL,
	[idMalfunction] [int] NOT NULL,
	[idStatus] [int] NOT NULL,
	[StartDate] [datetime] NULL,
	[EndDate] [datetime] NULL,
 CONSTRAINT [PK_MalfunctionStatus] PRIMARY KEY CLUSTERED 
(
	[idSpecMalfunction] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SpecPrinterElementOrder](
	[idSpecPrinterElementOrder] [int] IDENTITY(1,1) NOT NULL,
	[idPrinter] [int] NOT NULL,
	[idElement] [int] NULL,
	[idOrder] [int] NOT NULL,
	[idSet] [int] NULL,
 CONSTRAINT [PK_SpecPrinterElementOrder] PRIMARY KEY CLUSTERED 
(
	[idSpecPrinterElementOrder] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Status](
	[idStatus] [int] IDENTITY(1,1) NOT NULL,
	[StatusDesc] [nvarchar](max) NOT NULL,
 CONSTRAINT [PK_Status_1] PRIMARY KEY CLUSTERED 
(
	[idStatus] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET IDENTITY_INSERT [dbo].[Country] ON 

INSERT [dbo].[Country] ([idCountry], [CountryName]) VALUES (1, N'Poland')
INSERT [dbo].[Country] ([idCountry], [CountryName]) VALUES (6, N'Jamaica')
INSERT [dbo].[Country] ([idCountry], [CountryName]) VALUES (7, N'Guatemala')
INSERT [dbo].[Country] ([idCountry], [CountryName]) VALUES (10, N'New Caledonia')
INSERT [dbo].[Country] ([idCountry], [CountryName]) VALUES (12, N'Eire')
INSERT [dbo].[Country] ([idCountry], [CountryName]) VALUES (13, N'Ghana')
INSERT [dbo].[Country] ([idCountry], [CountryName]) VALUES (14, N'Yemen')
INSERT [dbo].[Country] ([idCountry], [CountryName]) VALUES (15, N'Oman')
INSERT [dbo].[Country] ([idCountry], [CountryName]) VALUES (16, N'Nicaragua')
INSERT [dbo].[Country] ([idCountry], [CountryName]) VALUES (17, N'Finland')
INSERT [dbo].[Country] ([idCountry], [CountryName]) VALUES (18, N'Mozambique')
INSERT [dbo].[Country] ([idCountry], [CountryName]) VALUES (19, N'Peru')
INSERT [dbo].[Country] ([idCountry], [CountryName]) VALUES (20, N'Paraguay')
SET IDENTITY_INSERT [dbo].[Country] OFF
GO
SET IDENTITY_INSERT [dbo].[Division] ON 

INSERT [dbo].[Division] ([idDivision], [idCountry], [DivisionName]) VALUES (1, 15, N'OmanDivision')
INSERT [dbo].[Division] ([idDivision], [idCountry], [DivisionName]) VALUES (2, 17, N'FinlandDivision')
INSERT [dbo].[Division] ([idDivision], [idCountry], [DivisionName]) VALUES (3, 16, N'NicaraguaDivision')
INSERT [dbo].[Division] ([idDivision], [idCountry], [DivisionName]) VALUES (4, 12, N'EireDivision')
INSERT [dbo].[Division] ([idDivision], [idCountry], [DivisionName]) VALUES (6, 12, N'EireDivision2')
INSERT [dbo].[Division] ([idDivision], [idCountry], [DivisionName]) VALUES (7, 19, N'PeruDivision')
INSERT [dbo].[Division] ([idDivision], [idCountry], [DivisionName]) VALUES (10, 6, N'JamaicaDivision')
INSERT [dbo].[Division] ([idDivision], [idCountry], [DivisionName]) VALUES (12, 10, N'NewCaledoniaDivision')
INSERT [dbo].[Division] ([idDivision], [idCountry], [DivisionName]) VALUES (13, 13, N'GhanaDivision')
INSERT [dbo].[Division] ([idDivision], [idCountry], [DivisionName]) VALUES (14, 10, N'New CaledoniaDivision')
INSERT [dbo].[Division] ([idDivision], [idCountry], [DivisionName]) VALUES (15, 20, N'ParaguayDivision')
INSERT [dbo].[Division] ([idDivision], [idCountry], [DivisionName]) VALUES (16, 1, N'PolandDivision')
INSERT [dbo].[Division] ([idDivision], [idCountry], [DivisionName]) VALUES (17, 18, N'MozambiqueDivision')
INSERT [dbo].[Division] ([idDivision], [idCountry], [DivisionName]) VALUES (18, 20, N'ParaguayDivision2')
INSERT [dbo].[Division] ([idDivision], [idCountry], [DivisionName]) VALUES (19, 14, N'YemenDivision2')
INSERT [dbo].[Division] ([idDivision], [idCountry], [DivisionName]) VALUES (20, 7, N'GuatemalaDivision')
SET IDENTITY_INSERT [dbo].[Division] OFF
GO
SET IDENTITY_INSERT [dbo].[Element] ON 

INSERT [dbo].[Element] ([idElement], [ElementName]) VALUES (1, N'Element1')
INSERT [dbo].[Element] ([idElement], [ElementName]) VALUES (3, N'Element3')
INSERT [dbo].[Element] ([idElement], [ElementName]) VALUES (4, N'Element4')
INSERT [dbo].[Element] ([idElement], [ElementName]) VALUES (5, N'Element5')
INSERT [dbo].[Element] ([idElement], [ElementName]) VALUES (6, N'Element6')
INSERT [dbo].[Element] ([idElement], [ElementName]) VALUES (7, N'Element7')
INSERT [dbo].[Element] ([idElement], [ElementName]) VALUES (11, N'Element11')
INSERT [dbo].[Element] ([idElement], [ElementName]) VALUES (12, N'Element12')
INSERT [dbo].[Element] ([idElement], [ElementName]) VALUES (13, N'Element13')
INSERT [dbo].[Element] ([idElement], [ElementName]) VALUES (14, N'Element14')
INSERT [dbo].[Element] ([idElement], [ElementName]) VALUES (15, N'Element15')
INSERT [dbo].[Element] ([idElement], [ElementName]) VALUES (16, N'Element16')
INSERT [dbo].[Element] ([idElement], [ElementName]) VALUES (17, N'Element17')
INSERT [dbo].[Element] ([idElement], [ElementName]) VALUES (18, N'Element18')
INSERT [dbo].[Element] ([idElement], [ElementName]) VALUES (19, N'Element19')
INSERT [dbo].[Element] ([idElement], [ElementName]) VALUES (20, N'Element20')
SET IDENTITY_INSERT [dbo].[Element] OFF
GO
SET IDENTITY_INSERT [dbo].[Malfunction] ON 

INSERT [dbo].[Malfunction] ([idMalfunction], [idPrinter], [MalfunctionDesc]) VALUES (1, 15, N'quad dolorum quoque novum quo, quoque fecundio, vobis in Pro vantis. quartu Pro et et cognitio, nomen si in eudis novum quo,')
INSERT [dbo].[Malfunction] ([idMalfunction], [idPrinter], [MalfunctionDesc]) VALUES (2, 15, N'bono fecit, si trepicandor Versus vobis pars estis quo e regit, Et quantare et gravis glavans vantis. apparens egreddior volcans non')
INSERT [dbo].[Malfunction] ([idMalfunction], [idPrinter], [MalfunctionDesc]) VALUES (5, 8, N'vobis parte et quorum vobis et quorum nomen e essit. homo, quantare trepicandor quo, venit. quo, pars')
INSERT [dbo].[Malfunction] ([idMalfunction], [idPrinter], [MalfunctionDesc]) VALUES (8, 6, N'gravis bono si quo Versus quorum gravum linguens plorum et delerium. bono gravum non quoque regit, Et')
INSERT [dbo].[Malfunction] ([idMalfunction], [idPrinter], [MalfunctionDesc]) VALUES (9, 5, N'vobis parte et quorum vobis et quorum nomen e essit. homo, quantare trepicandor quo, venit. quo, pars')
SET IDENTITY_INSERT [dbo].[Malfunction] OFF
GO
SET IDENTITY_INSERT [dbo].[Order] ON 

INSERT [dbo].[Order] ([idOrder], [OrderName]) VALUES (1, N'Zamówienie1')
INSERT [dbo].[Order] ([idOrder], [OrderName]) VALUES (5, N'Zamówienie5')
INSERT [dbo].[Order] ([idOrder], [OrderName]) VALUES (6, N'Zamówienie6')
INSERT [dbo].[Order] ([idOrder], [OrderName]) VALUES (7, N'Zamówienie7')
INSERT [dbo].[Order] ([idOrder], [OrderName]) VALUES (9, N'Zamówienie9')
INSERT [dbo].[Order] ([idOrder], [OrderName]) VALUES (10, N'Zamówienie10')
INSERT [dbo].[Order] ([idOrder], [OrderName]) VALUES (12, N'Zamówienie12')
INSERT [dbo].[Order] ([idOrder], [OrderName]) VALUES (13, N'Zamówienie13')
INSERT [dbo].[Order] ([idOrder], [OrderName]) VALUES (14, N'Zamówienie14')
INSERT [dbo].[Order] ([idOrder], [OrderName]) VALUES (15, N'Zamówienie15')
INSERT [dbo].[Order] ([idOrder], [OrderName]) VALUES (16, N'Zamówienie16')
INSERT [dbo].[Order] ([idOrder], [OrderName]) VALUES (17, N'Zamówienie17')
INSERT [dbo].[Order] ([idOrder], [OrderName]) VALUES (18, N'Zamówienie18')
INSERT [dbo].[Order] ([idOrder], [OrderName]) VALUES (19, N'Zamówienie19')
INSERT [dbo].[Order] ([idOrder], [OrderName]) VALUES (20, N'Zamówienie20')
SET IDENTITY_INSERT [dbo].[Order] OFF
GO
SET IDENTITY_INSERT [dbo].[Printer] ON 

INSERT [dbo].[Printer] ([idPrinter], [PrinterName], [idDivision]) VALUES (1, N'42527455605065250312240527', 15)
INSERT [dbo].[Printer] ([idPrinter], [PrinterName], [idDivision]) VALUES (2, N'03735376033684078566403737', 17)
INSERT [dbo].[Printer] ([idPrinter], [PrinterName], [idDivision]) VALUES (3, N'89209975297969811663716106', 16)
INSERT [dbo].[Printer] ([idPrinter], [PrinterName], [idDivision]) VALUES (4, N'29990889773361988169758107', 12)
INSERT [dbo].[Printer] ([idPrinter], [PrinterName], [idDivision]) VALUES (5, N'77219384529718904839182794', 12)
INSERT [dbo].[Printer] ([idPrinter], [PrinterName], [idDivision]) VALUES (6, N'36179230246397736944075437', 12)
INSERT [dbo].[Printer] ([idPrinter], [PrinterName], [idDivision]) VALUES (7, N'38441565744947876753145685', 19)
INSERT [dbo].[Printer] ([idPrinter], [PrinterName], [idDivision]) VALUES (8, N'75164250170573299190610868', 12)
INSERT [dbo].[Printer] ([idPrinter], [PrinterName], [idDivision]) VALUES (9, N'69386568067978779527994648', 12)
INSERT [dbo].[Printer] ([idPrinter], [PrinterName], [idDivision]) VALUES (10, N'25420689179301423112194023', 6)
INSERT [dbo].[Printer] ([idPrinter], [PrinterName], [idDivision]) VALUES (11, N'36474804353738969022557142', 6)
INSERT [dbo].[Printer] ([idPrinter], [PrinterName], [idDivision]) VALUES (12, N'42149655269559716038312400', 10)
INSERT [dbo].[Printer] ([idPrinter], [PrinterName], [idDivision]) VALUES (13, N'58932116121307379956283000', 13)
INSERT [dbo].[Printer] ([idPrinter], [PrinterName], [idDivision]) VALUES (14, N'22964940723733369563094344', 10)
INSERT [dbo].[Printer] ([idPrinter], [PrinterName], [idDivision]) VALUES (15, N'96492178315645664621381444', 20)
INSERT [dbo].[Printer] ([idPrinter], [PrinterName], [idDivision]) VALUES (16, N'33761955423056405382743062', 1)
INSERT [dbo].[Printer] ([idPrinter], [PrinterName], [idDivision]) VALUES (17, N'00404834554378023056588605', 18)
INSERT [dbo].[Printer] ([idPrinter], [PrinterName], [idDivision]) VALUES (18, N'08979965591821184091371090', 20)
INSERT [dbo].[Printer] ([idPrinter], [PrinterName], [idDivision]) VALUES (19, N'71279863568440343113449360', 14)
INSERT [dbo].[Printer] ([idPrinter], [PrinterName], [idDivision]) VALUES (20, N'93787849331106852665092788', 7)
SET IDENTITY_INSERT [dbo].[Printer] OFF
GO
SET IDENTITY_INSERT [dbo].[Set] ON 

INSERT [dbo].[Set] ([idSet], [SetName]) VALUES (1, N'Zestaw1')
INSERT [dbo].[Set] ([idSet], [SetName]) VALUES (9, N'Zestaw9')
INSERT [dbo].[Set] ([idSet], [SetName]) VALUES (10, N'Zestaw10')
INSERT [dbo].[Set] ([idSet], [SetName]) VALUES (11, N'Zestaw11')
INSERT [dbo].[Set] ([idSet], [SetName]) VALUES (14, N'Zestaw14')
INSERT [dbo].[Set] ([idSet], [SetName]) VALUES (17, N'Zestaw17')
SET IDENTITY_INSERT [dbo].[Set] OFF
GO
SET IDENTITY_INSERT [dbo].[Shift] ON 

INSERT [dbo].[Shift] ([idShift], [StartTime], [EndTime], [ShiftName]) VALUES (1, 6, 14, N'I zmiana  ')
INSERT [dbo].[Shift] ([idShift], [StartTime], [EndTime], [ShiftName]) VALUES (2, 14, 22, N'II zmiana ')
INSERT [dbo].[Shift] ([idShift], [StartTime], [EndTime], [ShiftName]) VALUES (3, 22, 6, N'III zmiana')
SET IDENTITY_INSERT [dbo].[Shift] OFF
GO
SET IDENTITY_INSERT [dbo].[SpecElementSet] ON 

INSERT [dbo].[SpecElementSet] ([idSpecElementSet], [idElement], [idSet]) VALUES (2, 1, 17)
INSERT [dbo].[SpecElementSet] ([idSpecElementSet], [idElement], [idSet]) VALUES (8, 5, 9)
INSERT [dbo].[SpecElementSet] ([idSpecElementSet], [idElement], [idSet]) VALUES (12, 3, 10)
INSERT [dbo].[SpecElementSet] ([idSpecElementSet], [idElement], [idSet]) VALUES (14, 4, 10)
INSERT [dbo].[SpecElementSet] ([idSpecElementSet], [idElement], [idSet]) VALUES (16, 5, 1)
INSERT [dbo].[SpecElementSet] ([idSpecElementSet], [idElement], [idSet]) VALUES (19, 6, 14)
INSERT [dbo].[SpecElementSet] ([idSpecElementSet], [idElement], [idSet]) VALUES (20, 7, 11)
SET IDENTITY_INSERT [dbo].[SpecElementSet] OFF
GO
SET IDENTITY_INSERT [dbo].[SpecMalfunction] ON 

INSERT [dbo].[SpecMalfunction] ([idSpecMalfunction], [idMalfunction], [idStatus], [StartDate], [EndDate]) VALUES (1, 1, 1, CAST(N'2020-03-16T06:35:48.000' AS DateTime), CAST(N'2020-03-17T06:35:48.000' AS DateTime))
INSERT [dbo].[SpecMalfunction] ([idSpecMalfunction], [idMalfunction], [idStatus], [StartDate], [EndDate]) VALUES (2, 1, 2, CAST(N'2020-06-01T14:28:05.000' AS DateTime), CAST(N'2020-06-01T16:28:05.000' AS DateTime))
INSERT [dbo].[SpecMalfunction] ([idSpecMalfunction], [idMalfunction], [idStatus], [StartDate], [EndDate]) VALUES (3, 1, 3, CAST(N'2020-07-10T13:59:42.180' AS DateTime), CAST(N'2020-07-13T13:59:42.180' AS DateTime))
INSERT [dbo].[SpecMalfunction] ([idSpecMalfunction], [idMalfunction], [idStatus], [StartDate], [EndDate]) VALUES (4, 1, 4, CAST(N'2020-07-13T00:25:38.000' AS DateTime), CAST(N'2020-07-14T00:25:38.000' AS DateTime))
INSERT [dbo].[SpecMalfunction] ([idSpecMalfunction], [idMalfunction], [idStatus], [StartDate], [EndDate]) VALUES (5, 1, 5, CAST(N'2020-07-15T13:59:42.000' AS DateTime), CAST(N'2020-07-16T13:59:42.000' AS DateTime))
INSERT [dbo].[SpecMalfunction] ([idSpecMalfunction], [idMalfunction], [idStatus], [StartDate], [EndDate]) VALUES (7, 2, 1, CAST(N'2020-04-16T06:35:48.000' AS DateTime), CAST(N'2020-04-17T06:35:48.000' AS DateTime))
INSERT [dbo].[SpecMalfunction] ([idSpecMalfunction], [idMalfunction], [idStatus], [StartDate], [EndDate]) VALUES (8, 2, 2, CAST(N'2020-05-28T07:53:22.000' AS DateTime), CAST(N'2020-05-29T07:53:22.000' AS DateTime))
INSERT [dbo].[SpecMalfunction] ([idSpecMalfunction], [idMalfunction], [idStatus], [StartDate], [EndDate]) VALUES (9, 2, 3, CAST(N'2021-06-03T02:47:58.000' AS DateTime), CAST(N'2021-06-03T02:47:58.000' AS DateTime))
INSERT [dbo].[SpecMalfunction] ([idSpecMalfunction], [idMalfunction], [idStatus], [StartDate], [EndDate]) VALUES (10, 2, 4, CAST(N'2021-06-21T03:51:26.000' AS DateTime), CAST(N'2021-06-22T03:51:26.000' AS DateTime))
INSERT [dbo].[SpecMalfunction] ([idSpecMalfunction], [idMalfunction], [idStatus], [StartDate], [EndDate]) VALUES (11, 2, 5, CAST(N'2021-06-04T02:47:58.000' AS DateTime), CAST(N'2021-06-04T02:47:58.000' AS DateTime))
INSERT [dbo].[SpecMalfunction] ([idSpecMalfunction], [idMalfunction], [idStatus], [StartDate], [EndDate]) VALUES (13, 5, 1, CAST(N'2020-06-25T03:17:30.000' AS DateTime), CAST(N'2021-06-28T03:17:30.000' AS DateTime))
INSERT [dbo].[SpecMalfunction] ([idSpecMalfunction], [idMalfunction], [idStatus], [StartDate], [EndDate]) VALUES (14, 5, 2, CAST(N'2021-08-18T08:24:12.000' AS DateTime), CAST(N'2021-08-19T08:24:12.000' AS DateTime))
INSERT [dbo].[SpecMalfunction] ([idSpecMalfunction], [idMalfunction], [idStatus], [StartDate], [EndDate]) VALUES (15, 5, 3, CAST(N'2021-09-23T08:30:37.000' AS DateTime), CAST(N'2021-09-24T08:30:37.000' AS DateTime))
INSERT [dbo].[SpecMalfunction] ([idSpecMalfunction], [idMalfunction], [idStatus], [StartDate], [EndDate]) VALUES (16, 5, 4, CAST(N'2021-10-25T10:49:39.000' AS DateTime), CAST(N'2021-10-26T10:49:39.000' AS DateTime))
INSERT [dbo].[SpecMalfunction] ([idSpecMalfunction], [idMalfunction], [idStatus], [StartDate], [EndDate]) VALUES (17, 5, 5, CAST(N'2021-11-03T10:34:16.000' AS DateTime), CAST(N'2021-11-04T10:34:16.000' AS DateTime))
INSERT [dbo].[SpecMalfunction] ([idSpecMalfunction], [idMalfunction], [idStatus], [StartDate], [EndDate]) VALUES (19, 8, 1, CAST(N'2020-12-24T08:20:04.000' AS DateTime), CAST(N'2021-12-27T08:20:04.000' AS DateTime))
INSERT [dbo].[SpecMalfunction] ([idSpecMalfunction], [idMalfunction], [idStatus], [StartDate], [EndDate]) VALUES (20, 8, 2, CAST(N'2022-02-18T18:23:18.000' AS DateTime), CAST(N'2022-02-25T18:23:18.000' AS DateTime))
INSERT [dbo].[SpecMalfunction] ([idSpecMalfunction], [idMalfunction], [idStatus], [StartDate], [EndDate]) VALUES (21, 9, 1, CAST(N'2020-07-15T13:59:42.000' AS DateTime), NULL)
SET IDENTITY_INSERT [dbo].[SpecMalfunction] OFF
GO
SET IDENTITY_INSERT [dbo].[SpecPrinterElementOrder] ON 

INSERT [dbo].[SpecPrinterElementOrder] ([idSpecPrinterElementOrder], [idPrinter], [idElement], [idOrder], [idSet]) VALUES (1, 15, 17, 15, NULL)
INSERT [dbo].[SpecPrinterElementOrder] ([idSpecPrinterElementOrder], [idPrinter], [idElement], [idOrder], [idSet]) VALUES (2, 18, 12, 17, NULL)
INSERT [dbo].[SpecPrinterElementOrder] ([idSpecPrinterElementOrder], [idPrinter], [idElement], [idOrder], [idSet]) VALUES (3, 6, 12, 16, NULL)
INSERT [dbo].[SpecPrinterElementOrder] ([idSpecPrinterElementOrder], [idPrinter], [idElement], [idOrder], [idSet]) VALUES (4, 6, NULL, 19, 9)
INSERT [dbo].[SpecPrinterElementOrder] ([idSpecPrinterElementOrder], [idPrinter], [idElement], [idOrder], [idSet]) VALUES (5, 10, 12, 5, NULL)
INSERT [dbo].[SpecPrinterElementOrder] ([idSpecPrinterElementOrder], [idPrinter], [idElement], [idOrder], [idSet]) VALUES (6, 10, 15, 12, NULL)
INSERT [dbo].[SpecPrinterElementOrder] ([idSpecPrinterElementOrder], [idPrinter], [idElement], [idOrder], [idSet]) VALUES (7, 10, NULL, 12, 10)
INSERT [dbo].[SpecPrinterElementOrder] ([idSpecPrinterElementOrder], [idPrinter], [idElement], [idOrder], [idSet]) VALUES (8, 3, 14, 9, NULL)
INSERT [dbo].[SpecPrinterElementOrder] ([idSpecPrinterElementOrder], [idPrinter], [idElement], [idOrder], [idSet]) VALUES (9, 20, 13, 20, NULL)
INSERT [dbo].[SpecPrinterElementOrder] ([idSpecPrinterElementOrder], [idPrinter], [idElement], [idOrder], [idSet]) VALUES (10, 1, 12, 6, NULL)
INSERT [dbo].[SpecPrinterElementOrder] ([idSpecPrinterElementOrder], [idPrinter], [idElement], [idOrder], [idSet]) VALUES (11, 4, NULL, 6, 17)
INSERT [dbo].[SpecPrinterElementOrder] ([idSpecPrinterElementOrder], [idPrinter], [idElement], [idOrder], [idSet]) VALUES (12, 8, NULL, 10, 1)
INSERT [dbo].[SpecPrinterElementOrder] ([idSpecPrinterElementOrder], [idPrinter], [idElement], [idOrder], [idSet]) VALUES (13, 9, NULL, 13, 11)
INSERT [dbo].[SpecPrinterElementOrder] ([idSpecPrinterElementOrder], [idPrinter], [idElement], [idOrder], [idSet]) VALUES (14, 13, NULL, 10, 14)
INSERT [dbo].[SpecPrinterElementOrder] ([idSpecPrinterElementOrder], [idPrinter], [idElement], [idOrder], [idSet]) VALUES (15, 13, 11, 20, NULL)
INSERT [dbo].[SpecPrinterElementOrder] ([idSpecPrinterElementOrder], [idPrinter], [idElement], [idOrder], [idSet]) VALUES (16, 7, 18, 1, NULL)
INSERT [dbo].[SpecPrinterElementOrder] ([idSpecPrinterElementOrder], [idPrinter], [idElement], [idOrder], [idSet]) VALUES (17, 17, 17, 18, NULL)
INSERT [dbo].[SpecPrinterElementOrder] ([idSpecPrinterElementOrder], [idPrinter], [idElement], [idOrder], [idSet]) VALUES (18, 12, 16, 20, NULL)
INSERT [dbo].[SpecPrinterElementOrder] ([idSpecPrinterElementOrder], [idPrinter], [idElement], [idOrder], [idSet]) VALUES (19, 11, 20, 14, NULL)
INSERT [dbo].[SpecPrinterElementOrder] ([idSpecPrinterElementOrder], [idPrinter], [idElement], [idOrder], [idSet]) VALUES (20, 7, 19, 7, NULL)
SET IDENTITY_INSERT [dbo].[SpecPrinterElementOrder] OFF
GO
SET IDENTITY_INSERT [dbo].[Status] ON 

INSERT [dbo].[Status] ([idStatus], [StatusDesc]) VALUES (1, N'1 etap – w  momencie awarii i przestoju przekazywana jest informacja do centrali')
INSERT [dbo].[Status] ([idStatus], [StatusDesc]) VALUES (2, N'2 etap to diagnoza przyczyny awarii,')
INSERT [dbo].[Status] ([idStatus], [StatusDesc]) VALUES (3, N'3 etap to rozpoczęcie naprawy')
INSERT [dbo].[Status] ([idStatus], [StatusDesc]) VALUES (4, N'4 testy ')
INSERT [dbo].[Status] ([idStatus], [StatusDesc]) VALUES (5, N'5 przywrócenie do etapu działania produkcyjnego')
INSERT [dbo].[Status] ([idStatus], [StatusDesc]) VALUES (6, N'6 urządzenia nie udaje się naprawić podlega kasacji ')
INSERT [dbo].[Status] ([idStatus], [StatusDesc]) VALUES (7, N'0 – urządzenie działa poprawnie')
SET IDENTITY_INSERT [dbo].[Status] OFF
GO
ALTER TABLE [dbo].[Division]  WITH CHECK ADD  CONSTRAINT [FK_Division_Country] FOREIGN KEY([idCountry])
REFERENCES [dbo].[Country] ([idCountry])
GO
ALTER TABLE [dbo].[Division] CHECK CONSTRAINT [FK_Division_Country]
GO
ALTER TABLE [dbo].[Malfunction]  WITH CHECK ADD  CONSTRAINT [FK_Malfunction_Printer1] FOREIGN KEY([idPrinter])
REFERENCES [dbo].[Printer] ([idPrinter])
GO
ALTER TABLE [dbo].[Malfunction] CHECK CONSTRAINT [FK_Malfunction_Printer1]
GO
ALTER TABLE [dbo].[Printer]  WITH CHECK ADD  CONSTRAINT [FK_Printer_Division] FOREIGN KEY([idDivision])
REFERENCES [dbo].[Division] ([idDivision])
GO
ALTER TABLE [dbo].[Printer] CHECK CONSTRAINT [FK_Printer_Division]
GO
ALTER TABLE [dbo].[SpecElementSet]  WITH CHECK ADD  CONSTRAINT [FK_SpecElementSet_Element] FOREIGN KEY([idElement])
REFERENCES [dbo].[Element] ([idElement])
GO
ALTER TABLE [dbo].[SpecElementSet] CHECK CONSTRAINT [FK_SpecElementSet_Element]
GO
ALTER TABLE [dbo].[SpecElementSet]  WITH CHECK ADD  CONSTRAINT [FK_SpecElementSet_Set] FOREIGN KEY([idSet])
REFERENCES [dbo].[Set] ([idSet])
GO
ALTER TABLE [dbo].[SpecElementSet] CHECK CONSTRAINT [FK_SpecElementSet_Set]
GO
ALTER TABLE [dbo].[SpecMalfunction]  WITH CHECK ADD  CONSTRAINT [FK_MalfunctionStatus_Malfunction] FOREIGN KEY([idMalfunction])
REFERENCES [dbo].[Malfunction] ([idMalfunction])
GO
ALTER TABLE [dbo].[SpecMalfunction] CHECK CONSTRAINT [FK_MalfunctionStatus_Malfunction]
GO
ALTER TABLE [dbo].[SpecMalfunction]  WITH CHECK ADD  CONSTRAINT [FK_MalfunctionStatus_Status] FOREIGN KEY([idStatus])
REFERENCES [dbo].[Status] ([idStatus])
GO
ALTER TABLE [dbo].[SpecMalfunction] CHECK CONSTRAINT [FK_MalfunctionStatus_Status]
GO
ALTER TABLE [dbo].[SpecPrinterElementOrder]  WITH CHECK ADD  CONSTRAINT [FK_SpecPrinterElementOrder_Element] FOREIGN KEY([idElement])
REFERENCES [dbo].[Element] ([idElement])
GO
ALTER TABLE [dbo].[SpecPrinterElementOrder] CHECK CONSTRAINT [FK_SpecPrinterElementOrder_Element]
GO
ALTER TABLE [dbo].[SpecPrinterElementOrder]  WITH CHECK ADD  CONSTRAINT [FK_SpecPrinterElementOrder_Order] FOREIGN KEY([idOrder])
REFERENCES [dbo].[Order] ([idOrder])
GO
ALTER TABLE [dbo].[SpecPrinterElementOrder] CHECK CONSTRAINT [FK_SpecPrinterElementOrder_Order]
GO
ALTER TABLE [dbo].[SpecPrinterElementOrder]  WITH CHECK ADD  CONSTRAINT [FK_SpecPrinterElementOrder_Printer] FOREIGN KEY([idPrinter])
REFERENCES [dbo].[Printer] ([idPrinter])
GO
ALTER TABLE [dbo].[SpecPrinterElementOrder] CHECK CONSTRAINT [FK_SpecPrinterElementOrder_Printer]
GO
ALTER TABLE [dbo].[SpecPrinterElementOrder]  WITH CHECK ADD  CONSTRAINT [FK_SpecPrinterElementOrder_Set] FOREIGN KEY([idSet])
REFERENCES [dbo].[Set] ([idSet])
GO
ALTER TABLE [dbo].[SpecPrinterElementOrder] CHECK CONSTRAINT [FK_SpecPrinterElementOrder_Set]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [dbo].[CheckOrderTrigger]
   ON  [dbo].[SpecMalfunction]
   AFTER INSERT
AS 
BEGIN	
	DECLARE @countTime int
	DECLARE @idStatus int
	DECLARE @idDivison int

	
	set @idStatus=(
	SELECT        TOP (1) SpecMalfunction.idStatus
	FROM            SpecMalfunction INNER JOIN
                         Malfunction ON SpecMalfunction.idMalfunction = Malfunction.idMalfunction INNER JOIN
                         Printer ON Malfunction.idPrinter = Printer.idPrinter
	ORDER BY SpecMalfunction.idSpecMalfunction DESC)

	if @idStatus=1
		set @idDivison=(
		SELECT        TOP (1) Printer.idDivision
		FROM            SpecMalfunction INNER JOIN
							 Malfunction ON SpecMalfunction.idMalfunction = Malfunction.idMalfunction INNER JOIN
							 Printer ON Malfunction.idPrinter = Printer.idPrinter
		ORDER BY SpecMalfunction.idSpecMalfunction DESC)	

	SET @countTime=(select (36*60-[dbo].[ElementsOrder](@idDivison))/10 as MożliweElementyZamówienia)

	if @countTime<0 
		 EXEC msdb.dbo.sp_send_dbmail
		 @profile_name = 'Notifications',
		 @recipients = 'jk427202@gmail.com',
		 @body = 'Wystąpiła awaria urządzenia. Zrealizowanie zamówienia w terminie nie jest możliwe.',
		 @subject = 'Awaria urządzenia';
	
	
END
GO
ALTER TABLE [dbo].[SpecMalfunction] ENABLE TRIGGER [CheckOrderTrigger]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Country', @level2type=N'COLUMN',@level2name=N'idCountry'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nazwa państwa' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Country', @level2type=N'COLUMN',@level2name=N'CountryName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabela zawiera państwa' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Country'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Division', @level2type=N'COLUMN',@level2name=N'idDivision'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nazwa oddziału' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Division', @level2type=N'COLUMN',@level2name=N'DivisionName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabela przechowuje oddziały' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Division'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Relacja jeden do wielu pomiędzy tabelą Country oraz Division. Każdy oddział należy do 1 państwa, a każde państwo może mieć wiele oddziałów.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Division', @level2type=N'CONSTRAINT',@level2name=N'FK_Division_Country'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nazwa elementu' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Element', @level2type=N'COLUMN',@level2name=N'ElementName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Elementy do wydrukowania' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Element'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Malfunction', @level2type=N'COLUMN',@level2name=N'idMalfunction'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Opis awarii' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Malfunction', @level2type=N'COLUMN',@level2name=N'MalfunctionDesc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabela zawierająca awarie' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Malfunction'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Relacja jeden do wielu pomiędzy tabelą Printer oraz Malfunction. Każda awaria należy do 1 drukarki, a każda drukarka może mieć wiele awarii.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Malfunction', @level2type=N'CONSTRAINT',@level2name=N'FK_Malfunction_Printer1'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nazwa zamówienia' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Order', @level2type=N'COLUMN',@level2name=N'OrderName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabela przechwoująca zamówienia' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Order'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Printer', @level2type=N'COLUMN',@level2name=N'idPrinter'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'26 znakowy identyfikator' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Printer', @level2type=N'COLUMN',@level2name=N'PrinterName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabela zawiera drukarki' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Printer'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Relacja jeden do wielu pomiędzy tabelą Printer oraz Division. Każda drukarka należy do 1 odziału, a każdy odział może mieć wiele drukarek.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Printer', @level2type=N'CONSTRAINT',@level2name=N'FK_Printer_Division'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nazwa zestawu' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Set', @level2type=N'COLUMN',@level2name=N'SetName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Zestawy do wydrukowania' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Set'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Klucz główny' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Shift', @level2type=N'COLUMN',@level2name=N'idShift'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Godzina rozpoczęcia zmiany' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Shift', @level2type=N'COLUMN',@level2name=N'StartTime'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Godzina zakończenia zmiany' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Shift', @level2type=N'COLUMN',@level2name=N'EndTime'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Numer zmiany' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Shift', @level2type=N'COLUMN',@level2name=N'ShiftName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabela zawierająca zmiany' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Shift'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabela łącząca tabelę Element i Set. Pokazuje elementy, które zawierają zestawy.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SpecElementSet'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Relacja jeden do wielu pomiędzy tabelami Element i SpecElementSet. Pojedynczemu rekordowi z tabeli Element jest przyporządkowany jeden lub wiele rekordów z tabeli SpecElementSet, natomiast pojedynczemu rekordowi z tabeli SpecElementSet jest przyporządkowany dokładnie jeden rekord z tabeli Element. ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SpecElementSet', @level2type=N'CONSTRAINT',@level2name=N'FK_SpecElementSet_Element'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Relacja jeden do wielu pomiędzy tabelami Set i SpecElementSet. Pojedynczemu rekordowi z tabeli Set jest przyporządkowany jeden lub wiele rekordów z tabeli SpecElementSet, natomiast pojedynczemu rekordowi z tabeli SpecElementSet jest przyporządkowany dokładnie jeden rekord z tabeli Set. ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SpecElementSet', @level2type=N'CONSTRAINT',@level2name=N'FK_SpecElementSet_Set'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SpecMalfunction', @level2type=N'COLUMN',@level2name=N'idSpecMalfunction'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Czas modyfikacji statusu.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SpecMalfunction', @level2type=N'COLUMN',@level2name=N'EndDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabela łącząca tabele Malfunction i Status oraz  zawierająca daty awarii' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SpecMalfunction'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Relacja jeden do wielu pomiędzy tabelami Malfunction i SpecMalfunction. Pojedynczemu rekordowi z tabeli Malfunction jest przyporządkowany jeden lub wiele rekordów z tabeli SpecMalfunction, natomiast pojedynczemu rekordowi z tabeli SpecMalfunction jest przyporządkowany dokładnie jeden rekord z tabeli Malfunction. ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SpecMalfunction', @level2type=N'CONSTRAINT',@level2name=N'FK_MalfunctionStatus_Malfunction'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Relacja jeden do wielu pomiędzy tabelami Status i SpecMalfunction. Pojedynczemu rekordowi z tabeli Status jest przyporządkowany jeden lub wiele rekordów z tabeli SpecMalfunction, natomiast pojedynczemu rekordowi z tabeli SpecMalfunction jest przyporządkowany dokładnie jeden rekord z tabeli Status. ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SpecMalfunction', @level2type=N'CONSTRAINT',@level2name=N'FK_MalfunctionStatus_Status'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabelą łączaca tabelę Element, Set, Printer i Order. Zamówienie może zawierać  zestaw lub element do wydrukowania.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SpecPrinterElementOrder'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Relacja jeden do wielu pomiędzy tabelami Element i SpecPrinterElementOrder. Pojedynczemu rekordowi z tabeli Element jest przyporządkowany jeden lub wiele rekordów z tabeli SpecPrinterElementOrder, natomiast pojedynczemu rekordowi z tabeli SpecPrinterElementOrder jest przyporządkowany dokładnie jeden rekord z tabeli Element. ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SpecPrinterElementOrder', @level2type=N'CONSTRAINT',@level2name=N'FK_SpecPrinterElementOrder_Element'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Relacja jeden do wielu pomiędzy tabelami Order i SpecPrinterElementOrder. Pojedynczemu rekordowi z tabeli Order jest przyporządkowany jeden lub wiele rekordów z tabeli SpecPrinterElementOrder, natomiast pojedynczemu rekordowi z tabeli SpecPrinterElementOrder jest przyporządkowany dokładnie jeden rekord z tabeli Order. ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SpecPrinterElementOrder', @level2type=N'CONSTRAINT',@level2name=N'FK_SpecPrinterElementOrder_Order'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Relacja jeden do wielu pomiędzy tabelami Printer i SpecPrinterElementOrder. Pojedynczemu rekordowi z tabeli Printer jest przyporządkowany jeden lub wiele rekordów z tabeli SpecPrinterElementOrder, natomiast pojedynczemu rekordowi z tabeli SpecPrinterElementOrder jest przyporządkowany dokładnie jeden rekord z tabeli Printer. ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SpecPrinterElementOrder', @level2type=N'CONSTRAINT',@level2name=N'FK_SpecPrinterElementOrder_Printer'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Relacja jeden do wielu pomiędzy tabelami Set i SpecPrinterElementOrder. Pojedynczemu rekordowi z tabeli Set jest przyporządkowany jeden lub wiele rekordów z tabeli SpecPrinterElementOrder, natomiast pojedynczemu rekordowi z tabeli SpecPrinterElementOrder jest przyporządkowany dokładnie jeden rekord z tabeli Set. ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SpecPrinterElementOrder', @level2type=N'CONSTRAINT',@level2name=N'FK_SpecPrinterElementOrder_Set'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Status', @level2type=N'COLUMN',@level2name=N'idStatus'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Status urządzenia' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Status', @level2type=N'COLUMN',@level2name=N'StatusDesc'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabela zawierająca statusy urządzeń.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Status'
GO
