import AppKit
import Combine
import Foundation
import SwiftUI

@main
struct TEDeskApp: App {
    var body: some Scene {
        WindowGroup("TE Desk") {
            ContentView()
                .frame(minWidth: 920, minHeight: 680)
        }
        .defaultSize(width: 1180, height: 820)
    }
}

enum DeskSection: String, CaseIterable, Identifiable {
    case overview = "Обзор"
    case apps = "Приложения"
    case community = "Сообщество"
    case catalog = "Каталог TE"

    var id: String { rawValue }
    var symbol: String {
        switch self {
        case .overview: "externaldrive"
        case .apps: "sparkles"
        case .community: "bubble.left.and.bubble.right"
        case .catalog: "square.grid.2x2"
        }
    }
}

struct OfficialProduct: Identifiable {
    let name: String
    let slug: String
    let hasOSDownloads: Bool

    var id: String { slug }
    var productURL: URL { URL(string: "https://teenage.engineering/products/\(slug)")! }
    var downloadsURL: URL { URL(string: "https://teenage.engineering/downloads/\(slug)")! }
}

struct OfficialApplication: Identifiable {
    let name: String
    let platform: String
    let detail: String
    let path: String
    var id: String { name + platform }
    var url: URL { URL(string: path.hasPrefix("https://") ? path : "https://teenage.engineering\(path)")! }
}

enum OfficialApplicationCatalog {
    static let apps: [OfficialApplication] = [
        .init(name: "Update Utility", platform: "WEB", detail: "Официальное обновление поддерживаемых устройств", path: "/apps/update"),
        .init(name: "EP Sample Tool", platform: "WEB", detail: "Работа с семплами EP-серии", path: "/apps/ep-sample-tool"),
        .init(name: "Drum Utility", platform: "WEB", detail: "Официальная веб-утилита", path: "/apps/drum-utility"),
        .init(name: "Field Kit", platform: "macOS", detail: "Приложение-компаньон", path: "https://apps.apple.com/se/app/field-kit/id1612653346"),
        .init(name: "OP–Z", platform: "macOS", detail: "Официальное приложение-компаньон", path: "https://apps.apple.com/app/op-z/id1098190457"),
        .init(name: "TP–7", platform: "iOS", detail: "Официальное приложение-компаньон", path: "https://apps.apple.com/app/tp-7/id6449426174"),
        .init(name: "TP–7", platform: "Android", detail: "Официальное приложение-компаньон", path: "https://play.google.com/store/apps/details?id=com.teenageengineering.tp7"),
        .init(name: "OP–Z", platform: "iOS", detail: "Официальное приложение-компаньон", path: "https://apps.apple.com/app/op-z/id1088232296"),
        .init(name: "OP–Z", platform: "Android", detail: "Официальное приложение-компаньон", path: "https://play.google.com/store/apps/details?id=com.teenageengineering.te012"),
        .init(name: "Orthoplay", platform: "iOS", detail: "Управление OD-11 и OB-4", path: "https://apps.apple.com/app/orthoplay/id582616765"),
        .init(name: "Orthoplay", platform: "Android", detail: "Управление OD-11 и OB-4", path: "https://play.google.com/store/apps/details?id=com.teenageengineering.orthoplay")
    ]
}

struct OfficialFirmwareInfo: Sendable {
    let deviceName: String
    let versions: [String]
    let downloadsPage: URL

    var versionSummary: String {
        guard !versions.isEmpty else { return "На странице не удалось распознать номер версии." }
        if deviceName == "OP-1", versions.count >= 2 {
            return "OP–1 field \(versions[0]) · OP–1 original \(versions[1])"
        }
        return versions[0]
    }
}

enum OfficialProductCatalog {
    static let products: [OfficialProduct] = [
        .init(name: "EP/BC–1", slug: "bc-1", hasOSDownloads: true),
        .init(name: "LIFE IS FANTASTIC! · EP–35", slug: "ep-35", hasOSDownloads: true),
        .init(name: "APC–2", slug: "apc-2", hasOSDownloads: false),
        .init(name: "SINUS TRANSMISSION COMPLETED", slug: "sinus-transmission-completed", hasOSDownloads: false),
        .init(name: "EP–133 K.O. II", slug: "ep-133", hasOSDownloads: true),
        .init(name: "K.O.–SIDEKICK · EP–136", slug: "ep-136", hasOSDownloads: true),
        .init(name: "riddim n ting · EP–40", slug: "ep-40", hasOSDownloads: true),
        .init(name: "field system™", slug: "field-system", hasOSDownloads: false),
        .init(name: "OP–XY", slug: "op-xy", hasOSDownloads: true),
        .init(name: "EP–1320 medieval", slug: "ep-1320", hasOSDownloads: true),
        .init(name: "pocket operators", slug: "po", hasOSDownloads: false),
        .init(name: "TP–7", slug: "tp-7", hasOSDownloads: true),
        .init(name: "OB–4", slug: "ob-4", hasOSDownloads: false),
        .init(name: "CM–15", slug: "cm-15", hasOSDownloads: true),
        .init(name: "TX–6", slug: "tx-6", hasOSDownloads: true),
        .init(name: "OP–1 field", slug: "op-1", hasOSDownloads: true),
        .init(name: "field accessories", slug: "field-accessories", hasOSDownloads: false),
        .init(name: "choir", slug: "choir", hasOSDownloads: true),
        .init(name: "field desk", slug: "field-desk", hasOSDownloads: false),
        .init(name: "computer–1", slug: "computer-1", hasOSDownloads: false),
        .init(name: "grip car", slug: "grip-car", hasOSDownloads: false),
        .init(name: "ortho remote", slug: "orthoremote", hasOSDownloads: false),
        .init(name: "OD-11", slug: "od-11", hasOSDownloads: false),
        .init(name: "OP–Z", slug: "op-z", hasOSDownloads: true),
        .init(name: "pocket operator modular", slug: "po/modular", hasOSDownloads: false),
        .init(name: "OP–1 original", slug: "op-1/original", hasOSDownloads: true),
        .init(name: "PO–80", slug: "po-80", hasOSDownloads: false)
    ]
}

struct USBDevice: Identifiable, Equatable, Sendable {
    let productName: String
    let manufacturer: String
    let vendorID: String
    let productID: String
    let locationID: String
    let detectedViaVolume: Bool

    var id: String { "\(locationID)-\(vendorID)-\(productID)-\(productName)" }
    var isTeenageEngineering: Bool {
        let value = "\(manufacturer) \(productName)"
            .lowercased()
            .replacingOccurrences(of: "–", with: "-")
        let knownModels = [
            "op-1", "op-z", "op-xy", "ep-133", "ep-1320", "ep-136", "ep-40",
            "ep-35", "bc-1", "tp-7", "tx-6", "cm-15", "ob-4", "po-80"
        ]
        return value.contains("teenage engineering")
            || knownModels.contains(where: value.contains)
    }

    var displayModel: String {
        let value = productName.lowercased().replacingOccurrences(of: "–", with: "-")
        if value.contains("ep-133") { return "EP-133 K.O. II" }
        if value.contains("ep-1320") { return "EP-1320 medieval" }
        if value.contains("ep-136") { return "EP-136 K.O.-sidekick" }
        if value.contains("ep-40") { return "EP-40" }
        if value.contains("ep-35") { return "EP-35" }
        if value.contains("op-xy") { return "OP-XY" }
        if value.contains("op-z") { return "OP-Z" }
        if value.contains("op-1") { return "OP-1" }
        return productName
    }

    init(
        productName: String,
        manufacturer: String,
        vendorID: String,
        productID: String,
        locationID: String,
        detectedViaVolume: Bool = false
    ) {
        self.productName = productName
        self.manufacturer = manufacturer
        self.vendorID = vendorID
        self.productID = productID
        self.locationID = locationID
        self.detectedViaVolume = detectedViaVolume
    }
}

struct StorageVolume: Identifiable, Sendable {
    let name: String
    let path: String
    let totalBytes: Int64
    let availableBytes: Int64

