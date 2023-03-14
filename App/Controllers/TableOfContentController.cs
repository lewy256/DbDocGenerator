using DbDocGenerator.Models;
using DbDocGenerator.Services;
using DbDocGenerator.ViewModels;
using Microsoft.AspNetCore.Mvc;

namespace DbDocGenerator.Controllers;

public class TableOfContentController : Controller {
    private readonly TableOfContentService _tableOfContentService;

    public TableOfContentController(TableOfContentService tableOfContentService) {
        _tableOfContentService = tableOfContentService;
    }

    [HttpGet]
    public IActionResult CreateTitle() {
        return View();
    }

    [HttpPost]
    public IActionResult CreateTitle(TableOfContent item) {
        if (ModelState.IsValid) {
            _tableOfContentService.AddTitle(Guid.NewGuid(), item);
            return RedirectToAction("Index", "Home");
        }
        return View(item);
    }

    [HttpGet]
    public IActionResult CreateSubtitle() {
        return View();
    }

    [HttpPost]
    [Route("TableOfContent/CreateSubtitle/{idTitle:Guid}")]
    [ValidateAntiForgeryToken]
    public IActionResult CreateSubtitle(Guid idTitle, Subtitle item) {
        if (ModelState.IsValid) {
            _tableOfContentService.AddSubtitle(idTitle, Guid.NewGuid(), item);
            return RedirectToAction("Index", "Home");
        }
        return View(item);
    }

    [HttpGet]
    [Route("TableOfContent/EditTitle/{idTitle:Guid}")]//I dont need this here.
    public IActionResult EditTitle(Guid idTitle) {
        var entity = _tableOfContentService.GetTitleById(idTitle);

        return View(new TitleViewModel() {
            Title = entity.Title,
            TitleId = idTitle,
            PageNumber = entity.PageNumber
        });
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public IActionResult EditTitle(TitleViewModel entity) {
        if (ModelState.IsValid) {
            _tableOfContentService.UpdateTitle(entity.TitleId, new TableOfContent() { PageNumber = entity.PageNumber, Title = entity.Title });

            return RedirectToAction("Index", "Home");
        }
        return View(entity);
    }

    [HttpGet]
    [Route("TableOfContent/EditSubtitle/{idTitle:Guid}/{idSubtitle:Guid}")]
    public IActionResult EditSubtitle(Guid idTitle, Guid idSubtitle) {
        var entity = _tableOfContentService.GetTitleById(idTitle).Subtitles[idSubtitle];

        return View(new SubtitleViewModel() {
            SubtitleId = idSubtitle,
            TitleId = idTitle,
            Subtitle = entity.SubTitle,
            PageNumber = entity.PageNumber
        });
    }

    [HttpPost]
    [Route("TableOfContent/EditSubtitle/{idTitle:Guid}/{idSubtitle:Guid}")]
    [ValidateAntiForgeryToken]
    public IActionResult EditSubtitle(SubtitleViewModel entity) {
        if (ModelState.IsValid) {
            _tableOfContentService.UpdateSubtitle(entity.TitleId, entity.SubtitleId, new Subtitle() {
                PageNumber = entity.PageNumber,
                SubTitle = entity.Subtitle
            });

            return RedirectToAction("Index", "Home");
        }
        return View(entity);
    }

    [Route("TableOfContent/DeleteTitle/{idTitle:Guid}")]
    public IActionResult DeleteTitle(Guid idTitle) {
        _tableOfContentService.RemoveTitleAt(idTitle);

        return RedirectToAction("Index", "Home");
    }

    [Route("TableOfContent/DeleteSubtitle/{idTitle:Guid}/{idSubtitle:Guid}")]
    public IActionResult DeleteSubtitle(Guid idTitle, Guid idSubTitle) {
        _tableOfContentService.RemoveSubtitleAt(idTitle, idSubTitle);

        return RedirectToAction("Index", "Home");
    }
}