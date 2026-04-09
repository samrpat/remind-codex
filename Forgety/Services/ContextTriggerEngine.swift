import Foundation
import UserNotifications
import CoreLocation

final class ContextTriggerEngine: NSObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private let center = UNUserNotificationCenter.current()

    override init() {
        super.init()
        locationManager.delegate = self
    }

    func requestPermissions() async {
        _ = try? await center.requestAuthorization(options: [.alert, .badge, .sound])
        locationManager.requestAlwaysAuthorization()
    }

    func scheduleNotification(for reminder: ReminderItem) {
        let content = UNMutableNotificationContent()
        content.title = "Reminder"
        content.body = reminder.title
        content.sound = .default

        let request: UNNotificationRequest?
        switch reminder.trigger {
        case .time(let date):
            let comps = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
            let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
            request = UNNotificationRequest(identifier: reminder.id.uuidString, content: content, trigger: trigger)
        case .none:
            request = nil
        default:
            // Placeholder for location/WiFi/app-mode integration.
            let fallback = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
            request = UNNotificationRequest(identifier: reminder.id.uuidString, content: content, trigger: fallback)
        }

        if let request {
            center.add(request)
        }
    }

    func enqueueRepeatIfIncomplete(for reminder: ReminderItem) {
        guard reminder.status == .active else { return }
        let content = UNMutableNotificationContent()
        content.title = "Still pending"
        content.body = reminder.title
        content.interruptionLevel = .timeSensitive

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 30 * 60, repeats: false)
        let request = UNNotificationRequest(identifier: "repeat-\(reminder.id.uuidString)", content: content, trigger: trigger)
        center.add(request)
    }
}