    var id: String { path }
    var usedBytes: Int64 { max(0, totalBytes - availableBytes) }
    var usedFraction: Double {
        guard totalBytes > 0 else { return 0 }
        return min(1, max(0, Double(usedBytes) / Double(totalBytes)))
    }
    var totalText: String { ByteCountFormatter.string(fromByteCount: totalBytes, countStyle: .file) }
    var usedText: String { ByteCountFormatter.string(fromByteCount: usedBytes, countStyle: .file) }
    var availableText: String { ByteCountFormatter.string(fromByteCount: availableBytes, countStyle: .file) }
}

struct ScanSnapshot: Sendable {
    let devices: [USBDevice]
    let volumes: [StorageVolume]
    let volumeScanError: String?
}

struct GitHubRepository: Decodable, Identifiable {
    let full_name: String
    let html_url: String
    let description: String?
    let stargazers_count: Int
    var id: String { full_name }
}

struct GitHubSearchResponse: Decodable {
    let items: [GitHubRepository]
}

struct RedditPost: Decodable, Identifiable {
    let id: String
    let title: String
    let permalink: String
    let score: Int
}

struct RedditSearchResponse: Decodable {
    struct Listing: Decodable {
        struct Child: Decodable {
            let data: RedditPost
        }
        let children: [Child]
    }
    let data: Listing
}

@MainActor
final class DeviceMonitor: ObservableObject {
    @Published private(set) var devices: [USBDevice] = []
    @Published private(set) var volumes: [StorageVolume] = []
    @Published private(set) var isScanning = false
    @Published private(set) var scanError: String?
    @Published private(set) var lastScan: Date?
    @Published var selectedDeviceID: String?
    @Published private(set) var repositories: [GitHubRepository] = []
    @Published private(set) var redditPosts: [RedditPost] = []
    @Published private(set) var sourceMessages: [String] = []
    @Published private(set) var redditSearchURL: URL?
    @Published private(set) var redditSearchFailure: String?
    @Published private(set) var didSearchReddit = false
    @Published private(set) var isSearchingSources = false
    @Published private(set) var volumeScanError: String?
    @Published private(set) var officialFirmwareInfo: OfficialFirmwareInfo?
    @Published private(set) var firmwareCheckError: String?
    @Published private(set) var isCheckingFirmware = false

    var selectedDevice: USBDevice? {
        devices.first(where: { $0.id == selectedDeviceID })
    }

    var connectionStatus: String {
        if let volumeDevice = selectedDevice?.detectedViaVolume == true
            ? selectedDevice
            : devices.first(where: \.detectedViaVolume) {
            return "Том \(volumeDevice.displayModel) найден"
        }
        return devices.isEmpty ? "Устройство не найдено" : "USB найден"
    }

    func refresh() {
        guard !isScanning else { return }
        isScanning = true
        scanError = nil

        Task {
            do {
                let result = try await Task.detached(priority: .utility) {
                    try USBScanner.scan()
                }.value
                devices = result.devices
                volumes = result.volumes
                volumeScanError = result.volumeScanError
                if selectedDeviceID == nil || !devices.contains(where: { $0.id == selectedDeviceID }) {
                    selectedDeviceID = devices.first(where: \.isTeenageEngineering)?.id ?? devices.first?.id
                }
                lastScan = Date()
            } catch {
                scanError = "Не удалось получить список USB-устройств: \(error.localizedDescription)"
            }
            isScanning = false
        }
    }

    func searchSources() {
        guard !isSearchingSources else { return }
        isSearchingSources = true
        sourceMessages = []
        repositories = []
        redditPosts = []
        let searchTerm = selectedDevice?.displayModel ?? "Teenage Engineering"
        redditSearchURL = PublicSources.redditSearchURL(for: searchTerm)
        redditSearchFailure = nil
        didSearchReddit = false

        Task {
            do {
                repositories = try await PublicSources.searchGitHub(for: searchTerm)
                if repositories.isEmpty {
                    sourceMessages.append("GitHub: по запросу «\(searchTerm)» ничего не найдено.")
                }
            } catch {
                sourceMessages.append("GitHub: \(error.localizedDescription)")
            }

            do {
                redditPosts = try await PublicSources.searchReddit(for: searchTerm)
                if redditPosts.isEmpty {
                    sourceMessages.append("Reddit: по запросу «\(searchTerm)» ничего не найдено.")
                }
            } catch {
                if let sourceError = error as? PublicSources.SourceError,
                   case .httpStatus(403) = sourceError {
                    redditSearchFailure = "Reddit API временно отклонил запрос (HTTP 403)."
                } else {
                    redditSearchFailure = "Reddit: \(error.localizedDescription)"
                    sourceMessages.append(redditSearchFailure ?? "Reddit: произошла неизвестная ошибка.")
                }
            }
            didSearchReddit = true
            isSearchingSources = false
        }
    }

    func checkOfficialFirmware() {
        guard let device = selectedDevice else {
            firmwareCheckError = "Сначала подключите USB-устройство."
            return
        }
        guard !isCheckingFirmware else { return }
        isCheckingFirmware = true
        firmwareCheckError = nil
        officialFirmwareInfo = nil

        Task {
            do {
                officialFirmwareInfo = try await OfficialFirmwareChecker.check(device: device)
            } catch {
                firmwareCheckError = error.localizedDescription
            }
            isCheckingFirmware = false
        }
    }
}

enum USBScanner {
    private static let knownVolumeModels = [
        "op-xy": "OP-XY",
        "op-z": "OP-Z",
        "op-1": "OP-1",
        "op-1 field": "OP-1 field",
        "ep-133": "EP-133 K.O. II",
        "ep-1320": "EP-1320 medieval",
        "ep-136": "EP-136 K.O.-sidekick",
        "ep-40": "EP-40",
        "ep-35": "EP-35",
        "tp-7": "TP-7",
        "tx-6": "TX-6",
        "cm-15": "CM-15",
        "ob-4": "OB-4"
    ]

    static func scan() throws -> ScanSnapshot {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/sbin/system_profiler")
        process.arguments = ["SPUSBDataType", "-json"]
        let output = Pipe()
        process.standardOutput = output
        process.standardError = output
        try process.run()
        let data = output.fileHandleForReading.readDataToEndOfFile()
        process.waitUntilExit()

        guard process.terminationStatus == 0 else {
            let detail = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            throw ScanError.systemProfiler(detail.isEmpty ? "system_profiler завершился с кодом \(process.terminationStatus)." : detail)
        }
        guard
            let root = try JSONSerialization.jsonObject(with: data) as? [String: Any],
            let buses = root["SPUSBDataType"] as? [[String: Any]]
        else {
            throw ScanError.invalidUSBResponse
        }

        var discovered: [USBDevice] = []
        for bus in buses {
            collectDevices(in: bus, into: &discovered)
        }
        var seen = Set<String>()
        let usbDevices = discovered
            .filter { seen.insert($0.id).inserted }
        let volumes: [StorageVolume]
        let volumeScanError: String?
        do {
            volumes = try mountedVolumes()
            volumeScanError = nil
        } catch {
            volumes = []
            volumeScanError = error.localizedDescription
        }
        let usbModels = Set(usbDevices.filter(\.isTeenageEngineering).map { modelKey($0.displayModel) })
        let volumeDevices = volumes
            .compactMap { deviceForMountedVolume(name: $0.name, path: $0.path) }
            .filter { !usbModels.contains(modelKey($0.displayModel)) }
        let devices = (usbDevices + volumeDevices).sorted {
            if $0.isTeenageEngineering != $1.isTeenageEngineering {
                return $0.isTeenageEngineering
            }
            return $0.productName.localizedCaseInsensitiveCompare($1.productName) == .orderedAscending
        }

        return ScanSnapshot(devices: devices, volumes: volumes, volumeScanError: volumeScanError)
    }

    static func deviceForMountedVolume(name: String, path: String) -> USBDevice? {
        let modelName = name
            .lowercased()
            .replacingOccurrences(of: "–", with: "-")
            .replacingOccurrences(of: "—", with: "-")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard let productName = knownVolumeModels[modelName] else { return nil }
        return USBDevice(
            productName: productName,
            manufacturer: "Teenage Engineering · модель по имени тома",
            vendorID: "—",
            productID: "—",
            locationID: "volume:\(path)",
            detectedViaVolume: true
        )
    }

