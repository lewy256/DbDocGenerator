using Dapper;
using System.Data.SqlClient;

namespace DbDocGenerator.Services;

public class BaseService<T> where T : class {
    private Dictionary<Guid, T> _table = new Dictionary<Guid, T>();

    public void InitDictionary(string query, string connectionString) {
        using var connection = new SqlConnection(connectionString);

        var model = connection.Query<T>(query).AsList();

        _table = model.ToDictionary(x => Guid.NewGuid(), x => x);
    }

    public Dictionary<Guid, T> GetAll() {
        return _table;
    }

    public T GetById(Guid id) {
        var item = _table.FirstOrDefault(x => x.Key == id).Value;
        return item;
    }

    public void Add(Guid id, T item) {
        _table[id] = item;
    }

    public void Update(Guid id, T item) {
        _table[id] = item;
    }

    public void RemoveAt(Guid id) {
        _table.Remove(id);
    }

    public void RemoveTable() {
        _table.Clear();
    }
}