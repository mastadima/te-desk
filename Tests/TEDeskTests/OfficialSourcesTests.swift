import XCTest
@testable import TEDesk

final class OfficialSourcesTests: XCTestCase {
    func testFirmwareParserSkipsScriptsAndReleaseDates() {
        let html = """
        <script>const old = "9.9.9"</script>
        <h2>OS updates</h2>
        <a>2.5.1</a><span>2026.07.03</span>
        <a>2.5</a><span>2026.06.24</span>
        """

        XCTAssertEqual(OfficialFirmwareChecker.parseVersions(from: html), ["2.5.1", "2.5"])
    }

    func testFirmwareParserHandlesOriginalOp1Numbering() {
        let html = "<a>OP–1 field 1.7.3</a><a>OP-1 original #246</a>"

        XCTAssertEqual(OfficialFirmwareChecker.parseVersions(from: html), ["1.7.3", "#246"])
    }

    func testOfficialDownloadPathsFollowDeviceModel() {
        let opXY = USBDevice(productName: "OP–XY", manufacturer: "Teenage Engineering", vendorID: "1", productID: "2", locationID: "3")
        let ep133 = USBDevice(productName: "EP–133 K.O. II", manufacturer: "Teenage Engineering", vendorID: "1", productID: "3", locationID: "4")

        XCTAssertEqual(OfficialFirmwareChecker.downloadsSlug(for: opXY), "op-xy")
        XCTAssertEqual(OfficialFirmwareChecker.downloadsSlug(for: ep133), "ep-133")
    }

    func testMountedOPXYVolumeIsRecognizedWithoutInventingUSBIdentifiers() {
        let device = USBScanner.deviceForMountedVolume(name: "OP–XY", path: "/Volumes/OP-XY")

        XCTAssertEqual(device?.displayModel, "OP-XY")
        XCTAssertEqual(device?.vendorID, "—")
        XCTAssertEqual(device?.productID, "—")
        XCTAssertTrue(device?.detectedViaVolume == true)
        XCTAssertEqual(device.flatMap(OfficialFirmwareChecker.downloadsSlug(for:)), "op-xy")
    }

    func testArbitraryVolumeIsNotClassifiedAsTeenageEngineering() {
        XCTAssertNil(USBScanner.deviceForMountedVolume(name: "My USB Drive", path: "/Volumes/My USB Drive"))
    }

    func testExternalDiskListReturnsMountedPhysicalVolumes() throws {
        let plist: [String: Any] = [
            "AllDisksAndPartitions": [
                [
                    "DeviceIdentifier": "disk15",
                    "Partitions": [
                        [
                            "DeviceIdentifier": "disk15s1",
                            "MountPoint": "/Volumes/OP-XY"
                        ]
                    ]
                ]
            ]
        ]
        let data = try PropertyListSerialization.data(fromPropertyList: plist, format: .xml, options: 0)

        XCTAssertEqual(
            try USBScanner.externalVolumeMountPoints(from: data),
            Set(["/Volumes/OP-XY"])
        )
    }

    func testRedditFallbackURLContainsDeviceSearch() throws {
        let url = try XCTUnwrap(PublicSources.redditSearchURL(for: "OP-XY"))
        let components = try XCTUnwrap(URLComponents(url: url, resolvingAgainstBaseURL: false))

        XCTAssertEqual(components.host, "www.reddit.com")
        XCTAssertEqual(components.queryItems?.first(where: { $0.name == "q" })?.value, "OP-XY")
    }
}