    private static func modelKey(_ model: String) -> String {
        model.lowercased()
            .replacingOccurrences(of: "–", with: "-")
            .replacingOccurrences(of: "—", with: "-")
    }

    private static func collectDevices(in item: [String: Any], into devices: inout [USBDevice]) {
        let name = item["_name"] as? String ?? item["product_id"] as? String
        let manufacturer = item["manufacturer"] as? String ?? ""
        if let name, item["vendor_id"] != nil || item["product_id"] != nil {
            devices.append(
                USBDevice(
                    productName: name,
                    manufacturer: manufacturer,
                    vendorID: item["vendor_id"] as? String ?? "—",
                    productID: item["product_id"] as? String ?? "—",
                    locationID: item["location_id"] as? String ?? name
                )
            )
        }
        if let children = item["_items"] as? [[String: Any]] {
            children.forEach { collectDevices(in: $0, into: &devices) }
        }
    }

    private static func mountedVolumes() throws -> [StorageVolume] {
        let externalMountPoints = try externalVolumeMountPoints()
        let keys: Set<URLResourceKey> = [.volumeNameKey, .volumeTotalCapacityKey, .volumeAvailableCapacityKey]
        let urls = FileManager.default.mountedVolumeURLs(includingResourceValuesForKeys: Array(keys), options: []) ?? []
        return urls.compactMap { url in
            guard externalMountPoints.contains(url.standardizedFileURL.path),
                  let values = try? url.resourceValues(forKeys: keys) else {
                return nil
            }
            guard let total = values.volumeTotalCapacity, let available = values.volumeAvailableCapacity else {
                return nil
            }
            return StorageVolume(
                name: values.volumeName ?? url.lastPathComponent,
                path: url.path,
                totalBytes: Int64(total),
                availableBytes: Int64(available)
            )
        }
        .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    private static func externalVolumeMountPoints() throws -> Set<String> {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/sbin/diskutil")
        process.arguments = ["list", "-plist", "external", "physical"]
        let output = Pipe()
        process.standardOutput = output
        process.standardError = output
        try process.run()
        let data = output.fileHandleForReading.readDataToEndOfFile()
        process.waitUntilExit()

        guard process.terminationStatus == 0 else {
            let detail = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            throw ScanError.diskUtil(detail.isEmpty ? "diskutil завершился с кодом \(process.terminationStatus)." : detail)
        }
        return try externalVolumeMountPoints(from: data)
    }

    static func externalVolumeMountPoints(from data: Data) throws -> Set<String> {
        guard
            let root = try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any],
            let disks = root["AllDisksAndPartitions"] as? [[String: Any]]
        else {
            throw ScanError.invalidDiskUtilResponse
        }

        var mountPoints = Set<String>()
        for disk in disks {
            collectMountPoints(in: disk, into: &mountPoints)
        }
        return mountPoints
    }

    private static func collectMountPoints(in item: [String: Any], into mountPoints: inout Set<String>) {
        if let path = item["MountPoint"] as? String, path.hasPrefix("/Volumes/") {
            mountPoints.insert(URL(fileURLWithPath: path).standardizedFileURL.path)
        }
        if let partitions = item["Partitions"] as? [[String: Any]] {
            partitions.forEach { collectMountPoints(in: $0, into: &mountPoints) }
        }
    }

    enum ScanError: LocalizedError {
        case systemProfiler(String)
        case invalidUSBResponse
        case diskUtil(String)
        case invalidDiskUtilResponse

        var errorDescription: String? {
            switch self {
            case .systemProfiler(let detail): "Ошибка чтения данных USB: \(detail)"
            case .invalidUSBResponse: "macOS вернула данные USB в неизвестном формате."
            case .diskUtil(let detail): "Не удалось прочитать список внешних дисков: \(detail)"
            case .invalidDiskUtilResponse: "macOS вернула список внешних дисков в неизвестном формате."
            }
        }
    }
}

enum PublicSources {
    static func searchGitHub(for device: String) async throws -> [GitHubRepository] {
        var components = URLComponents(string: "https://api.github.com/search/repositories")!
        components.queryItems = [
            URLQueryItem(name: "q", value: "\(device) Teenage Engineering"),
            URLQueryItem(name: "sort", value: "updated"),
            URLQueryItem(name: "per_page", value: "6")
        ]
        let data = try await get(components.url!)
        return try JSONDecoder().decode(GitHubSearchResponse.self, from: data).items
    }

    static func searchReddit(for device: String) async throws -> [RedditPost] {
        var components = URLComponents(string: "https://www.reddit.com/search.json")!
        components.queryItems = [
            URLQueryItem(name: "q", value: "\"\(device)\""),
            URLQueryItem(name: "sort", value: "new"),
            URLQueryItem(name: "limit", value: "8")
        ]
        let data = try await get(components.url!)
        return try JSONDecoder().decode(RedditSearchResponse.self, from: data).data.children.map(\.data)
    }

    static func redditSearchURL(for device: String) -> URL? {
        var components = URLComponents(string: "https://www.reddit.com/search/")!
        components.queryItems = [
            URLQueryItem(name: "q", value: device),
            URLQueryItem(name: "sort", value: "new")
        ]
        return components.url
    }

    static func get(_ url: URL) async throws -> Data {
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 18)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("TE-Desk/0.1 (macOS device companion)", forHTTPHeaderField: "User-Agent")
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let response = response as? HTTPURLResponse else {
            throw SourceError.invalidResponse
        }
        guard (200..<300).contains(response.statusCode) else {
            throw SourceError.httpStatus(response.statusCode)
        }
        return data
    }

    enum SourceError: LocalizedError {
        case invalidResponse
        case httpStatus(Int)

        var errorDescription: String? {
            switch self {
            case .invalidResponse: "Сервер вернул неизвестный ответ."
            case .httpStatus(let code): "Сервис ответил с кодом HTTP \(code)."
            }
        }
    }
}

enum OfficialFirmwareChecker {
    static func check(device: USBDevice) async throws -> OfficialFirmwareInfo {
        guard let slug = downloadsSlug(for: device) else {
            throw FirmwareError.noOfficialDownloads(device.displayModel)
        }
        let url = URL(string: "https://teenage.engineering/downloads/\(slug)")!
        let data = try await PublicSources.get(url)
        guard let html = String(data: data, encoding: .utf8) else {
            throw FirmwareError.invalidPage
        }
        let versions = parseVersions(from: html)
        return OfficialFirmwareInfo(deviceName: device.displayModel, versions: versions, downloadsPage: url)
    }

    static func downloadsSlug(for device: USBDevice) -> String? {
        let name = device.productName.lowercased().replacingOccurrences(of: "–", with: "-")
        if name.contains("op-xy") { return "op-xy" }
        if name.contains("op-z") { return "op-z" }
        if name.contains("op-1") { return "op-1" }
        if name.contains("ep-133") { return "ep-133" }
        if name.contains("ep-1320") { return "ep-1320" }
        if name.contains("ep-136") { return "ep-136" }
        if name.contains("ep-40") { return "ep-40" }
        if name.contains("ep-35") { return "ep-35" }
        if name.contains("bc-1") { return "bc-1" }
        if name.contains("tp-7") { return "tp-7" }
        if name.contains("tx-6") { return "tx-6" }
        if name.contains("cm-15") { return "cm-15" }
        if name.contains("choir") { return "choir" }
        return nil
    }

    static func parseVersions(from html: String) -> [String] {
        var text = html
        text = text.replacingOccurrences(of: "(?is)<script\\b[^>]*>.*?</script>", with: " ", options: .regularExpression)
        text = text.replacingOccurrences(of: "(?is)<style\\b[^>]*>.*?</style>", with: " ", options: .regularExpression)
        text = text.replacingOccurrences(of: "<[^>]+>", with: " ", options: .regularExpression)
        for (entity, value) in [
            ("&nbsp;", " "), ("&#160;", " "), ("&amp;", "&"),
            ("&ndash;", "–"), ("&mdash;", "—"), ("&quot;", "\"")
        ] {
            text = text.replacingOccurrences(of: entity, with: value)
        }

        guard let regex = try? NSRegularExpression(
            pattern: "(?<![A-Za-z0-9])(?:[0-9]+\\.)+[0-9]+(?:\\+[0-9]+)?(?![A-Za-z0-9])|(?<![A-Za-z0-9])#[0-9]+(?![0-9])"
        ) else {
            return []
        }
        let range = NSRange(text.startIndex..., in: text)
        var seen = Set<String>()
        return regex.matches(in: text, range: range).compactMap { match in
            guard let matchRange = Range(match.range, in: text) else { return nil }
            let value = String(text[matchRange])
            if value.first != "#", let first = value.split(separator: ".").first,
               first.count == 4, Int(first).map({ (1900...2099).contains($0) }) == true {
                return nil
            }
            guard seen.insert(value).inserted else { return nil }
            return value
        }
        .prefix(4)
        .map { $0 }
    }

