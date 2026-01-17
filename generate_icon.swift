import Foundation
import CoreGraphics
import ImageIO
import AppKit

func generateIcon(size: CGFloat, filename: String, idiom: String) {
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    // Using premultipliedLast but without alpha channel in the background to ensure opaque PNG
    let bitmapInfo = CGImageAlphaInfo.noneSkipLast.rawValue 
    guard let context = CGContext(data: nil, width: Int(size), height: Int(size), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo) else {
        print("Failed to create context")
        return
    }

    // Background: Black (OLED) - Zen Athlete
    let colors = [
        NSColor(red: 0.05, green: 0.05, blue: 0.05, alpha: 1.0).cgColor,
        NSColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0).cgColor
    ] as CFArray
    let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: [0.0, 1.0])!
    context.drawLinearGradient(gradient, start: CGPoint(x: 0, y: size), end: CGPoint(x: size, y: 0), options: [])

    // Pi Symbol
    let piString = "π"
    let fontSize = size * 0.6
    let font = NSFont.systemFont(ofSize: fontSize, weight: .bold)
    let attributes: [NSAttributedString.Key: Any] = [
        .font: font,
        .foregroundColor: NSColor(red: 0.0, green: 0.949, blue: 1.0, alpha: 1.0) // Cyan #00F2FF
    ]
    let attributedString = NSAttributedString(string: piString, attributes: attributes)
    let stringSize = attributedString.size()
    let stringRect = CGRect(x: (size - stringSize.width) / 2, y: (size - stringSize.height) / 2, width: stringSize.width, height: stringSize.height)
    
    // Draw string
    NSGraphicsContext.saveGraphicsState()
    let nsContext = NSGraphicsContext(cgContext: context, flipped: false)
    NSGraphicsContext.current = nsContext
    attributedString.draw(in: stringRect)
    NSGraphicsContext.restoreGraphicsState()

    // Save as PNG
    if let cgImage = context.makeImage() {
        let url = URL(fileURLWithPath: filename)
        // kUTTypePNG corresponds to public.png
        let destination = CGImageDestinationCreateWithURL(url as CFURL, "public.png" as CFString, 1, nil)!
        CGImageDestinationAddImage(destination, cgImage, nil)
        CGImageDestinationFinalize(destination)
        print("Generated \(filename) (\(Int(size))x\(Int(size))) for \(idiom)")
    }
}

func formatSize(_ val: CGFloat) -> String {
    if val == floor(val) {
        return "\(Int(val))"
    } else {
        return "\(val)"
    }
}

struct IconConfig {
    let size: CGFloat
    let scales: [CGFloat]
    let idiom: String
}

let configs: [IconConfig] = [
    // iPhone
    IconConfig(size: 20, scales: [2, 3], idiom: "iphone"),
    IconConfig(size: 29, scales: [2, 3], idiom: "iphone"),
    IconConfig(size: 40, scales: [2, 3], idiom: "iphone"),
    IconConfig(size: 60, scales: [2, 3], idiom: "iphone"),
    // iPad
    IconConfig(size: 20, scales: [1, 2], idiom: "ipad"),
    IconConfig(size: 29, scales: [1, 2], idiom: "ipad"),
    IconConfig(size: 40, scales: [1, 2], idiom: "ipad"),
    IconConfig(size: 76, scales: [1, 2], idiom: "ipad"),
    IconConfig(size: 83.5, scales: [2], idiom: "ipad"),
    // Marketing
    IconConfig(size: 1024, scales: [1], idiom: "ios-marketing")
]

for config in configs {
    for scale in config.scales {
        let pixelSize = config.size * scale
        let sizeStr = formatSize(config.size)
        let scaleStr = formatSize(scale)
        let filename = "AppIcon-\(config.idiom)-\(sizeStr)x\(sizeStr)@\(scaleStr)x.png"
        generateIcon(size: pixelSize, filename: filename, idiom: config.idiom)
    }
}
