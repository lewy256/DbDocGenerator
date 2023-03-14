namespace DbDocGenerator.Models;

public class TableOfContent {
    public string Title { get; set; }
    public int PageNumber { get; set; }
    public Dictionary<Guid, Subtitle> Subtitles { get; set; } = new Dictionary<Guid, Subtitle>();
}