    enum FirmwareError: LocalizedError {
        case noOfficialDownloads(String)
        case invalidPage

        var errorDescription: String? {
            switch self {
            case .noOfficialDownloads(let model):
                "Официальная страница загрузок для \(model) не найдена. Откройте каталог производителя."
            case .invalidPage:
                "Официальная страница не вернула читаемый текст."
            }
        }
    }
}

struct ContentView: View {
    @StateObject private var monitor = DeviceMonitor()
    @State private var section: DeskSection = .overview
    @State private var showingConnectionGuide = false
    @State private var manualFirmware = ""

    private var officialGuide: URL {
        guard let device = monitor.selectedDevice,
              let slug = OfficialFirmwareChecker.downloadsSlug(for: device) else {
            return URL(string: "https://teenage.engineering/products")!
        }
        return URL(string: "https://teenage.engineering/downloads/\(slug)")!
    }

    var body: some View {
        HStack(spacing: 0) {
            Sidebar(section: $section, monitor: monitor, showGuide: { showingConnectionGuide = true })
            VStack(spacing: 0) {
                topBar
                Group {
                    switch section {
                    case .overview: overview
                    case .apps: apps
                    case .community: community
                    case .catalog: catalog
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
        }
        .background(Palette.canvas)
        .preferredColorScheme(.light)
        .onChange(of: monitor.selectedDeviceID) { _ in
            if let device = monitor.selectedDevice {
                manualFirmware = UserDefaults.standard.string(forKey: firmwareKey(for: device)) ?? ""
            }
        }
        .task {
            monitor.refresh()
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 12_000_000_000)
                monitor.refresh()
            }
        }
        .sheet(isPresented: $showingConnectionGuide) {
            ConnectionGuide(device: monitor.selectedDevice, officialGuide: officialGuide)
        }
    }

    private var topBar: some View {
        HStack {
            HStack(spacing: 9) {
                Text("Мои устройства").foregroundStyle(Palette.muted)
                Text("/").foregroundStyle(Palette.subtle)
                Text(section == .overview ? (monitor.selectedDevice?.displayModel ?? "Устройства") : section.rawValue)
                    .fontWeight(.semibold)
            }
            .font(.system(size: 12))
            Spacer()
            HStack(spacing: 12) {
                Label(monitor.connectionStatus, systemImage: monitor.devices.isEmpty ? "circle" : "circle.fill")
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundStyle(monitor.devices.isEmpty ? Palette.muted : Palette.olive)
                Button {
                    monitor.refresh()
                } label: {
                    Label(monitor.isScanning ? "Сканирование…" : "Обновить", systemImage: "arrow.clockwise")
                }
                .buttonStyle(QuietButtonStyle())
                .disabled(monitor.isScanning)
            }
        }
        .padding(.horizontal, 27)
        .frame(height: 54)
        .background(Palette.canvas.opacity(0.94))
        .overlay(alignment: .bottom) { Rectangle().fill(Palette.line).frame(height: 1) }
    }

    private var overview: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 17) {
                pageHeading(title: "Всё о вашем устройстве.", subtitle: "Сначала читаем доступные данные. Любые изменения — только по вашему выбору.")
                demoSafetyBanner

                HStack(alignment: .top, spacing: 14) {
                    VStack(spacing: 14) {
                        deviceCard
                        storageCard
                    }
                    VStack(spacing: 14) {
                        firmwareCard
                        connectionCard
                    }
                    .frame(width: 300)
                }
                communityPreview
                privacyFooter
            }
            .padding(26)
            .frame(maxWidth: 1300, alignment: .leading)
            .frame(maxWidth: .infinity, alignment: .center)
        }
    }

    private var apps: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                pageHeading(title: "Приложения и проекты.", subtitle: "Официальные companion-приложения и проекты сообщества. Установку всегда запускаете вы.")
                Text("ОФИЦИАЛЬНЫЕ ПРИЛОЖЕНИЯ")
                    .font(.system(size: 9, design: .monospaced))
                    .tracking(0.7)
                    .foregroundStyle(Palette.subtle)
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 205), spacing: 10)], alignment: .leading, spacing: 10) {
                    ForEach(OfficialApplicationCatalog.apps) { app in
                        Link(destination: app.url) {
                            VStack(alignment: .leading, spacing: 9) {
                                HStack {
                                    Image(systemName: "app.dashed")
                                        .foregroundStyle(Palette.olive)
                                    Spacer()
                                    Text(app.platform)
                                        .font(.system(size: 8, design: .monospaced))
                                        .foregroundStyle(Palette.muted)
                                }
                                Text(app.name)
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundStyle(Palette.ink)
                                Text(app.detail)
                                    .font(.system(size: 9))
                                    .foregroundStyle(Palette.muted)
                                    .lineLimit(2)
                                    .frame(maxWidth: .infinity, minHeight: 25, alignment: .leading)
                                Label("Открыть источник", systemImage: "arrow.up.right")
                                    .font(.system(size: 9, weight: .medium))
                                    .foregroundStyle(Palette.olive)
                            }
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Palette.card)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Palette.line, lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                    }
                }

                Text("ПРОЕКТЫ СООБЩЕСТВА · GITHUB")
                    .font(.system(size: 9, design: .monospaced))
                    .tracking(0.7)
                    .foregroundStyle(Palette.subtle)
                sourceSearchButton
                if !monitor.sourceMessages.isEmpty { sourceMessagesView }
                if monitor.repositories.isEmpty {
                    EmptyPanel(
                        symbol: "shippingbox",
                        title: "Сначала найдём проекты",
                        detail: "Запустите поиск по GitHub. Приложения не устанавливаются автоматически."
                    )
                } else {
                    VStack(spacing: 9) {
                        ForEach(monitor.repositories) { repository in
                            RepositoryRow(repository: repository)
                        }
                    }
                }
                privacyFooter
            }
            .padding(26)
            .frame(maxWidth: 1000, alignment: .leading)
            .frame(maxWidth: .infinity, alignment: .center)
        }
    }

    private var community: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                pageHeading(title: "Опыт сообщества.", subtitle: "Публичные проекты GitHub и обсуждения Reddit — с прямыми ссылками на первоисточники.")
                sourceSearchButton
                if !monitor.sourceMessages.isEmpty { sourceMessagesView }
                Text("ПРОЕКТЫ · GITHUB")
                    .font(.system(size: 9, design: .monospaced))
                    .tracking(0.7)
                    .foregroundStyle(Palette.subtle)
                if monitor.repositories.isEmpty {
                    EmptyPanel(
                        symbol: "chevron.left.forwardslash.chevron.right",
                        title: monitor.isSearchingSources ? "Ищем проекты…" : "Проекты появятся после поиска",
                        detail: "Нажмите «Искать сейчас», чтобы получить актуальные репозитории GitHub."
                    )
                } else {
                    VStack(spacing: 9) {
                        ForEach(monitor.repositories) { repository in
                            RepositoryRow(repository: repository)
                        }
                    }
                }
                Rectangle().fill(Palette.line).frame(height: 1)
                Text("ОБСУЖДЕНИЯ · REDDIT")
                    .font(.system(size: 9, design: .monospaced))
                    .tracking(0.7)
                    .foregroundStyle(Palette.subtle)
                if monitor.redditPosts.isEmpty {
                    if monitor.didSearchReddit {
                        SurfaceCard {
                            VStack(alignment: .leading, spacing: 9) {
                                Text(monitor.redditSearchFailure ?? "Reddit не вернул публикаций по этому запросу.")
                                    .font(.system(size: 11))
                                    .foregroundStyle(Palette.muted)
                                if let url = monitor.redditSearchURL {
                                    Link(destination: url) {
                                        Label("Открыть поиск Reddit в браузере", systemImage: "arrow.up.right")
                                            .font(.system(size: 10, weight: .medium))
                                    }
                                    .foregroundStyle(Palette.olive)
                                }
                            }
                        }
                    } else {
                        EmptyPanel(
                            symbol: "bubble.left.and.bubble.right",
                            title: monitor.isSearchingSources ? "Ищем обсуждения…" : "Обсуждения появятся после поиска",
                            detail: "Reddit проверяется только после нажатия «Искать сейчас»."
                        )
                    }
                } else {
                    VStack(spacing: 9) {
                        ForEach(monitor.redditPosts) { post in
                            RedditRow(post: post)
                        }
                    }
                }
                privacyFooter
            }
            .padding(26)
            .frame(maxWidth: 1000, alignment: .leading)
            .frame(maxWidth: .infinity, alignment: .center)
        }
    }

    private var catalog: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                pageHeading(title: "Устройства Teenage Engineering.", subtitle: "Список сверен с официальным каталогом производителя. Не каждое устройство передаёт данные по USB.")
                HStack(spacing: 10) {
                    Image(systemName: "info.circle").foregroundStyle(Palette.olive)
                    Text("TE Desk обнаруживает USB-устройства через macOS. Наличие модели в каталоге не означает, что она поддерживает USB-передачу данных или обновление прошивки.")
                        .font(.system(size: 10))
                        .foregroundStyle(Palette.muted)
                    Spacer()
                    Link(destination: URL(string: "https://teenage.engineering/products")!) {
                        Label("Каталог производителя", systemImage: "arrow.up.right")
                            .font(.system(size: 10, weight: .medium))
                    }
                    .foregroundStyle(Palette.olive)
                }
                .padding(13)
                .background(Palette.safety)
                .clipShape(RoundedRectangle(cornerRadius: 8))

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 205), spacing: 10)], alignment: .leading, spacing: 10) {
                    ForEach(OfficialProductCatalog.products) { product in
                        VStack(alignment: .leading, spacing: 10) {
                            Image(systemName: "waveform")
                                .font(.system(size: 15))
                                .foregroundStyle(Palette.olive)
                                .frame(width: 31, height: 31)
                                .background(Palette.safety)
                                .clipShape(RoundedRectangle(cornerRadius: 7))
                            Text(product.name)
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(Palette.ink)
                                .lineLimit(2)
                                .frame(maxWidth: .infinity, minHeight: 30, alignment: .leading)
                            HStack {
                                Link(destination: product.productURL) {
                                    Label("Продукт", systemImage: "arrow.up.right")
                                }
                                if product.hasOSDownloads {
                                    Link(destination: product.downloadsURL) {
                                        Label("OS / загрузки", systemImage: "arrow.down.circle")
                                    }
                                    .foregroundStyle(Palette.olive)
                                }
                            }
                            .font(.system(size: 9, weight: .medium))
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Palette.card)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Palette.line, lineWidth: 1))
                    }
                }
                privacyFooter
            }
            .padding(26)
            .frame(maxWidth: 1100, alignment: .leading)
            .frame(maxWidth: .infinity, alignment: .center)
        }
    }

    private func pageHeading(title: String, subtitle: String) -> some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 7) {
                Label("ВАШЕ ОБОРУДОВАНИЕ", systemImage: "circle.fill")
                    .font(.system(size: 9, weight: .regular, design: .monospaced))
                    .tracking(1)
                    .foregroundStyle(Palette.olive)
                Text(title)
                    .font(.system(size: 29, weight: .medium, design: .rounded))
                    .tracking(-1.1)
                    .foregroundStyle(Palette.ink)
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundStyle(Palette.muted)
            }
            Spacer(minLength: 10)
            if section == .overview {
                Button {
                    showingConnectionGuide = true
                } label: {
                    Label("Как подключить", systemImage: "cable.connector")
                }
                .buttonStyle(DarkButtonStyle())
            }
        }
        .padding(.bottom, 2)
    }

    private var demoSafetyBanner: some View {
        HStack(spacing: 10) {
            Image(systemName: "lock.shield")
                .foregroundStyle(Palette.olive)
            VStack(alignment: .leading, spacing: 2) {
                Text("Безопасный режим · только чтение")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Palette.ink)
                Text("TE Desk не записывает файлы и не обновляет прошивку устройства.")
                    .font(.system(size: 10))
                    .foregroundStyle(Palette.muted)
            }
            Spacer()
            Text("ЛОКАЛЬНО")
                .font(.system(size: 9, design: .monospaced))
                .foregroundStyle(Palette.olive)
        }
        .padding(.horizontal, 13)
        .padding(.vertical, 10)
        .background(Palette.safety)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var deviceCard: some View {
        SurfaceCard {
            VStack(alignment: .leading, spacing: 15) {
                CardHeading(title: "Найденные устройства", detail: monitor.lastScan.map { "Обновлено \( $0.formatted(date: .omitted, time: .shortened) )" } ?? "Ожидаем первое сканирование", symbol: "cable.connector")
                if let error = monitor.scanError {
                    ErrorMessage(text: error)
                } else if monitor.devices.isEmpty {
                    EmptyPanel(
                        symbol: "cable.connector",
                        title: monitor.isScanning ? "Ищем устройства…" : "Устройства не найдены",
                        detail: monitor.isScanning
                            ? "Читаем список USB-устройств и внешних томов macOS."
                            : "Подключите устройство USB-кабелем с передачей данных и нажмите «Обновить». Для OP–XY режим MTP открывается через COM → M4."
                    )
                } else {
                    VStack(spacing: 7) {
                        ForEach(monitor.devices) { device in
                            USBDeviceRow(
                                device: device,
                                isSelected: device.id == monitor.selectedDeviceID,
                                onSelect: { select(device) }
                            )
                        }
                    }
                }
                HStack(spacing: 7) {
                    Image(systemName: "info.circle")
                    Text("Если USB-ID недоступен, поддерживаемая модель может быть распознана по точному имени внешнего тома.")
                }
                .font(.system(size: 9))
                .foregroundStyle(Palette.muted)
            }
        }
    }

    private var storageCard: some View {
        SurfaceCard {
            VStack(alignment: .leading, spacing: 14) {
                CardHeading(title: "Смонтированные тома", detail: "Информация macOS · чтение", symbol: "externaldrive")
                if let error = monitor.volumeScanError {
                    ErrorMessage(text: error)
                }
                if monitor.volumes.isEmpty {
                    if monitor.volumeScanError == nil {
                        Text("Внешние физические тома не смонтированы. Системные разделы и образы дисков скрыты.")
                            .font(.system(size: 11))
                            .foregroundStyle(Palette.muted)
                            .padding(.vertical, 5)
                    }
                } else {
                    ForEach(monitor.volumes) { volume in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Label(volume.name, systemImage: "externaldrive.fill")
                                    .font(.system(size: 11, weight: .semibold))
                                    .lineLimit(1)
                                Spacer()
                                Text("\(volume.usedText) из \(volume.totalText)")
                                    .font(.system(size: 10, design: .monospaced))
                                    .foregroundStyle(Palette.muted)
                            }
                            ProgressView(value: volume.usedFraction)
                                .tint(Palette.olive)
                            Text("Свободно \(volume.availableText) · \(volume.path)")
                                .font(.system(size: 9))
                                .foregroundStyle(Palette.muted)
                                .lineLimit(1)
                                .help(volume.path)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
    }

    private var firmwareCard: some View {
        SurfaceCard {
            VStack(alignment: .leading, spacing: 13) {
                CardHeading(title: "Прошивка", detail: "Официальный сайт производителя", symbol: "arrow.triangle.2.circlepath")
                VStack(alignment: .leading, spacing: 7) {
                    Text("ВЕРСИЯ УСТРОЙСТВА")
                        .font(.system(size: 8, design: .monospaced))
                        .tracking(0.7)
                        .foregroundStyle(Palette.subtle)
                    Text(manualFirmware.isEmpty ? "Не определена по USB" : "Ваша версия: \(manualFirmware)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Palette.ink)
                    Text("Не сравниваем автоматически, если устройство не отдаёт версию через USB.")
                        .font(.system(size: 10))
                        .foregroundStyle(Palette.muted)
                }
                TextField("Добавить версию вручную (необязательно)", text: $manualFirmware)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(size: 10))
                    .onChange(of: manualFirmware) { value in saveManualFirmware(value) }
                Button {
                    monitor.checkOfficialFirmware()
                } label: {
                    Label(
                        monitor.isCheckingFirmware ? "Проверяем сайт…" : "Проверить обновления",
                        systemImage: monitor.isCheckingFirmware ? "hourglass" : "arrow.clockwise"
                    )
                }
                .buttonStyle(DarkButtonStyle())
                .disabled(monitor.isCheckingFirmware || monitor.selectedDevice == nil)
                if let info = monitor.officialFirmwareInfo {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("ПОСЛЕДНЯЯ ВЕРСИЯ НА САЙТЕ")
                            .font(.system(size: 8, design: .monospaced))
                            .tracking(0.5)
                            .foregroundStyle(Palette.subtle)
                        Text(info.versionSummary)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(Palette.olive)
                        Link(destination: info.downloadsPage) {
                            Label("Открыть страницу загрузок", systemImage: "arrow.up.right")
                                .font(.system(size: 9, weight: .medium))
                        }
                        .foregroundStyle(Palette.olive)
                    }
                }
                if let error = monitor.firmwareCheckError { ErrorMessage(text: error) }
                Text("Скачивание и установка — только на официальной странице и по вашему решению. TE Desk не записывает прошивку на устройство.")
                    .font(.system(size: 9))
                    .foregroundStyle(Palette.muted)
            }
        }
    }

    private var connectionCard: some View {
        SurfaceCard {
            VStack(alignment: .leading, spacing: 10) {
                CardHeading(title: "Следующий шаг", detail: "Подключение без риска", symbol: "cable.connector")
                Text(monitor.selectedDevice?.detectedViaVolume == true
                     ? "Модель \(monitor.selectedDevice?.displayModel ?? "") распознана по имени тома; USB-ID macOS не предоставила."
                     : "Используйте USB-кабель с передачей данных. Если устройство предлагает USB / Disk / Data, выберите этот режим.")
                    .font(.system(size: 10))
                    .foregroundStyle(Palette.muted)
                    .fixedSize(horizontal: false, vertical: true)
                if monitor.selectedDevice?.detectedViaVolume == true,
                   monitor.selectedDevice?.displayModel == "OP-XY" {
                    Text("Для доступа к проектам и сэмплам используйте MTP: подключите OP–XY, нажмите COM → M4 и откройте Field Kit. Диск появляется в TE BOOT.")
                        .font(.system(size: 10))
                        .foregroundStyle(Palette.muted)
                        .fixedSize(horizontal: false, vertical: true)
                    Link(destination: URL(string: "https://teenage.engineering/guides/op-xy/com#mtp")!) {
                        Label("Инструкция OP–XY · MTP", systemImage: "arrow.up.right")
                            .font(.system(size: 9, weight: .medium))
                    }
                    .foregroundStyle(Palette.olive)
                    Link(destination: URL(string: "https://apps.apple.com/se/app/field-kit/id1612653346")!) {
                        Label("Открыть Field Kit", systemImage: "arrow.up.right")
                            .font(.system(size: 9, weight: .medium))
                    }
                    .foregroundStyle(Palette.olive)
                }
                Button {
                    showingConnectionGuide = true
                } label: {
                    Label("Показать инструкцию", systemImage: "arrow.right")
                }
                .buttonStyle(QuietButtonStyle())
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private var communityPreview: some View {
        SurfaceCard {
            VStack(alignment: .leading, spacing: 13) {
                HStack {
                    CardHeading(title: "Приложения и сообщество", detail: "Открытые источники · поиск вручную", symbol: "sparkles")
                    Spacer()
                    Button {
                        monitor.searchSources()
                        section = .community
                    } label: {
                        Label(monitor.isSearchingSources ? "Ищем…" : "Проверить GitHub и Reddit", systemImage: "magnifyingglass")
                    }
                    .buttonStyle(QuietButtonStyle())
                    .disabled(monitor.isSearchingSources)
                }
                if !monitor.sourceMessages.isEmpty { sourceMessagesView }
                if monitor.repositories.isEmpty && monitor.redditPosts.isEmpty && !monitor.didSearchReddit {
                    Text("Ничего не загружается в фоне. Нажмите кнопку, чтобы получить текущие публичные результаты поиска.")
                        .font(.system(size: 10))
                        .foregroundStyle(Palette.muted)
                } else {
                    HStack(alignment: .top, spacing: 18) {
                        VStack(alignment: .leading, spacing: 7) {
                            Label("GitHub", systemImage: "chevron.left.forwardslash.chevron.right")
                                .font(.system(size: 10, weight: .semibold))
                            ForEach(monitor.repositories.prefix(3)) { repository in
                                RepositoryRow(repository: repository, compact: true)
                            }
                        }
                        VStack(alignment: .leading, spacing: 7) {
                            Label("Reddit", systemImage: "bubble.left")
                                .font(.system(size: 10, weight: .semibold))
                            if monitor.redditPosts.isEmpty {
                                if monitor.didSearchReddit {
                                    Text(monitor.redditSearchFailure ?? "По запросу Reddit не вернул публикаций.")
                                        .font(.system(size: 9))
                                        .foregroundStyle(Palette.muted)
                                    if let url = monitor.redditSearchURL {
                                        Link(destination: url) {
                                            Label("Открыть поиск Reddit", systemImage: "arrow.up.right")
                                                .font(.system(size: 9, weight: .medium))
                                        }
                                        .foregroundStyle(Palette.olive)
                                    }
                                } else {
                                    Text("Обсуждения появятся после поиска.")
                                        .font(.system(size: 9))
                                        .foregroundStyle(Palette.muted)
                                }
                            } else {
                                ForEach(monitor.redditPosts.prefix(3)) { post in
                                    RedditRow(post: post, compact: true)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var sourceMessagesView: some View {
        ForEach(Array(monitor.sourceMessages.enumerated()), id: \.offset) { _, message in
            ErrorMessage(text: message)
        }
    }

    private var sourceSearchButton: some View {
        HStack(spacing: 12) {
            Image(systemName: "network")
                .font(.system(size: 16))
                .foregroundStyle(Palette.olive)
            VStack(alignment: .leading, spacing: 3) {
                Text("Поиск по публичным источникам")
                    .font(.system(size: 11, weight: .semibold))
                Text("Запрос: \(monitor.selectedDevice?.displayModel ?? "Teenage Engineering") · только после нажатия")
                    .font(.system(size: 9))
                    .foregroundStyle(Palette.muted)
            }
            Spacer()
            Button {
                monitor.searchSources()
            } label: {
                Label(monitor.isSearchingSources ? "Загружаем…" : "Искать сейчас", systemImage: "magnifyingglass")
            }
            .buttonStyle(DarkButtonStyle())
            .disabled(monitor.isSearchingSources)
        }
        .padding(14)
        .background(Palette.card)
        .clipShape(RoundedRectangle(cornerRadius: 9))
        .overlay(RoundedRectangle(cornerRadius: 9).stroke(Palette.line, lineWidth: 1))
    }

    private var privacyFooter: some View {
        HStack(spacing: 7) {
            Image(systemName: "lock.fill")
            Text("USB-данные остаются на Mac. В сеть отправляется только запрос поиска по названию модели.")
            Spacer()
            Text("TE DESK")
                .font(.system(size: 8, design: .monospaced))
        }
        .font(.system(size: 9))
        .foregroundStyle(Palette.subtle)
        .padding(.top, 5)
    }

    private func select(_ device: USBDevice) {
        monitor.selectedDeviceID = device.id
        manualFirmware = UserDefaults.standard.string(forKey: firmwareKey(for: device)) ?? ""
    }

    private func firmwareKey(for device: USBDevice) -> String {
        "TEDesk.manualFirmware.\(device.vendorID).\(device.productID).\(device.productName)"
    }

    private func saveManualFirmware(_ value: String) {
        guard let device = monitor.selectedDevice else { return }
        UserDefaults.standard.set(value, forKey: firmwareKey(for: device))
    }
}

struct Sidebar: View {
    @Binding var section: DeskSection
    @ObservedObject var monitor: DeviceMonitor
    let showGuide: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 9) {
                Image(systemName: "waveform.path")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Palette.lime)
                    .frame(width: 31, height: 31)
                    .background(Palette.ink)
                    .clipShape(RoundedRectangle(cornerRadius: 9))
                Text("TE ")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                + Text("DESK")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
            }
            .foregroundStyle(Palette.ink)
            .padding(.bottom, 38)

            Text("РАБОЧЕЕ ПРОСТРАНСТВО")
                .font(.system(size: 9, design: .monospaced))
                .tracking(0.5)
                .foregroundStyle(Palette.subtle)
                .padding(.horizontal, 7)
                .padding(.bottom, 9)

            ForEach(DeskSection.allCases) { item in
                Button {
                    section = item
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: item.symbol).frame(width: 17)
                        Text(item.rawValue)
                        Spacer()
                        if item == .overview, !monitor.devices.isEmpty {
                            Circle().fill(Palette.olive).frame(width: 6, height: 6)
                        }
                    }
                    .font(.system(size: 12, weight: section == item ? .semibold : .regular))
                    .foregroundStyle(section == item ? Palette.ink : Palette.muted)
                    .padding(.horizontal, 10)
                    .frame(height: 37)
                    .background(section == item ? Palette.selected : .clear)
                    .clipShape(RoundedRectangle(cornerRadius: 7))
                }
                .buttonStyle(.plain)
            }

            Rectangle().fill(Palette.line).frame(height: 1).padding(.vertical, 20)
            HStack {
                Text("МОИ УСТРОЙСТВА")
                    .font(.system(size: 9, design: .monospaced))
                    .tracking(0.5)
                    .foregroundStyle(Palette.subtle)
                Spacer()
                Image(systemName: "plus").font(.system(size: 12)).foregroundStyle(Palette.muted)
            }
            .padding(.horizontal, 7)
            .padding(.bottom, 9)

            if monitor.devices.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: "cable.connector")
                        .foregroundStyle(Palette.muted)
                    Text("Пока нет подключённых устройств")
                        .font(.system(size: 10))
                        .foregroundStyle(Palette.muted)
                }
                .padding(8)
            } else {
                ForEach(monitor.devices) { device in
                    Button {
                        monitor.selectedDeviceID = device.id
                    } label: {
                        HStack(spacing: 8) {
                            Text(deviceBadge(device))
                                .font(.system(size: 9, weight: .semibold, design: .monospaced))
                                .frame(width: 29, height: 29)
                                .background(device.isTeenageEngineering ? Palette.lime : Palette.selected)
                                .clipShape(RoundedRectangle(cornerRadius: 7))
                            VStack(alignment: .leading, spacing: 2) {
                                Text(device.displayModel)
                                    .font(.system(size: 10, weight: .semibold))
                                    .lineLimit(1)
                                Text(device.detectedViaVolume ? "Модель по имени тома" : device.isTeenageEngineering ? "Teenage Engineering" : device.manufacturer)
                                    .font(.system(size: 9))
                                    .foregroundStyle(Palette.muted)
                                    .lineLimit(1)
                            }
                            Spacer(minLength: 0)
                        }
                        .padding(6)
                        .background(device.id == monitor.selectedDeviceID ? Palette.selected.opacity(0.7) : .clear)
                        .clipShape(RoundedRectangle(cornerRadius: 7))
                    }
                    .buttonStyle(.plain)
                }
            }

            Spacer(minLength: 20)

            VStack(alignment: .leading, spacing: 7) {
                Label("Сначала безопасность", systemImage: "checkmark.shield")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(Palette.ink)
                Text("Ничего не меняем на устройстве без вашего разрешения.")
                    .font(.system(size: 9))
                    .foregroundStyle(Palette.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(11)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Palette.card)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Palette.line, lineWidth: 1))

            Button(action: showGuide) {
                Label("Как подключить", systemImage: "questionmark.circle")
                    .font(.system(size: 10))
                    .foregroundStyle(Palette.muted)
                    .padding(.top, 12)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 14)
        .padding(.top, 24)
        .padding(.bottom, 18)
        .frame(width: 222)
        .background(Palette.sidebar)
        .overlay(alignment: .trailing) { Rectangle().fill(Palette.line).frame(width: 1) }
    }

    private func deviceBadge(_ device: USBDevice) -> String {
        if device.displayModel.contains("EP-133") { return "EP" }
        if device.displayModel.contains("OP-Z") { return "OZ" }
        if device.displayModel.contains("OP-1") { return "OP" }
        return String(device.productName.prefix(2)).uppercased()
    }
}

struct USBDeviceRow: View {
    let device: USBDevice
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 10) {
                Image(systemName: device.detectedViaVolume ? "externaldrive.fill" : "cable.connector")
                    .font(.system(size: 13))
                    .foregroundStyle(device.isTeenageEngineering ? Palette.olive : Palette.muted)
                    .frame(width: 31, height: 31)
                    .background(device.isTeenageEngineering ? Palette.safety : Palette.selected)
                    .clipShape(RoundedRectangle(cornerRadius: 7))
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text(device.displayModel).font(.system(size: 11, weight: .semibold))
                        if device.isTeenageEngineering {
                            Text("TE")
                                .font(.system(size: 8, weight: .semibold, design: .monospaced))
                                .foregroundStyle(Palette.olive)
                                .padding(.horizontal, 4)
                                .padding(.vertical, 2)
                                .background(Palette.safety)
                                .clipShape(RoundedRectangle(cornerRadius: 3))
                        }
                    }
                    Text(device.detectedViaVolume
                         ? "Модель по имени тома · USB-ID недоступен"
                         : "\(device.manufacturer.isEmpty ? "Производитель не указан" : device.manufacturer) · VID \(device.vendorID) · PID \(device.productID)")
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundStyle(Palette.muted)
                        .lineLimit(1)
                }
                Spacer()
                if isSelected { Image(systemName: "checkmark.circle.fill").foregroundStyle(Palette.olive) }
            }
            .padding(8)
            .background(isSelected ? Palette.selected.opacity(0.6) : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

struct RepositoryRow: View {
    let repository: GitHubRepository
    var compact = false
    private var destination: URL? { URL(string: repository.html_url) }

    var body: some View {
        Group {
            if let destination {
                Link(destination: destination) { rowContent }
            } else {
                rowContent
            }
        }
    }

    private var rowContent: some View {
        HStack(alignment: .top, spacing: 9) {
            Image(systemName: "chevron.left.forwardslash.chevron.right")
                .font(.system(size: 12))
                .foregroundStyle(Palette.muted)
                .padding(.top, 2)
            VStack(alignment: .leading, spacing: 4) {
                Text(repository.full_name)
                    .font(.system(size: compact ? 9 : 11, weight: .semibold))
                    .lineLimit(1)
                    .foregroundStyle(Palette.ink)
                if let description = repository.description, !description.isEmpty {
                    Text(description)
                        .font(.system(size: compact ? 9 : 10))
                        .foregroundStyle(Palette.muted)
                        .lineLimit(compact ? 2 : 3)
                }
            }
            Spacer(minLength: 5)
            Label("\(repository.stargazers_count)", systemImage: "star")
                .font(.system(size: 9, design: .monospaced))
                .foregroundStyle(Palette.muted)
        }
        .padding(compact ? 7 : 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Palette.card)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Palette.line, lineWidth: 1))
    }
}

