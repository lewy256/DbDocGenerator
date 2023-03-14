namespace DbDocGenerator.ViewModels;

public class SubtitleViewModel {
    public Guid SubtitleId { get; set; }
    public Guid TitleId { get; set; }
    public string Subtitle { get; set; }
    public int PageNumber { get; set; }
}