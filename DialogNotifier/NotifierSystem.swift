//
//  NotifierSystem.swift
//  DialogNotifier
//
//  Minimal system utilities needed by the notifier helper.
//

import Foundation
import AppKit

func openSpecifiedURL(urlToOpen: String) {
    writeLog("Opening URL \(urlToOpen)")
    if let url = URL(string: urlToOpen) {
        NSWorkspace.shared.open(url)
    }
}

func shell(_ command: String) -> String {
    writeLog("Running shell command \(command)")
    let task = Process()
    let pipe = Pipe()
    task.standardOutput = pipe
    task.standardError = pipe
    task.arguments = ["-c", command]
    task.launchPath = "/bin/zsh"
    task.launch()
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    return String(data: data, encoding: .utf8) ?? ""
}
