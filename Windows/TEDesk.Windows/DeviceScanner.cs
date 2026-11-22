using System.Diagnostics;
using System.Globalization;
using System.Text.Json;
using System.Text.RegularExpressions;

namespace TEDesk.Windows;

internal sealed record TeDevice(
    string Name,
    string Manufacturer,
    string InstanceId,
    string VendorId,
    string ProductId,
    bool IsTeenageEngineering,
    bool DetectedViaVolume);

internal sealed record StorageVolume(string Name, string RootPath, long TotalBytes, long FreeBytes)
{
    public long UsedBytes => Math.Max(0, TotalBytes - FreeBytes);
    public string TotalText => FormatBytes(TotalBytes);
    public string UsedText => FormatBytes(UsedBytes);
    public string FreeText => FormatBytes(FreeBytes);

    private static string FormatBytes(long bytes) =>
        string.Format(CultureInfo.CurrentCulture, "{0:0.#} MB", bytes / 1024d / 1024d);
}

internal sealed record ScanResult(
    IReadOnlyList<TeDevice> Devices,
    IReadOnlyList<StorageVolume> Volumes,
    string? UsbError,
    string? VolumeError);

internal static class DeviceRecognition
{
    private static readonly string[] KnownModels =
    [
        "op-1", "op-z", "op-xy", "ep-133", "ep-1320", "ep-136", "ep-40",
        "ep-35", "bc-1", "tp-7", "tx-6", "cm-15", "ob-4", "po-80"
    ];

    private static readonly Dictionary<string, string> VolumeModels = new(StringComparer.OrdinalIgnoreCase)
    {
        ["op-xy"] = "OP-XY",
        ["op-z"] = "OP-Z",
        ["op-1"] = "OP-1",
        ["op-1 field"] = "OP-1 field",
        ["ep-133"] = "EP-133 K.O. II",
        ["ep-1320"] = "EP-1320 medieval",
        ["ep-136"] = "EP-136 K.O.-sidekick",
        ["ep-40"] = "EP-40",
        ["ep-35"] = "EP-35",
        ["tp-7"] = "TP-7",
        ["tx-6"] = "TX-6",
        ["cm-15"] = "CM-15",
        ["ob-4"] = "OB-4"
    };

    public static bool IsTeenageEngineering(string name, string? manufacturer)
    {
        var value = Normalize($"{manufacturer} {name}");
        return value.Contains("teenage engineering", StringComparison.Ordinal)
            || KnownModels.Any(value.Contains);
    }

    public static string DisplayModel(string name)
    {
        var value = Normalize(name);
        if (value.Contains("ep-133", StringComparison.Ordinal)) return "EP-133 K.O. II";
        if (value.Contains("ep-1320", StringComparison.Ordinal)) return "EP-1320 medieval";
        if (value.Contains("ep-136", StringComparison.Ordinal)) return "EP-136 K.O.-sidekick";
        if (value.Contains("ep-40", StringComparison.Ordinal)) return "EP-40";
        if (value.Contains("ep-35", StringComparison.Ordinal)) return "EP-35";
        if (value.Contains("op-xy", StringComparison.Ordinal)) return "OP-XY";
        if (value.Contains("op-z", StringComparison.Ordinal)) return "OP-Z";
        if (value.Contains("op-1", StringComparison.Ordinal)) return "OP-1";
        return name;
    }

    public static TeDevice? FromVolume(string name, string rootPath)
    {
        var key = Normalize(name);
        if (!VolumeModels.TryGetValue(key, out var model)) return null;
        return new TeDevice(model, "Модель по имени внешнего тома", rootPath, "—", "—", true, true);
    }

    public static (string VendorId, string ProductId) ReadUsbIds(string? instanceId)
    {
        if (string.IsNullOrEmpty(instanceId)) return ("—", "—");
        var vendor = Regex.Match(instanceId, @"VID_([0-9A-F]{4})", RegexOptions.IgnoreCase);
        var product = Regex.Match(instanceId, @"PID_([0-9A-F]{4})", RegexOptions.IgnoreCase);
        return (
            vendor.Success ? vendor.Groups[1].Value.ToUpperInvariant() : "—",
            product.Success ? product.Groups[1].Value.ToUpperInvariant() : "—");
    }

    private static string Normalize(string value) =>
        value.ToLowerInvariant()
            .Replace('–', '-')
            .Replace('—', '-')
            .Trim();
}

internal static class DeviceScanner
{
    private const string UsbQuery =
        "$ErrorActionPreference='Stop'; " +
        "Get-CimInstance -ClassName Win32_PnPEntity -Filter \"PNPClass = 'USB'\" | " +
        "Select-Object Name,Manufacturer,PNPDeviceID | ConvertTo-Json -Compress";

