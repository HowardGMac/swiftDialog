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
        let capturedArgs = args
        Task {
            await runNotifierFlow(args: capturedArgs)
        }
    }

    // Main async flow — awaiting authorisation keeps the app alive
    // for exactly as long as the permission prompt is visible.
    private func runNotifierFlow(args: NotifierArguments) async {
        let center = UNUserNotificationCenter.current()

        // Check current status first so we only prompt when genuinely undetermined.
        let settings = await center.notificationSettings()

        if settings.authorizationStatus == .notDetermined {
            writeLog("Requesting notification authorisation", logLevel: .debug)
            do {
                // This await returns only after the user taps Allow or Don't Allow,
                // so the app stays alive for the duration of the permission prompt.
                let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
                writeLog("Notification authorisation \(granted ? "granted" : "denied")", logLevel: .debug)
                if !granted {
                    await MainActor.run { NSApp.terminate(nil) }
                    return
                }
            } catch {
                writeLog(error.localizedDescription, logLevel: .error)
                await MainActor.run { NSApp.terminate(nil) }
                return
            }
        } else if settings.authorizationStatus == .denied {
            writeLog("Notifications are denied — nothing to send", logLevel: .error)
            await MainActor.run { NSApp.terminate(nil) }
            return
        }

        if args.removeNotification {
            writeLog("Removing notification(s)")
            removeNotification(identifier: args.identifier.isEmpty ? nil : args.identifier)
            try? await Task.sleep(for: .milliseconds(500))
            await MainActor.run { NSApp.terminate(nil) }
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

        // Small delay to ensure the notification request has been handed off
        // to the system before we exit.
        try? await Task.sleep(for: .milliseconds(500))
        await MainActor.run { NSApp.terminate(nil) }
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
