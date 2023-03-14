using DbDocGenerator.Models;
using DbDocGenerator.Models.Tables;
using System.Data;
using Index = DbDocGenerator.Models.Tables.Index;

namespace DbDocGenerator.ViewModels;

public class HomeVeiwModel {
    public Dictionary<Guid, Function> Functions { get; set; }
    public Dictionary<Guid, Trigger> Triggers { get; set; }
    public Dictionary<Guid, DbProperty> DbProperties { get; set; }
    public Dictionary<Guid, ForeignKey> ForeignKeys { get; set; }
    public Dictionary<Guid, Index> Indexes { get; set; }
    public Dictionary<Guid, PrimaryKey> PrimaryKeys { get; set; }
    public Dictionary<Guid, TableDescription> TableDescriptions { get; set; }
    public Dictionary<Guid, ColumnDescription> ColumnDescriptions { get; set; }
    public Dictionary<Guid, DbInfo> DbInfo { get; set; }
    public Dictionary<Guid, DataTable> DataTables { get; set; }
    public Dictionary<Guid, TableOfContent> TableOfContents { get; set; }

    public string Query { get; set; }

    public string TableName { get; set; }
}