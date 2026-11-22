import AppKit
import CoreGraphics
import Foundation

guard CommandLine.arguments.count == 2 else {
    fputs("Usage: make-app-icon.swift <output.iconset>\n", stderr)
    exit(64)
}

let iconsetURL = URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true)
try? FileManager.default.removeItem(at: iconsetURL)
try FileManager.default.createDirectory(at: iconsetURL, withIntermediateDirectories: true)

let iconFiles: [(String, Int)] = [
    ("icon_16x16.png", 16),
    ("icon_16x16@2x.png", 32),
    ("icon_32x32.png", 32),
    ("icon_32x32@2x.png", 64),
    ("icon_128x128.png", 128),
    ("icon_128x128@2x.png", 256),
    ("icon_256x256.png", 256),
    ("icon_256x256@2x.png", 512),
    ("icon_512x512.png", 512),
    ("icon_512x512@2x.png", 1024)
]

for (fileName, size) in iconFiles {
    guard let bitmap = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: size,
        pixelsHigh: size,
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
    ), let graphics = NSGraphicsContext(bitmapImageRep: bitmap) else {
        throw IconError.cannotCreateBitmap(size)
    }

    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = graphics
    graphics.imageInterpolation = .high
    graphics.cgContext.scaleBy(x: CGFloat(size) / 1024, y: CGFloat(size) / 1024)
    drawIcon(in: graphics.cgContext)
    graphics.flushGraphics()
    NSGraphicsContext.restoreGraphicsState()

    guard let data = bitmap.representation(using: .png, properties: [:]) else {
        throw IconError.cannotEncodePNG(fileName)
    }
    try data.write(to: iconsetURL.appendingPathComponent(fileName), options: .atomic)
}

func drawIcon(in context: CGContext) {
    let background = cgColor(0xE7E8D5)
    let body = cgColor(0x243B34)
    let bodyHighlight = cgColor(0x40584D)
    let screen = cgColor(0xD5E4C5)
    let ink = cgColor(0x20352E)
    let accent = cgColor(0xE8845B)
    let muted = cgColor(0x8FA18B)

    fillRoundedRect(
        CGRect(x: 0, y: 0, width: 1024, height: 1024),
        radius: 220,
        color: background,
        in: context
    )

    context.setFillColor(cgColor(0xD7DDC7, alpha: 0.65))
    context.fillEllipse(in: CGRect(x: 90, y: 70, width: 844, height: 844))

    context.saveGState()
    context.setShadow(offset: CGSize(width: 0, height: -24), blur: 40, color: cgColor(0x1B2A25, alpha: 0.24))
    fillRoundedRect(
        CGRect(x: 128, y: 215, width: 768, height: 594),
        radius: 108,
        color: body,
        in: context
    )
    context.restoreGState()

    strokeRoundedRect(
        CGRect(x: 143, y: 230, width: 738, height: 564),
        radius: 94,
        color: bodyHighlight,
        lineWidth: 7,
        in: context
    )

    for (index, color) in [accent, screen, muted, screen].enumerated() {
        context.setFillColor(color)
        context.fillEllipse(in: CGRect(x: 222 + index * 75, y: 724, width: 28, height: 28))
    }

    fillRoundedRect(
        CGRect(x: 208, y: 428, width: 420, height: 230),
        radius: 40,
        color: screen,
        in: context
    )
    strokeRoundedRect(
        CGRect(x: 222, y: 442, width: 392, height: 202),
        radius: 29,
        color: cgColor(0xB7C7A9),
        lineWidth: 4,
        in: context
    )

    context.setStrokeColor(accent)
    context.setLineWidth(18)
    context.setLineCap(.round)
    context.setLineJoin(.round)
    let wave = CGMutablePath()
    for step in 0...120 {
        let x = CGFloat(step) * 2.45
        let envelope = 0.2 + 0.8 * sin(Double(step) / 120 * .pi)
        let y = 543 + CGFloat(sin(Double(step) / 120 * .pi * 8) * 55 * envelope)
        if step == 0 {
            wave.move(to: CGPoint(x: 252 + x, y: y))
        } else {
            wave.addLine(to: CGPoint(x: 252 + x, y: y))
        }
    }
    context.addPath(wave)
    context.strokePath()

    context.setFillColor(screen)
    context.fillEllipse(in: CGRect(x: 671, y: 457, width: 210, height: 210))
    context.setStrokeColor(bodyHighlight)
    context.setLineWidth(9)
    context.strokeEllipse(in: CGRect(x: 680, y: 466, width: 192, height: 192))
    context.setFillColor(ink)
    context.fillEllipse(in: CGRect(x: 704, y: 490, width: 144, height: 144))
    context.setStrokeColor(muted)
    context.setLineWidth(7)
    context.move(to: CGPoint(x: 776, y: 606))
    context.addLine(to: CGPoint(x: 776, y: 574))
    context.strokePath()
    context.setFillColor(accent)
    context.fillEllipse(in: CGRect(x: 765, y: 603, width: 22, height: 22))

    context.setStrokeColor(bodyHighlight)
    context.setLineWidth(10)
    context.setLineCap(.round)
    for index in 0..<7 {
        let x = CGFloat(270 + index * 61)
        context.move(to: CGPoint(x: x, y: 302))
        context.addLine(to: CGPoint(x: x + 24, y: 302))
    }
    context.strokePath()
}

func fillRoundedRect(_ rect: CGRect, radius: CGFloat, color: CGColor, in context: CGContext) {
    context.setFillColor(color)
    context.addPath(CGPath(roundedRect: rect, cornerWidth: radius, cornerHeight: radius, transform: nil))
    context.fillPath()
}

func strokeRoundedRect(_ rect: CGRect, radius: CGFloat, color: CGColor, lineWidth: CGFloat, in context: CGContext) {
    context.setStrokeColor(color)
    context.setLineWidth(lineWidth)
    context.addPath(CGPath(roundedRect: rect, cornerWidth: radius, cornerHeight: radius, transform: nil))
    context.strokePath()
}

func cgColor(_ hex: UInt32, alpha: CGFloat = 1) -> CGColor {
    CGColor(
        red: CGFloat((hex >> 16) & 0xFF) / 255,
        green: CGFloat((hex >> 8) & 0xFF) / 255,
        blue: CGFloat(hex & 0xFF) / 255,
        alpha: alpha
    )
}

enum IconError: LocalizedError {
    case cannotCreateBitmap(Int)
    case cannotEncodePNG(String)

    var errorDescription: String? {
        switch self {
        case .cannotCreateBitmap(let size): "Could not render \(size)x\(size) app icon."
        case .cannotEncodePNG(let fileName): "Could not encode \(fileName)."
        }
    }
}
