using DbDocGenerator.Models;
using DbDocGenerator.Models.Tables;
using DbDocGenerator.Services;
using DbDocGenerator.ViewModels;
using Microsoft.AspNetCore.Mvc;
using PuppeteerSharp;
using PuppeteerSharp.Media;
using System.Data.SqlClient;
using Index = DbDocGenerator.Models.Tables.Index;

namespace DbDocGenerator.Controllers;

public class HomeController : Controller {
    private readonly BaseService<Function> _funtionService;
    private readonly BaseService<Trigger> _triggerService;
    private readonly BaseService<Index> _indexService;
    private readonly BaseService<PrimaryKey> _primaryKeyService;
    private readonly BaseService<ForeignKey> _foreignKeyService;
    private readonly BaseService<DbProperty> _dbPropertyService;
    private readonly BaseService<TableDescription> _tableDescService;
    private readonly BaseService<ColumnDescription> _columnDescService;
    private readonly BaseService<DbInfo> _dbInfoService;
    private readonly TableService _tableService;
    private readonly IWebHostEnvironment _webHostEnvironment;
    private readonly TemplateService _templateService;
    private readonly TableOfContentService _tableOfContentService;

    public HomeController(BaseService<Function> funtionService,
        BaseService<Trigger> triggerService,
        BaseService<Index> indexService,
        BaseService<PrimaryKey> primaryKeyService,
        BaseService<ForeignKey> foreignKeyService,
        BaseService<DbProperty> dbPropertyService,
        BaseService<TableDescription> tableDescService,
        BaseService<ColumnDescription> columnDescService,
        BaseService<DbInfo> dbInfoService,
        TableService tableService,
        IWebHostEnvironment webHostEnvironment,
        TemplateService templateService,
        TableOfContentService tableOfContentService
    ) {
        _funtionService = funtionService;
        _triggerService = triggerService;
        _indexService = indexService;
        _primaryKeyService = primaryKeyService;
        _foreignKeyService = foreignKeyService;
        _dbPropertyService = dbPropertyService;
        _tableDescService = tableDescService;
        _columnDescService = columnDescService;
        _dbInfoService = dbInfoService;
        _tableService = tableService;
        _webHostEnvironment = webHostEnvironment;
        _templateService = templateService;
        _tableOfContentService = tableOfContentService;
    }

    public IActionResult Index() {
        var viewModel = new HomeVeiwModel() {
            Functions = _funtionService.GetAll(),
            Triggers = _triggerService.GetAll(),
            PrimaryKeys = _primaryKeyService.GetAll(),
            ForeignKeys = _foreignKeyService.GetAll(),
            TableDescriptions = _tableDescService.GetAll(),
            DbProperties = _dbPropertyService.GetAll(),
            ColumnDescriptions = _columnDescService.GetAll(),
            Indexes = _indexService.GetAll(),
            DbInfo = _dbInfoService.GetAll(),
            DataTables = _tableService.AllTables,
            TableOfContents = _tableOfContentService.GetAll()
        };

        return View(viewModel);
    }

    public IActionResult Login(Login login) {
        if (ModelState.IsValid) {
            var connectionString = $"Server={login.ServerName}; Database={login.DatabaseName}; User Id={login.UserName}; Password={login.Password};";

            using var connection = new SqlConnection(connectionString);
            connection.Open();

            var query = new Queries();

            _funtionService.InitDictionary(query.Function, connectionString);
            _triggerService.InitDictionary(query.Trigger, connectionString);
            _dbPropertyService.InitDictionary(query.DatabaseProperty, connectionString);
            _columnDescService.InitDictionary(query.Column, connectionString);
            _primaryKeyService.InitDictionary(query.PrimaryKey, connectionString);
            _foreignKeyService.InitDictionary(query.ForeignKey, connectionString);
            _tableDescService.InitDictionary(query.Table, connectionString);
            _indexService.InitDictionary(query.Index, connectionString);
            _dbInfoService.Add(Guid.NewGuid(), new DbInfo() {
                ServerName = login.ServerName,
                DatabaseName = login.DatabaseName,
                UserName = login.UserName,
                CurrentDate = DateTime.Now.ToString()
            });

            var list = new List<Subtitle>();
            var tableName = _tableDescService.GetAll();
            foreach (var item in tableName) {
                list.Add(new Subtitle() { SubTitle = item.Value.TableName, PageNumber = 0 });
            }

            _tableOfContentService.AddTitle(Guid.NewGuid(), new TableOfContent { PageNumber = 3, Title = "Database properties" });
            _tableOfContentService.AddTitle(Guid.NewGuid(), new TableOfContent { PageNumber = 4, Title = "Tables", Subtitles = list.ToDictionary(x => Guid.NewGuid(), x => x) });
            _tableOfContentService.AddTitle(Guid.NewGuid(), new TableOfContent { PageNumber = 5, Title = "Functions" });
            _tableOfContentService.AddTitle(Guid.NewGuid(), new TableOfContent { PageNumber = 7, Title = "Triggers" });

            _tableService.InitLogin(login);

            return RedirectToAction(nameof(Details), "Home");
        }

        return View();
    }

    public async Task<IActionResult> Print() {
        var viewModel = new HomeVeiwModel() {
            Functions = _funtionService.GetAll(),
            Triggers = _triggerService.GetAll(),
            PrimaryKeys = _primaryKeyService.GetAll(),
            ForeignKeys = _foreignKeyService.GetAll(),
            TableDescriptions = _tableDescService.GetAll(),
            DbProperties = _dbPropertyService.GetAll(),
            ColumnDescriptions = _columnDescService.GetAll(),
            Indexes = _indexService.GetAll(),
            DbInfo = _dbInfoService.GetAll(),
            DataTables = _tableService.AllTables,
            TableOfContents = _tableOfContentService.GetAll(),
        };

        var html = await _templateService.RenderAsync("Home/Index", viewModel);
        await using var browser = await Puppeteer.LaunchAsync(new LaunchOptions {
            Headless = true,
            Args = new[] { "--no-sandbox" }
        });
        await using var page = await browser.NewPageAsync();

        await page.SetContentAsync(html);

        await page.AddStyleTagAsync(new AddTagOptions() { Path = "wwwroot/lib/bootstrap/dist/css/bootstrap.css" });
        await page.AddStyleTagAsync(new AddTagOptions() { Path = "wwwroot/css/table-of-content.css" });

        var pdfContent = await page.PdfStreamAsync(new PdfOptions {
            MarginOptions = new MarginOptions {
                Top = "20px",
                Right = "20px",
                Bottom = "40px",
                Left = "20px"
            },
            Format = PaperFormat.A4,
            PrintBackground = true,
            DisplayHeaderFooter = true,
            HeaderTemplate = "<div class=\"title\"></div>",
            FooterTemplate = "<div class=\"pageNumber\" style=\"font-size:10px; margin-left: auto; margin-right:40px\"></div>",
        });

        return File(pdfContent, "application/pdf", $"{Guid.NewGuid()}.pdf");
    }

    public IActionResult List(string query, string tableName) {
        _tableOfContentService.AddTitle(Guid.NewGuid(), new TableOfContent() { Title = tableName, PageNumber = 0 });
        _tableService.AddTable(query, tableName);
        return RedirectToAction(nameof(Index), "Home");
    }

    public IActionResult Details() {
        return View();
    }

    public IActionResult Error() {
        return View();
    }

    public IActionResult Delete(Guid id) {
        _tableService.AllTables.Remove(id);
        return RedirectToAction(nameof(Index), "Home");
    }
}