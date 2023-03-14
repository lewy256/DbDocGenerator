namespace DbDocGenerator.Models.Tables;

public class ForeignKey {
    public string ForeignKeyTableName { get; set; }
    public string ForeignKeyColumnName { get; set; }
    public string ForeignKeyName { get; set; }
    public string PrimaryKeyTableName { get; set; }
    public string Description { get; set; }
}