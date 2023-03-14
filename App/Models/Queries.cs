namespace DbDocGenerator.Models;

public class Queries {

    public string Trigger { get; } = @"
SELECT sys.objects.type_desc as ParentObjectType, sys.objects.name as ParentObjectName,
  sys.triggers.name as Name, sys.trigger_events.type_desc as Type,
  sys.extended_properties.value as Description
FROM sys.trigger_events INNER JOIN
  sys.triggers ON sys.triggers.object_id = sys.trigger_events.object_id LEFT OUTER JOIN
  sys.objects ON sys.triggers.parent_id = sys.objects.object_id LEFT OUTER JOIN
  sys.extended_properties ON sys.triggers.object_id = sys.extended_properties.major_id
ORDER BY sys.objects.name
";

    public string Function { get; } = @"
SELECT sys.objects.name AS Name, sys.objects.type as Type, sys.objects.type_desc as TypeDescription, sys.extended_properties.value AS Description
FROM sys.objects LEFT OUTER JOIN
    sys.extended_properties ON sys.objects.object_id = sys.extended_properties.major_id RIGHT OUTER JOIN
    sys.schemas ON sys.objects.schema_id = sys.schemas.schema_id
WHERE (sys.objects.type IN ('AF', 'FN', 'FS', 'FT', 'IF', 'TF'))
";

    public string Table { get; } = @"
SELECT
    sys.tables.name AS TableName, sys.tables.max_column_id_used AS ColumnCount,
    sys.dm_db_partition_stats.row_count AS 'RowCount', sys.extended_properties.value AS Description
FROM         sys.tables LEFT OUTER JOIN
    sys.dm_db_partition_stats ON sys.tables.object_id = sys.dm_db_partition_stats.object_id LEFT OUTER JOIN
    sys.extended_properties ON sys.tables.object_id = sys.extended_properties.major_id LEFT OUTER JOIN
    sys.schemas ON sys.schemas.schema_id = sys.tables.schema_id
WHERE     (sys.tables.name IS NOT NULL) AND (sys.extended_properties.class = 1) AND (sys.extended_properties.minor_id = 0) AND
    (sys.extended_properties.name = 'MS_Description') and index_id <= 1
ORDER BY sys.schemas.name, sys.tables.name";

    public string Column { get; } = @"
SELECT sys.tables.name AS TableName, sys.columns.name AS ColumnName,
CASE sys.types.name
	When 'varchar' Then sys.types.name + '(' +
	 CASE sys.columns.max_length
		WHEN -1 THEN 'Max'
		Else CAST(sys.columns.max_length AS varchar(5))
	END + ')'
	When 'varbinary' Then sys.types.name + '(' +
	 CASE sys.columns.max_length
		WHEN -1 THEN 'Max'
		Else CAST(sys.columns.max_length AS varchar(5))
	END + ')'
	When 'nvarchar' Then sys.types.name + '(' +
	 CASE sys.columns.max_length
		WHEN -1 THEN 'Max'
	    Else CAST(sys.columns.max_length AS varchar(5))
	END + ')'
	When 'char' Then sys.types.name + '(' + CAST(sys.columns.max_length AS varchar(5)) + ')'
	When 'numeric' Then sys.types.name +  '(' + CAST(sys.columns.precision AS varchar(5)) + ',' + CAST(sys.columns.scale AS varchar(5)) +')'
	When 'decimal' Then sys.types.name +  '(' + CAST(sys.columns.precision AS varchar(5)) + ',' + CAST(sys.columns.scale AS varchar(5)) +')'
	When 'money' Then sys.types.name +  '(' + CAST(sys.columns.precision AS varchar(5)) + ',' + CAST(sys.columns.scale AS varchar(5)) +')'
Else 	sys.types.name
END AS DataType, isNull(sys.columns.collation_name,'') AS Collation,
    Case sys.columns.is_nullable When '1' Then 'Nullable' Else '' End AS IsNullable,
    sys.extended_properties.value AS ColumnDescription

FROM sys.tables LEFT OUTER JOIN
  sys.columns ON sys.tables.object_id = sys.columns.object_id LEFT OUTER JOIN
  sys.schemas ON sys.tables.schema_id = sys.schemas.schema_id LEFT OUTER JOIN
  sys.extended_properties ON sys.extended_properties.major_id = sys.columns.object_id AND sys.extended_properties.minor_id = sys.columns.column_id LEFT OUTER JOIN
  sys.types ON sys.types.system_type_id = sys.columns.system_type_id
WHERE sys.types.name <> 'sysname' AND (sys.extended_properties.class = 1 OR sys.extended_properties.class IS NULL)
ORDER BY sys.schemas.name, sys.tables.name, sys.columns.column_id
";

