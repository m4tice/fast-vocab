import XCTest

final class RecoveryFlowUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testRecoverableLessonResumesAtQuestionBoundary() throws {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing-recovery"]
        app.launch()

        let resume = app.buttons["home.resume"]
        XCTAssertTrue(resume.waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Lesson · question 1 of 6 · 3 hearts"].exists)
        resume.tap()

        XCTAssertTrue(app.otherElements["game.page"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["game.answer.der"].exists)
        XCTAssertTrue(app.staticTexts["3"].exists)
    }
}