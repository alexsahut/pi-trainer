import XCTest
import UserNotifications
@testable import PiTrainer

/// Story 17.5: Tests for challenge notification scheduling and deep link handling
@MainActor
class NotificationServiceChallengeTests: XCTestCase {

    override func tearDown() {
        // Reset shared singleton state to avoid inter-test pollution
        NotificationService.shared.pendingDeepLink = nil
        NotificationService.shared.cancelPendingChallengeReminders()
        super.tearDown()
    }

    // MARK: - Schedule / Cancel Logic

    func testScheduleDailyChallengeReminder_WhenEnabled_SchedulesNotification() {
        let service = NotificationService.shared
        let originalEnabled = service.isEnabled

        // Ensure enabled
        service.isEnabled = true

        service.scheduleDailyChallengeReminder()

        let expectation = self.expectation(description: "Pending notifications fetched")
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let challengeRequests = requests.filter { $0.identifier == "daily_challenge_reminder" }
            XCTAssertFalse(challengeRequests.isEmpty, "Should have scheduled a daily_challenge_reminder")

            if let request = challengeRequests.first {
                // Verify trigger is calendar-based at 9:00 AM repeating
                if let trigger = request.trigger as? UNCalendarNotificationTrigger {
                    XCTAssertEqual(trigger.dateComponents.hour, 9)
                    XCTAssertEqual(trigger.dateComponents.minute, 0)
                    XCTAssertTrue(trigger.repeats)
                } else {
                    XCTFail("Trigger should be UNCalendarNotificationTrigger")
                }
            }

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5.0)

        // Cleanup
        service.cancelPendingChallengeReminders()
        service.isEnabled = originalEnabled
    }

    func testScheduleDailyChallengeReminder_WhenDisabled_DoesNotSchedule() {
        let service = NotificationService.shared
        let originalEnabled = service.isEnabled

        // Cancel any existing, then disable (didSet will fire and cancel reminders — expected behavior)
        service.isEnabled = false

        service.scheduleDailyChallengeReminder()

        let expectation = self.expectation(description: "Pending notifications fetched")
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let challengeRequests = requests.filter { $0.identifier == "daily_challenge_reminder" }
            XCTAssertTrue(challengeRequests.isEmpty, "Should NOT schedule when notifications are disabled")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5.0)

        // Restore
        service.isEnabled = originalEnabled
    }

    func testCancelPendingChallengeReminders_RemovesCorrectIdentifier() {
        let service = NotificationService.shared
        let originalEnabled = service.isEnabled
        service.isEnabled = true

        // Schedule first
        service.scheduleDailyChallengeReminder()

        // Then cancel
        service.cancelPendingChallengeReminders()

        let expectation = self.expectation(description: "Pending notifications fetched after cancel")
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let challengeRequests = requests.filter { $0.identifier == "daily_challenge_reminder" }
            XCTAssertTrue(challengeRequests.isEmpty, "Challenge reminder should be cancelled")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5.0)

        service.isEnabled = originalEnabled
    }

    func testCancelPendingReminders_AlsoCancelsChallengeReminder() {
        // Fix #1 verification: cancelPendingReminders() must cancel both practice AND challenge reminders
        let service = NotificationService.shared
        let originalEnabled = service.isEnabled
        service.isEnabled = true

        service.scheduleDailyChallengeReminder()
        service.cancelPendingReminders()  // Should cancel both

        let expectation = self.expectation(description: "Check challenge reminder also cancelled")
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let challengeRequests = requests.filter { $0.identifier == "daily_challenge_reminder" }
            XCTAssertTrue(challengeRequests.isEmpty, "cancelPendingReminders() should also cancel challenge reminders")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5.0)

        service.isEnabled = originalEnabled
    }

    // MARK: - Deep Link Routing

    func testDeepLink_ChallengeIdentifier_ReturnsChallengeHub() {
        // Tests actual identifier routing logic in delegate (Fix #2)
        let service = NotificationService.shared
        XCTAssertEqual(service.deepLink(forNotificationIdentifier: "daily_challenge_reminder"), .challengeHub)
    }

    func testDeepLink_UnknownIdentifier_ReturnsNil() {
        // Verify non-challenge notifications don't produce a deep link
        let service = NotificationService.shared
        XCTAssertNil(service.deepLink(forNotificationIdentifier: "daily_practice_reminder"))
        XCTAssertNil(service.deepLink(forNotificationIdentifier: "unknown_identifier"))
        XCTAssertNil(service.deepLink(forNotificationIdentifier: ""))
    }

    func testDeepLink_PendingProperty_AssignmentAndReset() {
        let service = NotificationService.shared

        // Set deep link as the delegate would
        service.pendingDeepLink = .challengeHub
        XCTAssertEqual(service.pendingDeepLink, .challengeHub)

        // Reset after navigation
        service.pendingDeepLink = nil
        XCTAssertNil(service.pendingDeepLink)
    }

    func testDeepLink_Equatable() {
        XCTAssertEqual(DeepLink.challengeHub, DeepLink.challengeHub)
    }
}