    public string PrimaryKey { get; } = @"
SELECT  sys.objects.name AS PKName,
    sys.tables.name AS TableName,
	sys.columns.name as PrimaryKeyColumnName,
	sys.extended_properties.value AS Description

FROM sys.sysconstraints LEFT OUTER JOIN
	sys.objects ON sys.objects.object_id = sys.sysconstraints.constid LEFT OUTER JOIN
	sys.tables ON sys.objects.parent_object_id = sys.tables.object_id INNER JOIN
	sys.indexes on sys.tables.object_id = sys.indexes.object_id and sys.indexes.is_primary_key = 1 INNER JOIN
	sys.index_columns on sys.index_columns.object_id = sys.indexes.object_id and sys.index_columns.index_id = sys.indexes.index_id INNER JOIN
	sys.columns on sys.indexes.object_id = sys.columns.object_id and sys.columns.column_id = sys.index_columns.column_id LEFT OUTER JOIN
	sys.extended_properties ON sys.extended_properties.major_id = sys.sysconstraints.constid
WHERE sys.objects.type = 'PK'
";

    public string ForeignKey { get; } = @"
SELECT sys.objects.name AS ForeignKeyTableName, sys.columns.name AS ForeignKeyColumnName,
	sys.foreign_keys.name AS ForeignKeyName, so2.name AS PrimaryKeyTableName, sys.extended_properties.value AS Description

FROM sys.foreign_key_columns INNER JOIN
    sys.foreign_keys ON sys.foreign_key_columns.constraint_object_id = sys.foreign_keys.object_id INNER JOIN
    sys.objects ON sys.objects.object_id = sys.foreign_key_columns.parent_object_id INNER JOIN
    sys.columns ON sys.columns.object_id = sys.foreign_key_columns.parent_object_id AND sys.columns.column_id = sys.foreign_key_columns.parent_column_id INNER JOIN
	sys.objects AS so2 ON so2.object_id = sys.foreign_key_columns.referenced_object_id INNER JOIN
	sys.columns AS sc2 ON sc2.object_id = sys.foreign_key_columns.referenced_object_id AND sc2.column_id = sys.foreign_key_columns.referenced_column_id LEFT OUTER JOIN
    sys.extended_properties ON sys.foreign_keys.object_id = sys.extended_properties.major_id

ORDER BY sys.objects.name
";

