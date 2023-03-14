using DbDocGenerator.Services;
using Microsoft.AspNetCore.Mvc;

namespace DbDocGenerator.Controllers;

public class TableCreatorController : Controller {
    private readonly TableService _tableService;

    public TableCreatorController(TableService tableService) {
        _tableService = tableService;
    }
}