//
//  NotifierLog.swift
//  DialogNotifier
//
//  Minimal logging for the notifier helper — no dependency on appvars or appArguments.
//

import Foundation
import OSLog

let notifierLog = OSLog(
    subsystem: Bundle.main.bundleIdentifier ?? "au.csiro.dialog.notifier",
    category: "main"
)

var notifierDebugMode = false

struct StandardError: TextOutputStream {
    func write(_ string: String) {
        fputs(string, stderr)
    }
}

func writeLog(_ message: String, logLevel: OSLogType = .info, log: OSLog = notifierLog) {
    os_log("%{public}@", log: log, type: logLevel, message)
    if logLevel == .error || notifierDebugMode {
        var standardError = StandardError()
        print("\(logLevel.stringValue.uppercased()): \(message)", to: &standardError)
    }
}

extension OSLogType {
    var stringValue: String {
        switch self {
        case .default: return "default"
        case .info:    return "info"
        case .debug:   return "debug"
        case .error:   return "error"
        case .fault:   return "fault"
        default:       return "unknown"
        }
    }
}
