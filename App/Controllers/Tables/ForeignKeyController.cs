using DbDocGenerator.Models.Tables;
using DbDocGenerator.Services;

namespace DbDocGenerator.Controllers.Tables;

public class ForeignKeyController : BaseController<ForeignKey> {

    public ForeignKeyController(BaseService<ForeignKey> context) : base(context) {
    }
}