struct RedditRow: View {
    let post: RedditPost
    var compact = false
    private var destination: URL? { URL(string: "https://www.reddit.com\(post.permalink)") }

    var body: some View {
        Group {
            if let destination {
                Link(destination: destination) { rowContent }
            } else {
                rowContent
            }
        }
    }

    private var rowContent: some View {
        HStack(alignment: .top, spacing: 9) {
            Image(systemName: "bubble.left")
                .font(.system(size: 12))
                .foregroundStyle(Palette.muted)
                .padding(.top, 2)
            Text(post.title)
                .font(.system(size: compact ? 9 : 11, weight: .medium))
                .foregroundStyle(Palette.ink)
                .lineLimit(compact ? 2 : 3)
                .frame(maxWidth: .infinity, alignment: .leading)
            Label("\(post.score)", systemImage: "arrow.up")
                .font(.system(size: 9, design: .monospaced))
                .foregroundStyle(Palette.muted)
        }
        .padding(compact ? 7 : 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Palette.card)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Palette.line, lineWidth: 1))
    }
}

struct ConnectionGuide: View {
    let device: USBDevice?
    let officialGuide: URL
    @Environment(\.dismiss) private var dismiss
    @State private var selectedModel = "OP–XY"

    private var modelName: String { device?.displayModel ?? selectedModel }
    private var isOPXY: Bool {
        modelName.lowercased().replacingOccurrences(of: "–", with: "-").contains("op-xy")
    }

