using DbDocGenerator.Services;
using Microsoft.AspNetCore.Mvc;

namespace DbDocGenerator.Controllers;

public class BaseController<T> : Controller where T : class {
    private readonly BaseService<T> _baseService;

    public BaseController(BaseService<T> baseService) {
        _baseService = baseService;
    }

    public IActionResult Create() {
        var model = Activator.CreateInstance(typeof(T));
        return View(model);
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public IActionResult Create(T entity) {
        if (ModelState.IsValid) {
            _baseService.Add(Guid.NewGuid(), entity);
            return RedirectToAction("Index", "Home");
        }
        return View(entity);
    }

    public IActionResult Edit(Guid id) {
        var entity = _baseService.GetById(id);
        if (entity == null) {
            return NotFound();
        }
        return View(entity);
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public IActionResult Edit(Guid id, T entity) {
        if (ModelState.IsValid) {
            _baseService.Update(id, entity);

            return RedirectToAction("Index", "Home");
        }
        return View(entity);
    }

    public IActionResult Delete(Guid id) {
        _baseService.RemoveAt(id);

        return RedirectToAction("Index", "Home");
    }
}