using System.Diagnostics;
using System.Drawing;

namespace TEDesk.Windows;

internal sealed class MainForm : Form
{
    private static readonly Color Canvas = Color.FromArgb(245, 245, 239);
    private static readonly Color Card = Color.White;
    private static readonly Color Ink = Color.FromArgb(35, 54, 46);
    private static readonly Color Olive = Color.FromArgb(99, 119, 60);
    private static readonly Color Muted = Color.FromArgb(111, 116, 105);

    private readonly ListView devices = CreateListView(("Устройство", 220), ("Производитель", 190), ("USB ID", 145));
    private readonly ListView volumes = CreateListView(("Том", 150), ("Занято", 110), ("Всего", 110), ("Свободно", 110));
    private readonly ListView sourceResults = CreateListView(("Источник", 90), ("Публикация / проект", 330), ("Описание", 450));
    private readonly Label status = new() { AutoSize = true, ForeColor = Muted };
    private readonly Label selectedDevice = new() { AutoSize = true, ForeColor = Ink, Font = new Font("Segoe UI", 13, FontStyle.Bold) };
    private readonly Label firmwareResult = new() { AutoSize = true, ForeColor = Olive };
    private readonly Button firmwareButton = new() { Text = "Проверить официальную страницу", AutoSize = true, Enabled = false };
    private readonly Button refreshButton = new() { Text = "Обновить", AutoSize = true };
    private readonly Button communityButton = new() { Text = "Искать GitHub и Reddit", AutoSize = true };
    private readonly LinkLabel firmwareLink = new() { AutoSize = true, Visible = false, Text = "Открыть официальные загрузки" };
    private readonly LinkLabel redditFallback = new() { AutoSize = true, Visible = false, Text = "Открыть поиск Reddit в браузере" };
    private readonly Label communityStatus = new() { AutoSize = true, ForeColor = Muted };
    private TeDevice? currentDevice;
    private bool scanning;

    public MainForm()
    {
        Text = "TE Desk";
        StartPosition = FormStartPosition.CenterScreen;
        MinimumSize = new Size(960, 680);
        Size = new Size(1180, 800);
        BackColor = Canvas;
        Font = new Font("Segoe UI", 9);

        var root = new TableLayoutPanel
        {
            Dock = DockStyle.Fill,
            ColumnCount = 1,
            RowCount = 3,
            Padding = new Padding(18),
            BackColor = Canvas
        };
        root.RowStyles.Add(new RowStyle(SizeType.Absolute, 58));
        root.RowStyles.Add(new RowStyle(SizeType.Percent, 100));
        root.RowStyles.Add(new RowStyle(SizeType.Absolute, 30));
        root.Controls.Add(BuildHeader(), 0, 0);
        root.Controls.Add(BuildTabs(), 0, 1);
        root.Controls.Add(status, 0, 2);
        Controls.Add(root);

        refreshButton.Click += async (_, _) => await RefreshDevicesAsync();
        devices.SelectedIndexChanged += (_, _) => SelectDevice();
        devices.ItemActivate += (_, _) => SelectDevice();
        firmwareButton.Click += async (_, _) => await CheckFirmwareAsync();
        firmwareLink.LinkClicked += (_, _) => OpenUrl(firmwareLink.Tag as string);
        communityButton.Click += async (_, _) => await SearchCommunityAsync();
        redditFallback.LinkClicked += (_, _) => OpenUrl(redditFallback.Tag as string);
        sourceResults.ItemActivate += (_, _) =>
        {
            if (sourceResults.SelectedItems.Count > 0)
                OpenUrl(sourceResults.SelectedItems[0].Tag as string);
        };
        Load += async (_, _) => await RefreshDevicesAsync();
    }

    private Control BuildHeader()
    {
        var header = new Panel { Dock = DockStyle.Fill, BackColor = Canvas };
        var title = new Label
        {
            Text = "TE  DESK",
            AutoSize = true,
            Font = new Font("Segoe UI", 18, FontStyle.Bold),
            ForeColor = Ink,
            Location = new Point(2, 8)
        };
        refreshButton.Anchor = AnchorStyles.Top | AnchorStyles.Right;
        refreshButton.Location = new Point(ClientSize.Width - refreshButton.Width - 48, 12);
        header.Resize += (_, _) => refreshButton.Left = header.ClientSize.Width - refreshButton.Width;
        header.Controls.Add(title);
        header.Controls.Add(refreshButton);
        return header;
    }

