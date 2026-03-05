import Foundation
import UserNotifications
import Combine

/// Story 17.5: Deep link destinations triggered by notification taps
enum DeepLink: Equatable {
    case challengeHub
}

/// Manages local notifications and user consent
class NotificationService: NSObject, ObservableObject {

    static let shared = NotificationService()

    private let center = UNUserNotificationCenter.current()
    private let requestedKey = "zen_athlete_notifications_requested"
    private let enabledKey = "zen_athlete_notifications_enabled"

    /// Story 17.5: Pending deep link set by notification delegate, observed by HomeView
    @Published var pendingDeepLink: DeepLink? = nil

    @Published var isEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: enabledKey)
            if !isEnabled {
                cancelPendingReminders()
                cancelPendingChallengeReminders()
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

    // MARK: - Practice Reminders

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
        cancelPendingChallengeReminders()
    }

    // MARK: - Story 17.5: Challenge Reminders

    /// Schedules a daily challenge reminder at 9:00 AM
    func scheduleDailyChallengeReminder() {
        guard isEnabled else { return }

        cancelPendingChallengeReminders()

        let content = UNMutableNotificationContent()
        content.title = String(localized: "notification.challenge.title")
        content.body = String(localized: "notification.challenge.body")
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = 9
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let request = UNNotificationRequest(
            identifier: "daily_challenge_reminder",
            content: content,
            trigger: trigger
        )

        center.add(request) { error in
            if let error = error {
                print("❌ Error scheduling challenge notification: \(error)")
            }
        }
    }

    func cancelPendingChallengeReminders() {
        center.removePendingNotificationRequests(withIdentifiers: ["daily_challenge_reminder"])
    }

    // MARK: - Private

    private func checkActualStatus(completion: @escaping (Bool) -> Void) {
        center.getNotificationSettings { settings in
            let granted = settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional
            DispatchQueue.main.async {
                self.isEnabled = granted  // Sync with actual iOS permission state (user may have changed in Settings)
                completion(granted)
            }
        }
    }
}

// MARK: - Story 17.5: UNUserNotificationCenterDelegate

extension NotificationService: UNUserNotificationCenterDelegate {

    /// Maps a notification identifier to its deep link destination.
    /// Extracted for testability — this is the single source of truth for notification routing.
    func deepLink(forNotificationIdentifier identifier: String) -> DeepLink? {
        switch identifier {
        case "daily_challenge_reminder":
            return .challengeHub
        default:
            return nil
        }
    }

    /// Called when user taps a notification — route to appropriate deep link
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        if let deepLink = deepLink(forNotificationIdentifier: response.notification.request.identifier) {
            DispatchQueue.main.async {
                self.pendingDeepLink = deepLink
            }
        }
        completionHandler()
    }

    /// Show notification banner even when app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }
}
