//
//  main.swift
//  DialogNotifier
//
//  Application entry point. Top-level expressions are only valid in main.swift.
//

import AppKit

let app = NSApplication.shared
let delegate = NotifierAppDelegate()
app.delegate = delegate
app.run()
