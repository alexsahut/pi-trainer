# Story 17.5: Notifications push locales quotidiennes

Status: done

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a **utilisateur**,
I want **recevoir une notification quotidienne m'informant qu'un nouveau challenge est disponible**,
so that **je ne rate aucun challenge et maintienne mon engagement quotidien**.

## Acceptance Criteria

1. **AC1 — Demande de permission** : Quand l'utilisateur accède au Challenge Hub pour la première fois, la permission de notification est demandée via `UNUserNotificationCenter` (en complément de la demande existante après 5 sessions de practice). Si déjà autorisé, pas de re-demande.

2. **AC2 — Programmation de la notification quotidienne** : Quand les notifications sont autorisées, une notification locale est programmée avec un trigger quotidien répétitif (`UNCalendarNotificationTrigger`, `repeats: true`). Le contenu affiche un message motivant lié au challenge (distinct du rappel de practice existant). L'heure de déclenchement est 9h00 (matin, avant la journée — distinct du rappel practice à 20h00).

3. **AC3 — Deep link vers le Challenge Hub** : Quand l'utilisateur tape sur la notification challenge, l'app s'ouvre et navigue directement vers le Challenge Hub via `NavigationCoordinator.push(.challengeHub)`.

4. **AC4 — Gestion des permissions désactivées** : Quand l'utilisateur a désactivé les notifications dans les réglages iOS, aucune notification n'est envoyée et aucune erreur n'est générée. Le toggle dans SettingsView reflète l'état réel.

5. **AC5 — Tests unitaires** : Tests couvrant la programmation de la notification challenge, la vérification que le bon identifier est utilisé, et que la notification n'est pas programmée quand les permissions sont désactivées.

## Tasks / Subtasks

