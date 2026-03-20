//
//  NotifierNotifications.swift
//  DialogNotifier
//
//  Notification send/remove/response logic, adapted from dialog's Notifications.swift.
//

import Foundation
import UserNotifications
import AppKit

func removeNotification(identifier: String? = nil) {
    let center = UNUserNotificationCenter.current()
    if let id = identifier, !id.isEmpty {
        center.removeDeliveredNotifications(withIdentifiers: [id])
        center.removePendingNotificationRequests(withIdentifiers: [id])
        writeLog("Removed notification with identifier: \(id)")
    } else {
        center.removeAllDeliveredNotifications()
        center.removeAllPendingNotificationRequests()
        writeLog("Removed all notifications")
    }
}

func sendNotification(
    title: String = "",
    subtitle: String = "",
    message: String = "",
    image: String = "",
    identifier: String = "",
    acceptString: String = "Open",
    acceptAction: String = "",
    declineString: String = "Close",
    declineAction: String = "",
    soundEnabled: Bool = false
) {
    let center = UNUserNotificationCenter.current()
    let tempImagePath = "/var/tmp/sdnotification.png"

    // Build action buttons
    var actions: [UNNotificationAction] = []
    if !acceptString.isEmpty {
        actions.append(UNNotificationAction(identifier: "ACCEPT_ACTION_LABEL",
                                            title: acceptString, options: []))
    }
    if !declineString.isEmpty {
        actions.append(UNNotificationAction(identifier: "DECLINE_ACTION_LABEL",
                                            title: declineString, options: []))
    }

    // Prepare icon attachment
    if !image.isEmpty {
        var importedImage: NSImage

        if image.hasSuffix(".app") || image.hasSuffix("prefPane") {
            importedImage = getAppIcon(appPath: image)
        } else if image.lowercased().hasPrefix("sf=") {
            let config = NSImage.SymbolConfiguration(pointSize: 128, weight: .thin)
            importedImage = NSImage(
                systemSymbolName: String(image.dropFirst(3)),
                accessibilityDescription: "SF Symbol"
            )?.withSymbolConfiguration(config) ?? NSImage(
                systemSymbolName: "applelogo",
                accessibilityDescription: nil
            )!
        } else {
            importedImage = getImageFromPath(fileImagePath: image, returnErrorImage: true)
                ?? NSImage(systemSymbolName: "applelogo", accessibilityDescription: nil)!
        }

        savePNG(image: importedImage, path: tempImagePath)
    }

    // Register notification category
    let category = UNNotificationCategory(
        identifier: "SD_NOTIFICATION",
        actions: actions,
        intentIdentifiers: [],
        hiddenPreviewsBodyPlaceholder: "",
        options: .customDismissAction
    )
    center.setNotificationCategories([category])

    center.getNotificationSettings { settings in
        guard settings.authorizationStatus == .authorized ||
              settings.authorizationStatus == .provisional else {
            writeLog("Notifications not authorised (status: \(settings.authorizationStatus.rawValue))", logLevel: .error)
            return
        }

        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = subtitle
        content.body = message
        content.userInfo = ["ACCEPT_ACTION": acceptAction, "DECLINE_ACTION": declineAction]
        content.categoryIdentifier = "SD_NOTIFICATION"

        if soundEnabled {
            content.sound = .default
        }

        // Attach image if present
        if !image.isEmpty {
            do {
                let attachment = try UNNotificationAttachment(
                    identifier: "AttachedContent",
                    url: URL(fileURLWithPath: tempImagePath),
                    options: nil
                )
                content.attachments = [attachment]
            } catch {
                writeLog(error.localizedDescription, logLevel: .error)
            }
        }

        let request = UNNotificationRequest(
            identifier: identifier.isEmpty ? UUID().uuidString : identifier,
            content: content,
            trigger: nil
        )

        center.add(request) { error in
            if let error {
                writeLog(error.localizedDescription, logLevel: .error)
            }
        }
    }
}

func processNotification(response: UNNotificationResponse) {
    let userInfo = response.notification.request.content.userInfo
    let acceptAction = userInfo["ACCEPT_ACTION"] as? String ?? ""
    let declineAction = userInfo["DECLINE_ACTION"] as? String ?? ""

    writeLog("acceptAction: \(acceptAction)")
    writeLog("declineAction: \(declineAction)")

    switch response.actionIdentifier {
    case "ACCEPT_ACTION_LABEL", UNNotificationDefaultActionIdentifier:
        writeLog("user accepted", logLevel: .debug)
        notificationAction(acceptAction)

    case "DECLINE_ACTION_LABEL":
        writeLog("user declined", logLevel: .debug)
        notificationAction(declineAction)

    case UNNotificationDismissActionIdentifier:
        writeLog("notification dismissed", logLevel: .debug)

    default:
        break
    }
}

func notificationAction(_ action: String) {
    writeLog("Processing notification action: \(action)")
    if action.contains("://") {
        openSpecifiedURL(urlToOpen: action)
    } else if !action.isEmpty {
        _ = shell(action)
    }
}
