//
//  NotifierImages.swift
//  DialogNotifier
//
//  Image utilities needed by the notifier helper. SwiftUI-free, no quitDialog dependency.
//

import Foundation
import AppKit

func getImageFromPath(fileImagePath: String, returnErrorImage: Bool = false) -> NSImage? {
    writeLog("Getting image from path \(fileImagePath)")

    let errorImage = NSImage(
        systemSymbolName: "questionmark.square.dashed",
        accessibilityDescription: nil
    )

    // Base64 image data
    if fileImagePath.hasPrefix("base64") {
        return getImageFromBase64(base64String: fileImagePath.replacing("base64=", with: ""))
    }

    let urlPath: URL
    if fileImagePath.hasPrefix("http") {
        guard let url = URL(string: fileImagePath) else {
            return returnErrorImage ? errorImage : nil
        }
        urlPath = url
    } else {
        urlPath = URL(fileURLWithPath: fileImagePath)
    }

    guard let imageData = try? Data(contentsOf: urlPath) else {
        writeLog("Could not load image data from \(fileImagePath)", logLevel: .error)
        return returnErrorImage ? errorImage : nil
    }

    return NSImage(data: imageData) ?? errorImage
}

func getImageFromBase64(base64String: String) -> NSImage? {
    guard let imageData = Data(base64Encoded: base64String, options: .ignoreUnknownCharacters) else {
        return nil
    }
    return NSImage(data: imageData)
}

func getAppIcon(appPath: String, withSize: CGFloat = 300) -> NSImage {
    writeLog("Getting app icon from \(appPath)")
    let image = NSImage()
    if let rep = NSWorkspace.shared.icon(forFile: appPath)
        .bestRepresentation(for: NSRect(x: 0, y: 0, width: withSize, height: withSize),
                            context: nil, hints: nil) {
        image.size = rep.size
        image.addRepresentation(rep)
    }
    return image
}

func savePNG(image: NSImage, path: String) {
    guard let tiff = image.tiffRepresentation,
          let rep = NSBitmapImageRep(data: tiff),
          let pngData = rep.representation(using: .png, properties: [:]) else {
        writeLog("Failed to convert image to PNG", logLevel: .error)
        return
    }
    do {
        try pngData.write(to: URL(fileURLWithPath: path))
    } catch {
        writeLog("Failed to save PNG to \(path): \(error)", logLevel: .error)
    }
}