    private var modelDownloadsPage: URL {
        if isOPXY { return URL(string: "https://teenage.engineering/downloads/op-xy")! }
        return officialGuide
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "cable.connector")
                    .font(.system(size: 20))
                    .foregroundStyle(Palette.olive)
                    .frame(width: 42, height: 42)
                    .background(Palette.safety)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                Spacer()
                Button { dismiss() } label: { Image(systemName: "xmark") }
                    .buttonStyle(.plain)
                    .foregroundStyle(Palette.muted)
            }
            Text("Подключение \(modelName)")
                .font(.system(size: 23, weight: .medium, design: .rounded))
                .tracking(-0.7)
            if device == nil {
                Picker("Модель", selection: $selectedModel) {
                    ForEach(["OP–XY", "OP–1 field", "OP–1 original", "OP–Z", "EP–133 K.O. II", "EP–1320 medieval"], id: \.self) {
                        Text($0).tag($0)
                    }
                }
                .pickerStyle(.menu)
            }
            Text("Используйте USB-кабель с передачей данных. Кабель только для зарядки не передаст данные на Mac.")
                .font(.system(size: 12))
                .foregroundStyle(Palette.muted)
            VStack(alignment: .leading, spacing: 13) {
                if isOPXY {
                    if device?.detectedViaVolume == true {
                        GuideStep(number: "1", title: "Том OP–XY уже найден", detail: "Модель определена по имени диска; macOS не передала USB-ID.")
                        GuideStep(number: "2", title: "Диск и MTP — разные режимы", detail: "В TE BOOT OP–XY отображается как диск. Для проектов и сэмплов используйте обычный режим: COM → M4 (MTP) и приложение Field Kit.")
                        GuideStep(number: "3", title: "Ничего не записывайте", detail: "TE Desk только читает сведения. Следуйте официальной инструкции, если решите обновить прошивку.")
                    } else {
                        GuideStep(number: "1", title: "Выключите OP–XY", detail: "Не подключайте и не копируйте файлы прошивки.")
                        GuideStep(number: "2", title: "Откройте TE BOOT", detail: "Удерживайте COM, включая устройство.")
                        GuideStep(number: "3", title: "Подключите USB-C и нажмите 1", detail: "По официальной инструкции устройство появится как диск. Затем нажмите «Обновить» в TE Desk.")
                    }
                } else {
                    GuideStep(number: "1", title: "Подключите USB", detail: "Используйте кабель передачи данных и подключите устройство напрямую к Mac.")
                    GuideStep(number: "2", title: "Выберите режим передачи", detail: "Если устройство предлагает USB / Disk / Data, выберите его. Иначе сверьтесь с руководством модели.")
                    GuideStep(number: "3", title: "Нажмите «Обновить»", detail: "TE Desk попросит macOS показать список USB-устройств и смонтированных томов.")
                }
            }
            .padding(14)
            .background(Palette.canvas)
            .clipShape(RoundedRectangle(cornerRadius: 9))
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "checkmark.shield").foregroundStyle(Palette.olive)
                Text(isOPXY
                     ? "TE BOOT — режим загрузчика. Только подключите диск для чтения; не помещайте на него firmware-файлы. TE Desk не записывает данные."
                     : "Приложение читает данные macOS и доступные размеры томов. Оно не форматирует диски, не копирует и не записывает файлы.")
                    .font(.system(size: 10))
                    .foregroundStyle(Palette.muted)
            }
            Link(destination: modelDownloadsPage) {
                Label("Официальные инструкции и загрузки", systemImage: "arrow.up.right")
                    .font(.system(size: 10, weight: .medium))
            }
            .foregroundStyle(Palette.olive)
            Spacer(minLength: 0)
        }
        .padding(24)
        .frame(width: 460, height: 525)
        .background(Palette.card)
    }
}

