/****** Object:  Table [dbo].[UserInfo]    Script Date: 01/19/2016 21:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserInfo](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[UserName] [nvarchar](250) NULL,
	[AuthToken] [nvarchar](250) NULL,
	[RefreshToken] [nvarchar](250) NULL,
	[AuthDt] [datetime] NULL,
 CONSTRAINT [PK_UserInfo] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SendInfo]    Script Date: 01/19/2016 21:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SendInfo](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[UserName] [nvarchar](250) NULL,
	[SendEmail] [bit] NULL,
	[SendSms] [bit] NULL,
	[SendRoost] [bit] NULL,
	[UserEmail] [nvarchar](500) NULL,
	[UserPhone] [nvarchar](20) NULL,
	[LastSendDt] [datetime] NULL,
	[City] [nvarchar](250) NULL,
	[DataFileName] [nvarchar](150) NULL,
	[DataFileId] [nvarchar](150) NULL,
	[TimeWeekDay] [nvarchar](50) NULL,
	[TimeWeekEnd] [nvarchar](50) NULL,
	[TimeZoneValue] [nvarchar](50) NULL,
	[TimeZoneOffset] [decimal](18, 5) NULL,
	[WeekendMode] [int] NULL,
	[Temperature] [int] NULL,
	[SmsId] [nvarchar](50) NULL,
	[SmsUseFrom2] [bit] NULL,
	[LastWeatherUpdate] [nvarchar](max) NULL,
	[WeatherUpdateDt] [datetime] NULL,
 CONSTRAINT [PK_EmailInfo] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
