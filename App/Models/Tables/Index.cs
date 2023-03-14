namespace DbDocGenerator.Models.Tables;

public class Index {
    public string IndexName { get; set; }
    public string TableName { get; set; }
    public string ColumnName { get; set; }
    public string IndexType { get; set; }
    public string IsPrimaryKey { get; set; }
    public string IndexDescription { get; set; }
}