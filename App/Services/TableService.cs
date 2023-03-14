using DbDocGenerator.Models;
using System.Data;
using System.Data.SqlClient;

namespace DbDocGenerator.Services;

public class TableService {
    public Dictionary<Guid, DataTable> AllTables { get; set; } = new Dictionary<Guid, DataTable>();
    private Login login;

    public void InitLogin(Login login) {
        this.login = login;
    }

    public void AddTable(string query, string tableName) {
        var table = new DataTable();
        var connectionString = $"Server={login.ServerName}; Database={login.DatabaseName}; User Id={login.UserName}; Password={login.Password};";
        using (var conn = new SqlConnection(connectionString)) {
            using (var cmd = conn.CreateCommand()) {
                conn.Open();
                cmd.CommandText = query;
                table.Load(cmd.ExecuteReader());
            };
        }
        table.TableName = tableName;
        AllTables.Add(Guid.NewGuid(), table);
    }
}