    private Control BuildTabs()
    {
        var tabs = new TabControl { Dock = DockStyle.Fill };
        tabs.TabPages.Add(new TabPage("Обзор") { BackColor = Canvas, Controls = { BuildOverview() } });
        tabs.TabPages.Add(new TabPage("Сообщество") { BackColor = Canvas, Controls = { BuildCommunity() } });
        tabs.TabPages.Add(new TabPage("Ссылки TE") { BackColor = Canvas, Controls = { BuildOfficialLinks() } });
        return tabs;
    }

    private Control BuildOverview()
    {
        var layout = new TableLayoutPanel
        {
            Dock = DockStyle.Fill,
            ColumnCount = 2,
            RowCount = 2,
            Padding = new Padding(8),
            BackColor = Canvas
        };
        layout.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 64));
        layout.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 36));
        layout.RowStyles.Add(new RowStyle(SizeType.Percent, 57));
        layout.RowStyles.Add(new RowStyle(SizeType.Percent, 43));

        layout.Controls.Add(CreateCard("USB-устройства", devices), 0, 0);
        layout.Controls.Add(CreateCard("Смонтированные внешние тома", volumes), 0, 1);

        var details = new FlowLayoutPanel
        {
            Dock = DockStyle.Fill,
            FlowDirection = FlowDirection.TopDown,
            WrapContents = false,
            AutoScroll = true,
            BackColor = Card,
            Padding = new Padding(18)
        };
        details.Controls.Add(Heading("Выбранное устройство"));
        details.Controls.Add(selectedDevice);
        details.Controls.Add(new Label
        {
            AutoSize = true,
            MaximumSize = new Size(340, 0),
            ForeColor = Muted,
            Text = "Показываем только сведения, которые Windows предоставляет через USB и смонтированные внешние тома. Файлы и прошивка не изменяются."
        });
        details.Controls.Add(Spacer(12));
        details.Controls.Add(Heading("Прошивка"));
        details.Controls.Add(firmwareButton);
        details.Controls.Add(firmwareResult);
        details.Controls.Add(firmwareLink);
        details.Controls.Add(Spacer(12));
        details.Controls.Add(Heading("OP–XY: подключение"));
        details.Controls.Add(new Label
        {
            AutoSize = true,
            MaximumSize = new Size(340, 0),
            ForeColor = Muted,
            Text = "Для проектов и сэмплов: обычный режим → COM → M4 (MTP) и Field Kit. Диск появляется в TE BOOT для процедуры обновления; это другой режим."
        });
        details.Controls.Add(CreateLink("Официальная инструкция MTP", "https://teenage.engineering/guides/op-xy/com#mtp"));
        layout.Controls.Add(CreateCard("Информация и действия", details), 1, 0);
        layout.SetRowSpan(layout.GetControlFromPosition(1, 0)!, 2);
        return layout;
    }

    private Control BuildCommunity()
    {
        var layout = new TableLayoutPanel
        {
            Dock = DockStyle.Fill,
            ColumnCount = 1,
            RowCount = 3,
            Padding = new Padding(12),
            BackColor = Canvas
        };
        layout.RowStyles.Add(new RowStyle(SizeType.Absolute, 54));
        layout.RowStyles.Add(new RowStyle(SizeType.Absolute, 54));
        layout.RowStyles.Add(new RowStyle(SizeType.Percent, 100));

        var searchPanel = new FlowLayoutPanel { Dock = DockStyle.Fill, WrapContents = false, BackColor = Canvas };
        searchPanel.Controls.Add(communityButton);
        searchPanel.Controls.Add(communityStatus);
        redditFallback.Margin = new Padding(12, 8, 3, 3);
        searchPanel.Controls.Add(redditFallback);
        layout.Controls.Add(searchPanel, 0, 0);
        layout.Controls.Add(new Label
        {
            Text = "Ищем открытые репозитории и обсуждения по выбранной модели. Поиск запускается только по нажатию.",
            Dock = DockStyle.Fill,
            ForeColor = Muted,
            TextAlign = ContentAlignment.MiddleLeft
        }, 0, 1);
        layout.Controls.Add(sourceResults, 0, 2);
        return layout;
    }

    private Control BuildOfficialLinks()
    {
        var panel = new FlowLayoutPanel
        {
            Dock = DockStyle.Fill,
            FlowDirection = FlowDirection.TopDown,
            WrapContents = false,
            AutoScroll = true,
            Padding = new Padding(24),
            BackColor = Canvas
        };
        panel.Controls.Add(Heading("Teenage Engineering"));
        panel.Controls.Add(CreateLink("Каталог устройств", "https://teenage.engineering/products"));
        panel.Controls.Add(CreateLink("Загрузки и обновления", "https://teenage.engineering/downloads"));
        panel.Controls.Add(CreateLink("Field Kit", "https://apps.apple.com/se/app/field-kit/id1612653346"));
        panel.Controls.Add(CreateLink("Руководство OP–XY: MTP", "https://teenage.engineering/guides/op-xy/com#mtp"));
        panel.Controls.Add(Heading("Поиск по устройствам"));
        foreach (var model in new[] { "OP-XY", "OP-1", "OP-Z", "EP-133", "EP-1320", "TP-7", "TX-6", "CM-15" })
            panel.Controls.Add(CreateLink($"{model} · официальные загрузки", $"https://teenage.engineering/downloads/{PublicSources.DownloadsSlug(model)}"));
        return panel;
    }

    private async Task RefreshDevicesAsync()
    {
        if (scanning) return;
        scanning = true;
        refreshButton.Enabled = false;
        status.Text = "Сканирование USB и внешних томов…";
        devices.Items.Clear();
        volumes.Items.Clear();

        try
        {
            var result = await Task.Run(DeviceScanner.Scan);
            foreach (var device in result.Devices)
            {
                var item = new ListViewItem(device.IsTeenageEngineering
                    ? DeviceRecognition.DisplayModel(device.Name)
                    : device.Name);
                item.SubItems.Add(device.DetectedViaVolume ? "Распознано по метке тома" : device.Manufacturer);
                item.SubItems.Add(device.DetectedViaVolume
                    ? "USB ID недоступен"
                    : $"VID {device.VendorId} · PID {device.ProductId}");
                item.Tag = device;
                devices.Items.Add(item);
            }

            foreach (var volume in result.Volumes)
            {
                var item = new ListViewItem(volume.Name);
                item.SubItems.Add(volume.UsedText);
                item.SubItems.Add(volume.TotalText);
                item.SubItems.Add(volume.FreeText);
                volumes.Items.Add(item);
            }

            if (devices.Items.Count > 0) devices.Items[0].Selected = true;
            var errors = new[] { result.UsbError, result.VolumeError }.Where(error => !string.IsNullOrWhiteSpace(error));
            status.Text = string.Join("  ", errors);
            if (string.IsNullOrWhiteSpace(status.Text))
                status.Text = $"Обновлено {DateTime.Now.ToString("HH:mm:ss")} · {result.Devices.Count} устройств · {result.Volumes.Count} томов";
        }
        catch (Exception error)
        {
            status.Text = $"Не удалось выполнить сканирование: {error.Message}";
        }
        finally
        {
            scanning = false;
            refreshButton.Enabled = true;
        }
    }

    private void SelectDevice()
    {
        currentDevice = devices.SelectedItems.Count > 0 ? devices.SelectedItems[0].Tag as TeDevice : null;
        selectedDevice.Text = currentDevice is null
            ? "Устройство не выбрано"
            : currentDevice.DetectedViaVolume
                ? $"{DeviceRecognition.DisplayModel(currentDevice.Name)} · найден том"
                : DeviceRecognition.DisplayModel(currentDevice.Name);
        firmwareButton.Enabled = currentDevice is not null
            && PublicSources.DownloadsSlug(DeviceRecognition.DisplayModel(currentDevice.Name)) is not null;
        firmwareResult.Text = string.Empty;
        firmwareLink.Visible = false;
    }

    private async Task CheckFirmwareAsync()
    {
        if (currentDevice is null) return;
        firmwareButton.Enabled = false;
        firmwareButton.Text = "Проверяем сайт…";
        try
        {
            var model = DeviceRecognition.DisplayModel(currentDevice.Name);
            var result = await PublicSources.CheckFirmwareAsync(model, CancellationToken.None);
            firmwareResult.Text = result.Summary;
            firmwareLink.Tag = result.Url;
            firmwareLink.Visible = true;
        }
        catch (Exception error)
        {
            firmwareResult.Text = $"Не удалось проверить страницу: {error.Message}";
        }
        finally
        {
            firmwareButton.Text = "Проверить официальную страницу";
            firmwareButton.Enabled = currentDevice is not null
                && PublicSources.DownloadsSlug(DeviceRecognition.DisplayModel(currentDevice.Name)) is not null;
        }
    }

    private async Task SearchCommunityAsync()
    {
        communityButton.Enabled = false;
        redditFallback.Visible = false;
        sourceResults.Items.Clear();
        communityStatus.Text = "Ищем…";
        var query = currentDevice is null ? "Teenage Engineering" : DeviceRecognition.DisplayModel(currentDevice.Name);
        var errors = new List<string>();
        try
        {
            var repositories = await PublicSources.SearchGitHubAsync(query, CancellationToken.None);
            AddSourceResults(repositories);
            if (repositories.Count == 0) errors.Add("GitHub: результатов нет.");
        }
        catch (Exception error)
        {
            errors.Add($"GitHub: {error.Message}");
        }

        try
        {
            var posts = await PublicSources.SearchRedditAsync(query, CancellationToken.None);
            AddSourceResults(posts);
            if (posts.Count == 0) errors.Add("Reddit: результатов нет.");
        }
        catch (RedditBlockedException error)
        {
            errors.Add(error.Message);
            redditFallback.Tag = error.SearchUrl;
            redditFallback.Visible = true;
        }
        catch (Exception error)
        {
            errors.Add($"Reddit: {error.Message}");
        }

        communityStatus.Text = string.Join("  ", errors);
        communityButton.Enabled = true;
    }

    private void AddSourceResults(IEnumerable<SourceResult> results)
    {
        foreach (var result in results)
        {
            var item = new ListViewItem(result.Source);
            item.SubItems.Add(result.Title);
            item.SubItems.Add(result.Detail);
            item.Tag = result.Url;
            sourceResults.Items.Add(item);
        }
    }

    private void OpenUrl(string? url)
    {
        if (string.IsNullOrWhiteSpace(url)) return;
        try
        {
            Process.Start(new ProcessStartInfo(url) { UseShellExecute = true });
        }
        catch (Exception error)
        {
            status.Text = $"Не удалось открыть ссылку: {error.Message}";
        }
    }

    private static ListView CreateListView(params (string Name, int Width)[] columns)
    {
        var list = new ListView
        {
            Dock = DockStyle.Fill,
            View = View.Details,
            FullRowSelect = true,
            GridLines = true,
            MultiSelect = false,
            HideSelection = false,
            BackColor = Card,
            ForeColor = Ink
        };
        foreach (var (name, width) in columns) list.Columns.Add(name, width);
        return list;
    }

    private static Control CreateCard(string title, Control content)
    {
        var group = new GroupBox
        {
            Text = title,
            Dock = DockStyle.Fill,
            BackColor = Card,
            ForeColor = Ink,
            Padding = new Padding(10)
        };
        content.Dock = DockStyle.Fill;
        group.Controls.Add(content);
        return group;
    }

    private static Label Heading(string text) => new()
    {
        Text = text,
        AutoSize = true,
        ForeColor = Ink,
        Font = new Font("Segoe UI", 10, FontStyle.Bold),
        Margin = new Padding(3, 12, 3, 6)
    };

    private static Control Spacer(int height) => new Panel { Height = height, Width = 12 };

    private static LinkLabel CreateLink(string text, string url)
    {
        var link = new LinkLabel
        {
            Text = text,
            AutoSize = true,
            Tag = url,
            LinkColor = Olive,
            Margin = new Padding(3, 5, 3, 5)
        };
        link.LinkClicked += (_, _) =>
        {
            try
            {
                Process.Start(new ProcessStartInfo(url) { UseShellExecute = true });
            }
            catch
            {
                MessageBox.Show($"Не удалось открыть ссылку:\n{url}", "TE Desk", MessageBoxButtons.OK, MessageBoxIcon.Warning);
            }
        };
        return link;
    }
}