    public static ScanResult Scan()
    {
        var devices = new List<TeDevice>();
        var volumes = new List<StorageVolume>();
        string? usbError = null;
        string? volumeError = null;

        try
        {
            devices.AddRange(ReadUsbDevices());
        }
        catch (Exception error)
        {
            usbError = $"USB: {error.Message}";
        }

        try
        {
            volumes.AddRange(ReadVolumes(out volumeError));
        }
        catch (Exception error)
        {
            volumeError = $"Диски: {error.Message}";
        }

        var usbModels = new HashSet<string>(
            devices.Where(device => device.IsTeenageEngineering)
                .Select(device => DeviceRecognition.DisplayModel(device.Name)),
            StringComparer.OrdinalIgnoreCase);

        foreach (var volume in volumes)
        {
            var device = DeviceRecognition.FromVolume(volume.Name, volume.RootPath);
            if (device is not null && !usbModels.Contains(device.Name))
                devices.Add(device);
        }

        return new ScanResult(
            devices.OrderByDescending(device => device.IsTeenageEngineering)
                .ThenBy(device => device.Name, StringComparer.CurrentCultureIgnoreCase)
                .ToArray(),
            volumes.OrderBy(volume => volume.Name, StringComparer.CurrentCultureIgnoreCase).ToArray(),
            usbError,
            volumeError);
    }

    private static IEnumerable<TeDevice> ReadUsbDevices()
    {
        using var process = new Process
        {
            StartInfo = new ProcessStartInfo
            {
                FileName = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.System), "WindowsPowerShell", "v1.0", "powershell.exe"),
                UseShellExecute = false,
                RedirectStandardOutput = true,
                RedirectStandardError = true,
                CreateNoWindow = true
            }
        };
        process.StartInfo.ArgumentList.Add("-NoProfile");
        process.StartInfo.ArgumentList.Add("-NonInteractive");
        process.StartInfo.ArgumentList.Add("-Command");
        process.StartInfo.ArgumentList.Add(UsbQuery);

        if (!process.Start()) throw new InvalidOperationException("Не удалось запустить Windows PowerShell.");
        var outputTask = process.StandardOutput.ReadToEndAsync();
        var errorTask = process.StandardError.ReadToEndAsync();
        if (!process.WaitForExit(20_000))
        {
            process.Kill(true);
            throw new TimeoutException("Windows не ответила на запрос USB за 20 секунд.");
        }

        Task.WaitAll(outputTask, errorTask);
        if (process.ExitCode != 0)
            throw new InvalidOperationException(string.IsNullOrWhiteSpace(errorTask.Result)
                ? $"PowerShell завершился с кодом {process.ExitCode}."
                : errorTask.Result.Trim());

        if (string.IsNullOrWhiteSpace(outputTask.Result)) return [];
        using var json = JsonDocument.Parse(outputTask.Result);
        if (json.RootElement.ValueKind is JsonValueKind.Null or JsonValueKind.Undefined) return [];
        var entries = json.RootElement.ValueKind == JsonValueKind.Array
            ? json.RootElement.EnumerateArray().ToArray()
            : [json.RootElement];

        return entries.Select(entry =>
        {
            var name = ReadProperty(entry, "Name");
            var manufacturer = ReadProperty(entry, "Manufacturer");
            var instanceId = ReadProperty(entry, "PNPDeviceID");
            var (vendor, product) = DeviceRecognition.ReadUsbIds(instanceId);
            return new TeDevice(
                string.IsNullOrWhiteSpace(name) ? "USB-устройство" : name,
                manufacturer,
                instanceId,
                vendor,
                product,
                DeviceRecognition.IsTeenageEngineering(name, manufacturer),
                false);
        }).ToArray();
    }

    private static IEnumerable<StorageVolume> ReadVolumes(out string? warnings)
    {
        var volumes = new List<StorageVolume>();
        var failures = new List<string>();
        foreach (var drive in DriveInfo.GetDrives())
        {
            try
            {
                if (!drive.IsReady) continue;
                var name = drive.VolumeLabel;
                var isRecognized = DeviceRecognition.FromVolume(name, drive.Name) is not null;
                if (drive.DriveType != DriveType.Removable && !isRecognized) continue;
                volumes.Add(new StorageVolume(name, drive.Name, drive.TotalSize, drive.AvailableFreeSpace));
            }
            catch (IOException error)
            {
                failures.Add($"{drive.Name}: {error.Message}");
            }
            catch (UnauthorizedAccessException error)
            {
                failures.Add($"{drive.Name}: {error.Message}");
            }
        }
        warnings = failures.Count == 0 ? null : $"Не удалось прочитать некоторые диски: {string.Join("; ", failures)}";
        return volumes;
    }

    private static string ReadProperty(JsonElement entry, string name) =>
        entry.TryGetProperty(name, out var value) && value.ValueKind == JsonValueKind.String
            ? value.GetString() ?? string.Empty
            : string.Empty;
}
