using DbDocGenerator.Models.Tables;
using DbDocGenerator.Services;

namespace DbDocGenerator.Controllers.Tables;

public class ColumnDescriptionController : BaseController<ColumnDescription> {

    public ColumnDescriptionController(BaseService<ColumnDescription> context) : base(context) {
    }
}