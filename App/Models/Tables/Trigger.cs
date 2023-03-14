namespace DbDocGenerator.Models.Tables;

public class Trigger {
    public string ParentObjectType { get; set; }
    public string ParentObjectName { get; set; }
    public string Name { get; set; }
    public string Type { get; set; }
    public string Description { get; set; }
}