- [x] Task 1 — Étendre NotificationService pour les notifications challenge (AC: #2, #4)
  - [x] 1.1 Ajouter `func scheduleDailyChallengeReminder()` dans `NotificationService.swift`
  - [x] 1.2 Identifier : `"daily_challenge_reminder"` (distinct de `"daily_practice_reminder"`)
  - [x] 1.3 Trigger : `UNCalendarNotificationTrigger` avec `hour: 9, minute: 0, repeats: true`
  - [x] 1.4 Contenu : titre = `notification.challenge.title`, body = `notification.challenge.body` (nouvelles clés localisées)
  - [x] 1.5 Guard `isEnabled` — ne pas programmer si notifications désactivées
  - [x] 1.6 Ajouter `func cancelPendingChallengeReminders()` avec l'identifier `"daily_challenge_reminder"`
  - [x] 1.7 Modifier `cancelPendingReminders()` existant : aussi annuler `"daily_challenge_reminder"` (ou renommer en `cancelAllReminders()`) — Implémenté via `didSet` de `isEnabled` (appel des deux cancel)
  - [x] 1.8 Appeler `cancelPendingChallengeReminders()` dans le `didSet` de `isEnabled` quand `!isEnabled`
- [x] Task 2 — Deep link : notification → Challenge Hub (AC: #3)
  - [x] 2.1 Conformer `NotificationService` à `UNUserNotificationCenterDelegate`
  - [x] 2.2 Implémenter `userNotificationCenter(_:didReceive:withCompletionHandler:)` — détecter `"daily_challenge_reminder"` identifier
  - [x] 2.3 Ajouter `@Published var pendingDeepLink: DeepLink? = nil` sur `NotificationService` (enum `DeepLink { case challengeHub }`)
  - [x] 2.4 Dans `PiTrainerApp.swift` : assigner le delegate au lancement (`UNUserNotificationCenter.current().delegate = NotificationService.shared`)
  - [x] 2.5 Dans `HomeView` : observer `NotificationService.shared.pendingDeepLink` via `.onReceive` et naviguer vers `.challengeHub` quand déclenché
  - [x] 2.6 Réinitialiser `pendingDeepLink = nil` après navigation
- [x] Task 3 — Déclenchement de la programmation (AC: #1, #2)
  - [x] 3.1 Dans `ChallengeHubView.onAppear` : appeler `NotificationService.shared.requestAuthorization()` si pas encore demandé
  - [x] 3.2 Après autorisation accordée : appeler `NotificationService.shared.scheduleDailyChallengeReminder()`
  - [x] 3.3 Dans `StatsStore` ou là où `scheduleDailyReminder(streak:)` est déjà appelé : aussi appeler `scheduleDailyChallengeReminder()` pour maintenir la notification active
- [x] Task 4 — Clés de localisation (AC: #2)
  - [x] 4.1 Ajouter dans `Localizable.xcstrings` : `notification.challenge.title` — FR: "Challenge du jour 🎯", EN: "Daily Challenge 🎯"
  - [x] 4.2 Ajouter dans `Localizable.xcstrings` : `notification.challenge.body` — FR: "Un nouveau challenge vous attend ! Combien de décimales reconnaîtrez-vous ?", EN: "A new challenge awaits! How many digits will you recognize?"
- [x] Task 5 — Tests unitaires (AC: #5)
  - [x] 5.1 Créer `PiTrainer/PiTrainerTests/NotificationServiceChallengeTests.swift`
  - [x] 5.2 `testScheduleDailyChallengeReminder_WhenEnabled_SchedulesNotification` — vérifier que la requête est ajoutée au center
  - [x] 5.3 `testScheduleDailyChallengeReminder_WhenDisabled_DoesNotSchedule` — vérifier qu'aucune requête n'est ajoutée
  - [x] 5.4 `testCancelPendingChallengeReminders_RemovesCorrectIdentifier` — vérifier que seul `"daily_challenge_reminder"` est annulé
  - [x] 5.5 `testDeepLink_ChallengeNotification_SetsPendingDeepLink` — vérifier que le delegate parse correctement l'identifier

## Dev Notes

### Contexte architectural

Cette story est la **cinquième** de l'Epic 17. Elle est **indépendante** des stories 17.1–17.4 (aucune dépendance fonctionnelle directe), mais partage le même contexte Challenge.

**Infrastructure existante à réutiliser :**

Le projet a déjà un `NotificationService` complet dans `Core/Persistence/NotificationService.swift` :
- Singleton `NotificationService.shared` avec `@Published var isEnabled`
- `requestAuthorization(completion:)` — gère le flag `requestedKey` pour ne pas re-demander
- `scheduleDailyReminder(streak:)` — programme un rappel practice à 20h00 avec identifier `"daily_practice_reminder"`
- `cancelPendingReminders()` — annule `"daily_practice_reminder"`
- Déjà appelé dans `StatsStore.swift:292` après enregistrement d'un record
- Toggle dans `SettingsView.swift` — binding vers `NotificationService.shared.isEnabled`

⚠️ **IMPORTANT — Le service utilise `ObservableObject` (pas `@Observable`)** : c'est un choix historique (Story 5.x). NE PAS migrer vers `@Observable` — hors scope. Utiliser `@StateObject` ou `.onReceive` pour observer.

⚠️ **`scheduleDailyReminder` n'est PAS appelé depuis le Challenge Hub** — seulement depuis `StatsStore` après un record de practice. Cette story ajoute un second canal de notification spécifique aux challenges.

### Task 1 — Extension de NotificationService

**Pattern à suivre** : identique à `scheduleDailyReminder(streak:)` mais avec un identifier et un horaire différents.

```swift
/// Story 17.5: Daily challenge notification at 9:00 AM
func scheduleDailyChallengeReminder() {
    guard isEnabled else { return }

    cancelPendingChallengeReminders()

    let content = UNMutableNotificationContent()
    content.title = String(localized: "notification.challenge.title")
    content.body = String(localized: "notification.challenge.body")
    content.sound = .default
    content.categoryIdentifier = "daily_challenge"

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
```

**Modification de `cancelPendingReminders()`** : aussi annuler les challenge reminders, ou mieux — appeler `cancelPendingChallengeReminders()` dans le `didSet` de `isEnabled`.

Modification du `didSet` de `isEnabled` :
```swift
@Published var isEnabled: Bool {
    didSet {
        UserDefaults.standard.set(isEnabled, forKey: enabledKey)
        if !isEnabled {
            cancelPendingReminders()
            cancelPendingChallengeReminders()  // Story 17.5
        }
    }
}
```

### Task 2 — Deep link via UNUserNotificationCenterDelegate

**Le problème** : Actuellement, `PiTrainerApp` ne configure pas de notification delegate. Quand l'utilisateur tape sur une notification, l'app s'ouvre mais atterrit sur le Home sans navigation.

**Solution** :

1. Ajouter un enum `DeepLink` :
```swift
enum DeepLink {
    case challengeHub
}
```

2. Conformer `NotificationService` à `UNUserNotificationCenterDelegate` :
```swift
// NotificationService est déjà NSObject — conformance directe
extension NotificationService: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        if response.notification.request.identifier == "daily_challenge_reminder" {
            DispatchQueue.main.async {
                self.pendingDeepLink = .challengeHub
            }
        }
        completionHandler()
    }

    // Show notification even when app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }
}
```

3. Dans `PiTrainerApp.init()` : assigner le delegate. SwiftUI n'a pas de `init()` standard — utiliser `.onAppear` ou un `init()` custom :
```swift
@main
struct PiTrainerApp: App {
    @State private var navigationCoordinator = NavigationCoordinator()

    init() {
        UNUserNotificationCenter.current().delegate = NotificationService.shared
    }

    var body: some Scene { ... }
}
```

4. Dans `HomeView` : observer `pendingDeepLink` via `.onReceive` :
```swift
.onReceive(NotificationService.shared.$pendingDeepLink) { deepLink in
    if let deepLink, deepLink == .challengeHub {
        coordinator.push(.challengeHub)
        NotificationService.shared.pendingDeepLink = nil
    }
}
```

⚠️ **Piège SwiftUI** : `.onReceive` avec `@Published` fonctionne car `NotificationService` est `ObservableObject`. Si c'était `@Observable`, il faudrait un pattern différent.

⚠️ **Piège deep link au lancement** : si l'app est complètement fermée (cold start) et l'utilisateur tape la notification, le delegate `didReceive` est appelé AVANT que `HomeView` soit monté. Le `pendingDeepLink` sera défini, et quand `HomeView.onAppear` se déclenche, le `.onReceive` devrait capter la valeur. Tester ce scénario sur device.

### Task 3 — Déclenchement de la programmation

**Quand programmer la notification challenge ?**
- **Au premier accès au Challenge Hub** : `ChallengeHubView.onAppear` → `requestAuthorization` → si accordé → `scheduleDailyChallengeReminder()`
- **À chaque enregistrement de record practice** : dans `StatsStore` où `scheduleDailyReminder(streak:)` est déjà appelé (ligne 292), ajouter aussi `scheduleDailyChallengeReminder()`

Cela garantit que la notification challenge est reprogrammée régulièrement (au cas où elle serait annulée par l'OS).

### Task 5 — Tests

**Difficulté** : `UNUserNotificationCenter` ne peut pas être facilement mocké car c'est une classe finale système.

**Approches de test :**
- Tester la logique de garde (`isEnabled`) sans toucher au center
- Pour le deep link : tester que `pendingDeepLink` est correctement défini quand le delegate est appelé avec le bon identifier
- Utiliser un protocol wrapper autour de `UNUserNotificationCenter` SI l'injection est faisable — sinon, tester au niveau intégration

**Pattern de test recommandé** : Créer un `MockNotificationCenter` protocol :
```swift
protocol NotificationCenterProtocol {
    func add(_ request: UNNotificationRequest, withCompletionHandler: ((Error?) -> Void)?)
    func removePendingNotificationRequests(withIdentifiers: [String])
}
extension UNUserNotificationCenter: NotificationCenterProtocol {}
```

Puis injecter dans `NotificationService(center:)` — mais attention, le service est un singleton existant, ne pas casser l'API publique. Alternative : tester via le `pendingNotificationRequests` getter de `UNUserNotificationCenter.current()`.

### Fichiers impactés

| Fichier | Action |
|---|---|
| `PiTrainer/PiTrainer/Core/Persistence/NotificationService.swift` | **Modifier** : ajouter `scheduleDailyChallengeReminder()`, `cancelPendingChallengeReminders()`, `pendingDeepLink`, `DeepLink` enum, `UNUserNotificationCenterDelegate` |
| `PiTrainer/PiTrainer/PiTrainerApp.swift` | **Modifier** : assigner notification delegate dans `init()` |
| `PiTrainer/PiTrainer/HomeView.swift` | **Modifier** : observer `pendingDeepLink` via `.onReceive` |
| `PiTrainer/PiTrainer/Features/Challenges/ChallengeHubView.swift` | **Modifier** : `onAppear` → `requestAuthorization` + `scheduleDailyChallengeReminder` |
| `PiTrainer/PiTrainer/Core/Persistence/StatsStore.swift` | **Modifier** : ajouter appel `scheduleDailyChallengeReminder()` après `scheduleDailyReminder(streak:)` |
| `PiTrainer/PiTrainer/Localizable.xcstrings` | **Modifier** : ajouter 2 clés `notification.challenge.*` |
| `PiTrainer/PiTrainerTests/NotificationServiceChallengeTests.swift` | **Créer** : tests de la notification challenge |

**Aucune modification à** : `ChallengeService.swift`, `ChallengeViewModel.swift`, `ChallengeSessionView.swift`, `NavigationCoordinator.swift`, `SettingsView.swift` (le toggle existant contrôle déjà `isEnabled` qui impacte les deux types de notifications).

### Project Structure Notes

- La notification challenge utilise le même `NotificationService` singleton — pas de nouveau service
- Le deep link passe par `@Published pendingDeepLink` → observé dans `HomeView` — compatible avec le pattern `ObservableObject` existant
- Le `DeepLink` enum est placé dans `NotificationService.swift` car c'est le seul consommateur pour l'instant. Si d'autres deep links apparaissent, extraire vers un fichier dédié.

### References

- [Source: _bmad-output/planning-artifacts/epics-challenge-revamp.md — Story 17.5 AC, FR-C7, NFR-C3]
- [Source: PiTrainer/PiTrainer/Core/Persistence/NotificationService.swift — service existant à étendre]
- [Source: PiTrainer/PiTrainer/Core/Persistence/StatsStore.swift:292 — appel scheduleDailyReminder existant]
- [Source: PiTrainer/PiTrainer/SettingsView.swift:130 — toggle notification existant]
- [Source: PiTrainer/PiTrainer/SessionViewModel.swift:660 — requestAuthorization existant après 5 sessions]
- [Source: PiTrainer/PiTrainer/PiTrainerApp.swift — point d'entrée à modifier pour delegate]
- [Source: PiTrainer/PiTrainer/Shared/Navigation/NavigationCoordinator.swift — .challengeHub destination]
- [Source: PiTrainer/PiTrainer/Features/Challenges/ChallengeHubView.swift — onAppear trigger point]
- [Source: _bmad-output/planning-artifacts/architecture.md — patterns UserDefaults, singleton, Feature-Sliced]
- [Source: _bmad-output/project-context.md — règles Swift, testing, @Observable vs ObservableObject]

## Dev Agent Record

### Agent Model Used
Claude Opus 4.6

### Debug Log References
N/A

### Completion Notes List
- All 5 tasks implemented following existing NotificationService patterns
- Used `ObservableObject` + `.onReceive` pattern (not `@Observable`) as per project conventions
- Deep link implemented via `@Published pendingDeepLink` → `HomeView.onReceive`
- Delegate assigned in `PiTrainerApp.init()` for cold start support
- `scheduleDailyChallengeReminder()` called from both ChallengeHubView.onAppear and StatsStore after record save
- Build succeeded, all 41 challenge-related tests passed (5 notification + 18 ChallengeViewModel + 12 ChallengeScoreStore + 6 isNewRecord)

### File List
| Fichier | Action |
|---|---|
| `PiTrainer/PiTrainer/Core/Persistence/NotificationService.swift` | Modified: added `DeepLink` enum, `pendingDeepLink`, `scheduleDailyChallengeReminder()`, `cancelPendingChallengeReminders()`, `UNUserNotificationCenterDelegate` extension, updated `isEnabled.didSet` |
| `PiTrainer/PiTrainer/PiTrainerApp.swift` | Modified: added `import UserNotifications`, `init()` with delegate assignment |
| `PiTrainer/PiTrainer/HomeView.swift` | Modified: added `.onReceive` for `pendingDeepLink` deep link navigation |
| `PiTrainer/PiTrainer/Features/Challenges/ChallengeHubView.swift` | Modified: added `requestAuthorization` + `scheduleDailyChallengeReminder` in `.onAppear` |
| `PiTrainer/PiTrainer/Core/Persistence/StatsStore.swift` | Modified: added `scheduleDailyChallengeReminder()` after record save, `cancelPendingChallengeReminders()` in `reset()` |
| `PiTrainer/PiTrainer/Localizable.xcstrings` | Modified: added `notification.challenge.title` and `notification.challenge.body` (FR + EN) |
| `PiTrainer/PiTrainerTests/NotificationServiceChallengeTests.swift` | Created: 5 tests covering schedule/cancel/deeplink |

### Change Log
- 2026-03-03: Initial implementation of all 5 tasks — build succeeded, all tests passed
- 2026-03-04: Code review fixes — `cancelPendingReminders()` now cancels challenge reminders too; extracted `deepLink(forNotificationIdentifier:)` for testability; `checkActualStatus` syncs `isEnabled`; added `tearDown()` + 3 new tests (8 total, all passing)
