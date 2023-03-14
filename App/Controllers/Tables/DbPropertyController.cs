using DbDocGenerator.Models.Tables;
using DbDocGenerator.Services;

namespace DbDocGenerator.Controllers.Tables;

public class DbPropertyController : BaseController<DbProperty> {

    public DbPropertyController(BaseService<DbProperty> context) : base(context) {
    }
}