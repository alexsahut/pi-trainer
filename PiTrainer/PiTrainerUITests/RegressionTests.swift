import XCTest

final class RegressionTests: XCTestCase {
    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }

    func testFirstDigitVisibility() throws {
        // Naviguer vers la session via l'identifiant
        let startButton = app.buttons["home.start_button"]
        XCTAssertTrue(startButton.waitForExistence(timeout: 5), "Le bouton 'Démarrer' devrait exister.")
        startButton.tap()
        
        // Vérifier que le "3." est présent via l'identifiant
        let integerPart = app.staticTexts["session.integer_part"]
        XCTAssertTrue(integerPart.waitForExistence(timeout: 5), "La partie entière '3.' devrait être visible.")
        
        // Taper un chiffre '1' sur le clavier ProPad
        // Pour ProPad, les boutons n'ont pas encore d'ID, on utilise le label
        let digit1 = app.buttons["1"]
        XCTAssertTrue(digit1.waitForExistence(timeout: 2), "Le bouton '1' du clavier devrait exister.")
        digit1.tap()
        
        // Vérifier que '1' apparaît dans la grille
        let typedDigit = app.staticTexts["1"]
        XCTAssertTrue(typedDigit.waitForExistence(timeout: 2), "Le chiffre '1' devrait apparaître après la saisie.")
    }
}