struct GuideStep: View {
    let number: String
    let title: String
    let detail: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Text(number)
                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                .foregroundStyle(Palette.olive)
                .frame(width: 22, height: 22)
                .background(Palette.safety)
                .clipShape(Circle())
            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(.system(size: 11, weight: .semibold))
                Text(detail).font(.system(size: 9)).foregroundStyle(Palette.muted)
            }
        }
    }
}

struct CardHeading: View {
    let title: String
    let detail: String
    let symbol: String

    var body: some View {
        HStack(alignment: .top, spacing: 9) {
            Image(systemName: symbol)
                .font(.system(size: 13))
                .foregroundStyle(Palette.olive)
                .frame(width: 27, height: 27)
                .background(Palette.safety)
                .clipShape(RoundedRectangle(cornerRadius: 7))
            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(.system(size: 11, weight: .semibold)).foregroundStyle(Palette.ink)
                Text(detail).font(.system(size: 9)).foregroundStyle(Palette.muted)
            }
            Spacer(minLength: 0)
        }
    }
}

struct EmptyPanel: View {
    let symbol: String
    let title: String
    let detail: String

    var body: some View {
        VStack(spacing: 7) {
            Image(systemName: symbol)
                .font(.system(size: 18))
                .foregroundStyle(Palette.subtle)
                .padding(.bottom, 2)
            Text(title).font(.system(size: 11, weight: .semibold)).foregroundStyle(Palette.ink)
            Text(detail)
                .font(.system(size: 9))
                .foregroundStyle(Palette.muted)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 360)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 23)
    }
}

