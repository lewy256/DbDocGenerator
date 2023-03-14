namespace DbDocGenerator.Models.Tables;

public class ColumnDescription {
    public string TableName { get; set; }
    public string ColumnName { get; set; }
    public string DataType { get; set; }
    public string Collation { get; set; }
    public string IsNullable { get; set; }
    public string Description { get; set; }
}