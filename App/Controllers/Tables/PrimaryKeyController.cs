using DbDocGenerator.Models.Tables;
using DbDocGenerator.Services;

namespace DbDocGenerator.Controllers.Tables;

public class PrimaryKeyController : BaseController<PrimaryKey> {

    public PrimaryKeyController(BaseService<PrimaryKey> context) : base(context) {
    }
}