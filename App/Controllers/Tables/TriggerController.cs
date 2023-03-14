using DbDocGenerator.Models.Tables;
using DbDocGenerator.Services;

namespace DbDocGenerator.Controllers.Tables {

    public class TriggerController : BaseController<Trigger> {

        public TriggerController(BaseService<Trigger> context) : base(context) {
        }
    }
}