import Foundation
import UserNotifications
import Combine

/// Manages local notifications and user consent
class NotificationService: NSObject, ObservableObject {
    
    static let shared = NotificationService()
    
    private let center = UNUserNotificationCenter.current()
    private let requestedKey = "zen_athlete_notifications_requested"
    private let enabledKey = "zen_athlete_notifications_enabled"
    
    @Published var isEnabled: Bool {
        didSet { 
            UserDefaults.standard.set(isEnabled, forKey: enabledKey)
            if !isEnabled {
                cancelPendingReminders()
            }
        }
    }
    
    private override init() {
        self.isEnabled = UserDefaults.standard.bool(forKey: enabledKey)
        super.init()
    }
    
    /// Requests authorization for local notifications if not already done
    func requestAuthorization(completion: @escaping (Bool) -> Void = { _ in }) {
        guard !UserDefaults.standard.bool(forKey: requestedKey) else {
            // Already requested once, don't trigger system alert again
            checkActualStatus(completion: completion)
            return
        }
        
        center.requestAuthorization(options: [.alert, .badge, .sound]) { [weak self] granted, error in
            if let error = error {
                print("❌ Notification authorization error: \(error)")
            }
            
            DispatchQueue.main.async {
                self?.isEnabled = granted
                UserDefaults.standard.set(true, forKey: self?.requestedKey ?? "")
                completion(granted)
            }
        }
    }
    
    /// Schedules a reminder for tomorrow at 8:00 PM if none exists
    func scheduleDailyReminder(streak: Int) {
        guard isEnabled else { return }
        
        // Cancel existing to avoid duplicates
        cancelPendingReminders()
        
        let content = UNMutableNotificationContent()
        content.title = String(localized: "notification.reminder.title")
        
        if streak > 0 {
            let format = NSLocalizedString("notification.reminder.body.streak %lld", comment: "")
            content.body = String.localizedStringWithFormat(format, streak)
        } else {
            content.body = String(localized: "notification.reminder.body.default")
        }
        
        content.sound = .default
        
        // Schedule for 8:00 PM tomorrow
        var dateComponents = DateComponents()
        dateComponents.hour = 20
        dateComponents.minute = 0
        
        // Trigger daily at 8 PM
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: "daily_practice_reminder",
            content: content,
            trigger: trigger
        )
        
        center.add(request) { error in
            if let error = error {
                print("❌ Error scheduling notification: \(error)")
            }
        }
    }
    
    func cancelPendingReminders() {
        center.removePendingNotificationRequests(withIdentifiers: ["daily_practice_reminder"])
    }
    
    private func checkActualStatus(completion: @escaping (Bool) -> Void) {
        center.getNotificationSettings { settings in
            let granted = settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
}
