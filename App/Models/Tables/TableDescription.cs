namespace DbDocGenerator.Models.Tables;

public class TableDescription {
    public string TableName { get; set; }
    public int ColumnCount { get; set; }
    public int RowCount { get; set; }
    public string Description { get; set; }
}