    public string Index { get; } = @"
SELECT   sys.indexes.name AS IndexName, sys.tables.name AS TableName, sys.columns.name AS ColumnName,
	sys.indexes.type_desc AS IndexType,
	CASE WHEN is_primary_key=1 THEN 'PrimaryKey' ELSE '' END As IsPrimaryKey,
    extended_properties.value AS IndexDescription
FROM sys.sysindexkeys LEFT OUTER JOIN
    sys.indexes ON sys.sysindexkeys.id = sys.indexes.object_id AND sys.sysindexkeys.indid = sys.indexes.index_id LEFT OUTER JOIN
    sys.tables INNER JOIN
    sys.columns ON sys.tables.object_id = sys.columns.object_id ON sys.sysindexkeys.colid = sys.columns.column_id AND
    sys.indexes.object_id = sys.columns.object_id LEFT OUTER JOIN
	sys.schemas ON sys.schemas.schema_id = sys.tables.schema_id  LEFT OUTER JOIN
	sys.extended_properties ON  extended_properties.major_id = indexes.object_id AND extended_properties.minor_id = indexes.index_id
where sys.schemas.name IS NOT NULL
ORDER BY sys.schemas.name, sys.tables.name, column_id
";
    public string DatabaseProperty { get; set; } = @"
select * from(

SELECT

convert(varchar(256), (select  [ServiceName]  = @@SERVICENAME) ) as  [ServiceName]
,convert(varchar(256), (select [ServerName] = SERVERPROPERTY('ServerName')) ) as [ServerName]
,convert(varchar(256), (select [PhysicalNetBIOSName] = SERVERPROPERTY('ComputerNamePhysicalNetBIOS')) ) as [PhysicalNetBIOSName]
,convert(varchar(256), (select [Edition]  = SERVERPROPERTY('Edition')) ) as [Edition]
,convert(varchar(256), (select [ProductVersion]  = SERVERPROPERTY('ProductVersion')) ) as [ProductVersion]
,convert(varchar(256), (select [ProductUpdateReference]  = SERVERPROPERTY('ProductUpdateReference')) ) as [ProductUpdateReference]
,convert(varchar(256), (select [ResourceLastUpdateDate] = SERVERPROPERTY('ResourceLastUpdateDateTime')) ) as [ResourceLastUpdateDate]
,convert(varchar(256), (select [ProcessID] = SERVERPROPERTY('ProcessID')) ) as [ProcessID]
,convert(varchar(256), (select [Collation]  = SERVERPROPERTY('Collation')) ) as [Collation]
,convert(varchar(256), (select [CLRVersion]  = SERVERPROPERTY('BuildClrVersion')) ) as [CLRVersion]
,convert(varchar(256), (select [IsClustered]    = SERVERPROPERTY('IsClustered') ) ) as [IsClustered]
,convert(varchar(256), (select [IsFullTextInstalled]   = SERVERPROPERTY('IsFullTextInstalled') ) ) as [IsFullTextInstalled]
,convert(varchar(256), (select [IsIntegratedSecurityOnly] = SERVERPROPERTY('IsIntegratedSecurityOnly')) ) as [IsIntegratedSecurityOnly]
,convert(varchar(256), (select [FileStreamConfiguredLevel] = SERVERPROPERTY('FilestreamConfiguredLevel')) ) as [FileStreamConfiguredLevel]
,convert(varchar(256), (select [IsHadrEnabled]    = SERVERPROPERTY('IsHadrEnabled') ) ) as [IsHadrEnabled]
,convert(varchar(256), (select [HadrManagerStatus]  = SERVERPROPERTY('HadrManagerStatus')) ) as [HadrManagerStatus]
,convert(varchar(256), (select [DefaultDataPath]  = SERVERPROPERTY('InstanceDefaultDataPath')) ) as [DefaultDataPath]
,convert(varchar(256), (select [DefaultLogPath]  = SERVERPROPERTY('InstanceDefaultLogPath')) ) as [DefaultLogPath]
) as t
UNPIVOT
(
  [Value]
  FOR [DatabaseProperty] IN(
   [ServiceName]
,[ServerName]
,[PhysicalNetBIOSName]
,[Edition]
,[ProductVersion]
,[ProductUpdateReference]
,[ResourceLastUpdateDate]
,[ProcessID]
,[Collation]
,[CLRVersion]
,[IsClustered]
,[IsFullTextInstalled]
,[IsIntegratedSecurityOnly]
,[FileStreamConfiguredLevel]
,[IsHadrEnabled]
,[HadrManagerStatus]
,[DefaultDataPath]
,[DefaultLogPath]
)) AS u
";
}