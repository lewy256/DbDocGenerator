using DbDocGenerator.Models.Tables;
using DbDocGenerator.Services;

namespace DbDocGenerator.Controllers.Tables;

public class TableDescriptionController : BaseController<TableDescription> {

    public TableDescriptionController(BaseService<TableDescription> context) : base(context) {
    }
}