struct ErrorMessage: View {
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 7) {
            Image(systemName: "exclamationmark.triangle")
            Text(text)
                .fixedSize(horizontal: false, vertical: true)
        }
        .font(.system(size: 9))
        .foregroundStyle(Palette.error)
        .padding(9)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Palette.error.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}

struct SurfaceCard<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        content
            .padding(15)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Palette.card)
            .clipShape(RoundedRectangle(cornerRadius: 9))
            .overlay(RoundedRectangle(cornerRadius: 9).stroke(Palette.line, lineWidth: 1))
    }
}

struct DarkButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 10, weight: .semibold))
            .foregroundStyle(Color.white)
            .padding(.horizontal, 11)
            .frame(height: 33)
            .background(configuration.isPressed ? Palette.darkHover : Palette.ink)
            .clipShape(RoundedRectangle(cornerRadius: 7))
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
    }
}

struct QuietButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 10, weight: .medium))
            .foregroundStyle(configuration.isPressed ? Palette.olive : Palette.ink)
            .padding(.horizontal, 9)
            .frame(height: 29)
            .background(configuration.isPressed ? Palette.selected : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}

enum Palette {
    static let canvas = Color(hex: 0xF6F5F1)
    static let sidebar = Color(hex: 0xF1F0EB)
    static let card = Color.white
    static let ink = Color(hex: 0x252521)
    static let muted = Color(hex: 0x898982)
    static let subtle = Color(hex: 0xAAA9A1)
    static let line = Color(hex: 0xE9E8E2)
    static let selected = Color(hex: 0xE6E5DF)
    static let safety = Color(hex: 0xEFF2E3)
    static let olive = Color(hex: 0x778344)
    static let lime = Color(hex: 0xD7FB42)
    static let error = Color(hex: 0xA44535)
    static let darkHover = Color(hex: 0x42423A)
}

extension Color {
    init(hex: UInt32) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }
}
