#!/usr/bin/env python3
import os

# We will just generate a macOS app icon using sips and text/emoji
# since we don't have an external image.
os.system('''
mkdir -p MyIcon.iconset
# Create a robust simple image using text with ImageMagick or standard tools?
# Mac comes with `sips` but creating from scratch with sips isn't fully supported.
# We can use python's CoreGraphics to draw.
''')

import Cocoa
import CoreGraphics

def create_icon(size, filename):
    colorSpace = CoreGraphics.CGColorSpaceCreateDeviceRGB()
    context = CoreGraphics.CGBitmapContextCreate(None, size, size, 8, size * 4, colorSpace, CoreGraphics.kCGImageAlphaPremultipliedLast)
    
    # Draw Background
    CoreGraphics.CGContextSetRGBFillColor(context, 0.1, 0.1, 0.1, 1.0)
    rect = CoreGraphics.CGRectMake(0, 0, size, size)
    
    # Rounded rect
    radius = size * 0.225
    CoreGraphics.CGContextBeginPath(context)
    CoreGraphics.CGContextMoveToPoint(context, size, size/2)
    CoreGraphics.CGContextAddArcToPoint(context, size, size, size/2, size, radius)
    CoreGraphics.CGContextAddArcToPoint(context, 0, size, 0, size/2, radius)
    CoreGraphics.CGContextAddArcToPoint(context, 0, 0, size/2, 0, radius)
    CoreGraphics.CGContextAddArcToPoint(context, size, 0, size, size/2, radius)
    CoreGraphics.CGContextClosePath(context)
    CoreGraphics.CGContextFillPath(context)

    # We draw a lightning emoji
    text = Cocoa.NSString.stringWithString_("⚡")
    font = Cocoa.NSFont.systemFontOfSize_(size * 0.6)
    attributes = {
        Cocoa.NSFontAttributeName: font,
        Cocoa.NSForegroundColorAttributeName: Cocoa.NSColor.yellowColor()
    }
    textSize = text.sizeWithAttributes_(attributes)
    
    CoreGraphics.CGContextSaveGState(context)
    Cocoa.NSGraphicsContext.setCurrentContext_(Cocoa.NSGraphicsContext.graphicsContextWithCGContext_flipped_(context, False))
    text.drawAtPoint_withAttributes_(Cocoa.NSMakePoint((size - textSize.width) / 2, (size - textSize.height) / 2.2), attributes)
    Cocoa.NSGraphicsContext.currentContext().flushGraphics()
    CoreGraphics.CGContextRestoreGState(context)
    
    image = CoreGraphics.CGBitmapContextCreateImage(context)
    url = Cocoa.NSURL.fileURLWithPath_(filename)
    dest = CoreGraphics.CGImageDestinationCreateWithURL(url, Cocoa.kUTTypePNG, 1, None)
    CoreGraphics.CGImageDestinationAddImage(dest, image, None)
    CoreGraphics.CGImageDestinationFinalize(dest)

sizes = [16, 32, 64, 128, 256, 512, 1024]
for s in sizes:
    create_icon(s, f"MyIcon.iconset/icon_{s}x{s}.png")
    if s < 512:
        create_icon(s * 2, f"MyIcon.iconset/icon_{s}x{s}@2x.png")

os.system('iconutil -c icns MyIcon.iconset -o AppIcon.icns')
os.system('rm -rf MyIcon.iconset')
