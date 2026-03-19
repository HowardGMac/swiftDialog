//
//  NotifierApp.swift
//  DialogNotifier
//
//  App delegate for the DialogNotifier helper. Entry point is in main.swift.
//

import AppKit
import UserNotifications

class NotifierAppDelegate: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate {

    private let args = NotifierArguments()

    func applicationWillFinishLaunching(_ notification: Notification) {
        notifierDebugMode = args.debugMode
        UNUserNotificationCenter.current().delegate = self
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Request authorisation (non-blocking; completion fires asynchronously)
        requestNotificationAuthorisation()

        if args.removeNotification {
            writeLog("Removing notification(s)")
            removeNotification(identifier: args.identifier.isEmpty ? nil : args.identifier)
            // Small delay to let the removal propagate before quitting
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                NSApp.terminate(nil)
            }
            return
        }

        writeLog("Sending notification")
        sendNotification(
            title: args.title,
            subtitle: args.subtitle,
            message: args.message,
            image: args.icon,
            identifier: args.identifier,
            acceptString: args.button1Text,
            acceptAction: args.button1Action,
            declineString: args.button2Text,
            declineAction: args.button2Action,
            soundEnabled: args.soundEnabled
        )

        // Allow time for the notification to be delivered before quitting.
        // The system delivers it asynchronously; 0.5 s is sufficient in practice.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            NSApp.terminate(nil)
        }
    }

    // MARK: - UNUserNotificationCenterDelegate

    /// Called when the user interacts with a delivered notification.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        writeLog("Received notification response", logLevel: .debug)

        if response.notification.request.content.categoryIdentifier == "SD_NOTIFICATION" {
            processNotification(response: response)
        } else {
            writeLog("Unknown notification category", logLevel: .debug)
        }

        completionHandler()
        NSApp.terminate(nil)
    }

    /// Called when a notification arrives while the app is in the foreground.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }
}
