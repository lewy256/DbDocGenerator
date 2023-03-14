using DbDocGenerator.Services;
using Index = DbDocGenerator.Models.Tables.Index;

namespace DbDocGenerator.Controllers.Tables;

public class IndexController : BaseController<Index> {

    public IndexController(BaseService<Index> context) : base(context) {
    }
}