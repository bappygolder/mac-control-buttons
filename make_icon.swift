import Cocoa
import CoreGraphics

func createIcon(size: Int, filename: String) {
    let rect = NSRect(x: 0, y: 0, width: size, height: size)
    let image = NSImage(size: rect.size)
    
    image.lockFocus()
    
    // Background
    NSColor(white: 0.1, alpha: 1.0).setFill()
    let path = NSBezierPath(roundedRect: rect, xRadius: CGFloat(size) * 0.225, yRadius: CGFloat(size) * 0.225)
    path.fill()
    
    // Lightning Emoji
    let text = "⚡" as NSString
    let font = NSFont.systemFont(ofSize: CGFloat(size) * 0.6)
    let attributes: [NSAttributedString.Key: Any] = [
        .font: font,
        .foregroundColor: NSColor.systemYellow
    ]
    
    let textSize = text.size(withAttributes: attributes)
    let textRect = NSRect(
        x: (CGFloat(size) - textSize.width) / 2,
        y: (CGFloat(size) - textSize.height) / 2.2,
        width: textSize.width,
        height: textSize.height
    )
    
    text.draw(in: textRect, withAttributes: attributes)
    
    image.unlockFocus()
    
    if let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) {
        let bitmapRep = NSBitmapImageRep(cgImage: cgImage)
        bitmapRep.size = image.size
        if let data = bitmapRep.representation(using: .png, properties: [:]) {
            try? data.write(to: URL(fileURLWithPath: filename))
        }
    }
}

let fm = FileManager.default
try? fm.createDirectory(atPath: "MyIcon.iconset", withIntermediateDirectories: true)

let iconSpecs: [(pointSize: Int, scale: Int)] = [
    (16, 1), (16, 2),
    (32, 1), (32, 2),
    (128, 1), (128, 2),
    (256, 1), (256, 2),
    (512, 1), (512, 2)
]

for spec in iconSpecs {
    let pixelSize = spec.pointSize * spec.scale
    let suffix = spec.scale == 2 ? "@2x" : ""
    let filename = "MyIcon.iconset/icon_\(spec.pointSize)x\(spec.pointSize)\(suffix).png"
    createIcon(size: pixelSize, filename: filename)
}
