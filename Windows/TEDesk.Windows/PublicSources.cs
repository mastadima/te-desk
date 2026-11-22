using System.Net;
using System.Net.Http.Headers;
using System.Text.Json;
using System.Text.Json.Serialization;
using System.Text.RegularExpressions;

namespace TEDesk.Windows;

internal sealed record SourceResult(string Source, string Title, string Detail, string Url);

internal sealed record FirmwareResult(string DeviceName, IReadOnlyList<string> Versions, string Url)
{
    public string Summary => Versions.Count == 0
        ? "На странице не удалось распознать номер версии."
        : string.Join(" · ", Versions);
}

internal static class PublicSources
{
    private static readonly HttpClient Client = CreateClient();

    public static async Task<IReadOnlyList<SourceResult>> SearchGitHubAsync(string device, CancellationToken cancellationToken)
    {
        var url = $"https://api.github.com/search/repositories?q={Uri.EscapeDataString($"{device} Teenage Engineering")}&sort=updated&per_page=6";
        using var response = await Client.GetAsync(url, cancellationToken);
        response.EnsureSuccessStatusCode();
        await using var stream = await response.Content.ReadAsStreamAsync(cancellationToken);
        using var document = await JsonDocument.ParseAsync(stream, cancellationToken: cancellationToken);
        if (!document.RootElement.TryGetProperty("items", out var items)) return [];

        return items.EnumerateArray().Select(item => new SourceResult(
            "GitHub",
            ReadString(item, "full_name"),
            ReadString(item, "description"),
            ReadString(item, "html_url"))).ToArray();
    }

    public static async Task<IReadOnlyList<SourceResult>> SearchRedditAsync(string device, CancellationToken cancellationToken)
    {
        var url = $"https://www.reddit.com/search.json?q={Uri.EscapeDataString($"\"{device}\"")}&sort=new&limit=8";
        using var response = await Client.GetAsync(url, cancellationToken);
        if (response.StatusCode == HttpStatusCode.Forbidden)
            throw new RedditBlockedException(RedditSearchUrl(device));
        response.EnsureSuccessStatusCode();

        await using var stream = await response.Content.ReadAsStreamAsync(cancellationToken);
        using var document = await JsonDocument.ParseAsync(stream, cancellationToken: cancellationToken);
        if (!document.RootElement.TryGetProperty("data", out var data)
            || !data.TryGetProperty("children", out var children))
            return [];

        return children.EnumerateArray().Select(child =>
        {
            var post = child.GetProperty("data");
            return new SourceResult(
                "Reddit",
                ReadString(post, "title"),
                $"Score: {ReadString(post, "score")}",
                $"https://www.reddit.com{ReadString(post, "permalink")}");
        }).ToArray();
    }

    public static async Task<FirmwareResult> CheckFirmwareAsync(string model, CancellationToken cancellationToken)
    {
        var slug = DownloadsSlug(model);
        if (slug is null) throw new InvalidOperationException($"Для {model} не настроена официальная страница загрузок.");
        var url = $"https://teenage.engineering/downloads/{slug}";
        using var response = await Client.GetAsync(url, cancellationToken);
        response.EnsureSuccessStatusCode();
        var html = await response.Content.ReadAsStringAsync(cancellationToken);
        var text = WebUtility.HtmlDecode(Regex.Replace(html, @"(?is)<script\b[^>]*>.*?</script>|<style\b[^>]*>.*?</style>|<[^>]+>", " "));
        var versions = Regex.Matches(text, @"(?<![A-Za-z0-9])(?:[0-9]+\.)+[0-9]+(?:\+[0-9]+)?(?![A-Za-z0-9])|(?<![A-Za-z0-9])#[0-9]+(?![0-9])")
            .Select(match => match.Value)
            .Where(version => !IsReleaseDate(version))
            .Distinct(StringComparer.Ordinal)
            .Take(4)
            .ToArray();
        return new FirmwareResult(model, versions, url);
    }

    public static string? DownloadsSlug(string model)
    {
        var name = model.ToLowerInvariant().Replace('–', '-').Replace('—', '-');
        if (name.Contains("op-xy", StringComparison.Ordinal)) return "op-xy";
        if (name.Contains("op-z", StringComparison.Ordinal)) return "op-z";
        if (name.Contains("op-1", StringComparison.Ordinal)) return "op-1";
        if (name.Contains("ep-133", StringComparison.Ordinal)) return "ep-133";
        if (name.Contains("ep-1320", StringComparison.Ordinal)) return "ep-1320";
        if (name.Contains("ep-136", StringComparison.Ordinal)) return "ep-136";
        if (name.Contains("ep-40", StringComparison.Ordinal)) return "ep-40";
        if (name.Contains("ep-35", StringComparison.Ordinal)) return "ep-35";
        if (name.Contains("bc-1", StringComparison.Ordinal)) return "bc-1";
        if (name.Contains("tp-7", StringComparison.Ordinal)) return "tp-7";
        if (name.Contains("tx-6", StringComparison.Ordinal)) return "tx-6";
        if (name.Contains("cm-15", StringComparison.Ordinal)) return "cm-15";
        if (name.Contains("choir", StringComparison.Ordinal)) return "choir";
        return null;
    }

    public static string RedditSearchUrl(string device) =>
        $"https://www.reddit.com/search/?q={Uri.EscapeDataString(device)}&sort=new";

    private static HttpClient CreateClient()
    {
        var client = new HttpClient { Timeout = TimeSpan.FromSeconds(18) };
        client.DefaultRequestHeaders.UserAgent.ParseAdd("TE-Desk/0.1 (Windows device companion)");
        client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));
        return client;
    }

    private static string ReadString(JsonElement element, string property) =>
        element.TryGetProperty(property, out var value) ? value.ToString() : string.Empty;

    private static bool IsReleaseDate(string version)
    {
        var firstPart = version.Split('.')[0];
        return firstPart.Length == 4
            && int.TryParse(firstPart, out var year)
            && year is >= 1900 and <= 2099;
    }
}

internal sealed class RedditBlockedException(string searchUrl)
    : Exception("Reddit API вернул HTTP 403. Откройте поиск Reddit в браузере.")
{
    public string SearchUrl { get; } = searchUrl;
}
