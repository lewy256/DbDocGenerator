using DbDocGenerator.Models;

namespace DbDocGenerator.Services;

public class TableOfContentService {
    private Dictionary<Guid, TableOfContent> _table = new Dictionary<Guid, TableOfContent>();

    public Dictionary<Guid, TableOfContent> GetAll() {
        return _table;
    }

    public TableOfContent GetTitleById(Guid idTitle) {
        var item = _table[idTitle];
        return item;
    }

    public Subtitle GetSubtitleById(Guid idTitle, Guid idSubtitle) {
        var item = _table[idTitle].Subtitles[idSubtitle];
        return item;
    }

    public void AddTitle(Guid idTitle, TableOfContent item) {
        _table[idTitle] = item;
    }

    public void AddSubtitle(Guid idTitle, Guid idSubtitle, Subtitle item) {
        _table[idTitle].Subtitles[idSubtitle] = item;
    }

    public void UpdateTitle(Guid idTitle, TableOfContent item) {
        _table[idTitle] = item;
    }

    public void UpdateSubtitle(Guid idTitle, Guid idSubtitle, Subtitle item) {
        _table[idTitle].Subtitles[idSubtitle] = item;
    }

    public void RemoveSubtitleAt(Guid idTitle, Guid idSubtitle) {
        _table[idTitle].Subtitles.Remove(idSubtitle);
    }

    public void RemoveTitleAt(Guid idTitle) {
        _table.Remove(idTitle);
    }
}