
import XCTest
@testable import PiTrainer

final class AssetIntegrityTests: XCTestCase {

    func testAllConstantsHaveValidResourceFiles() {
        for constant in Constant.allCases {
            print("Checking asset integrity for constant: \(constant.symbol) (\(constant.rawValue))")
            
            // Revert to standard class-based bundle lookup.
            // This should work now that files are correctly in the resource bundle.
            let bundle = Bundle(for: SessionViewModel.self)
            print("Using Bundle: \(bundle.bundlePath)")
            
            var provider = FileDigitsProvider(constant: constant, bundle: bundle)
            
            // Assert we have digits
            do {
                try provider.loadDigits()
                XCTAssertGreaterThan(provider.totalDigits, 0, "Digits file for \(constant.symbol) (\(constant.resourceName).txt) should not be empty")
            } catch {
                XCTFail("❌ FAILED to load \(constant.resourceName): \(error). Bundle Path: \(bundle.bundlePath).")
            }
        }
    }
}
