using DbDocGenerator.Models.Tables;
using DbDocGenerator.Services;

namespace DbDocGenerator.Controllers.Tables;

public class DbInfoController : BaseController<DbInfo> {

    public DbInfoController(BaseService<DbInfo> context) : base(context) {
    }
}