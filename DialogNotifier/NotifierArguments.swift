//
//  NotifierArguments.swift
//  DialogNotifier
//
//  Minimal CLI argument parser for notification-relevant flags only.
//

import Foundation

struct NotifierArguments {
    var title: String = ""
    var subtitle: String = ""
    var message: String = ""
    var icon: String = ""
    var button1Text: String = ""
    var button1Action: String = ""
    var button2Text: String = ""
    var button2Action: String = ""
    var identifier: String = ""
    var soundEnabled: Bool = false
    var removeNotification: Bool = false
    var debugMode: Bool = false

    init() {
        let args = CommandLine.arguments
        var i = 1
        while i < args.count {
            let arg = args[i]
            switch arg {
            case "--title", "-t":
                title = nextValue(args: args, index: &i)
            case "--subtitle":
                subtitle = nextValue(args: args, index: &i)
            case "--message", "-m":
                message = nextValue(args: args, index: &i)
            case "--icon", "-i":
                icon = nextValue(args: args, index: &i)
            case "--button1text":
                button1Text = nextValue(args: args, index: &i)
            case "--button1action":
                button1Action = nextValue(args: args, index: &i)
            case "--button2text":
                button2Text = nextValue(args: args, index: &i)
            case "--button2action":
                button2Action = nextValue(args: args, index: &i)
            case "--identifier", "-id":
                identifier = nextValue(args: args, index: &i)
            case "--enablenotificationsounds":
                soundEnabled = true
            case "--remove":
                removeNotification = true
            case "--debug":
                debugMode = true
            default:
                break
            }
            i += 1
        }
    }

    // Reads the next argument as a value, advancing the index.
    // Returns empty string if the next token starts with "--" or is absent.
    private func nextValue(args: [String], index: inout Int) -> String {
        let next = index + 1
        guard next < args.count, !args[next].hasPrefix("-") else { return "" }
        index = next
        return args[next]
    }
}
