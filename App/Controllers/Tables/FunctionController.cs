using DbDocGenerator.Models.Tables;
using DbDocGenerator.Services;

namespace DbDocGenerator.Controllers.Tables;

public class FunctionController : BaseController<Function> {

    public FunctionController(BaseService<Function> context) : base(context) {
    }
}