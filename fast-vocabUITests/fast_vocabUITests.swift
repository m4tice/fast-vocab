//
//  fast_vocabUITests.swift
//  fast-vocabUITests
//
//  Created by Nguyen Duc Tuan on 26/7/26.
//

import XCTest

final class fast_vocabUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testPrimaryLessonFlow() throws {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing"]
        app.launch()

        XCTAssertTrue(app.buttons["home.start"].waitForExistence(timeout: 5))
        app.buttons["home.start"].tap()
        XCTAssertTrue(app.buttons["topic.household-a1"].waitForExistence(timeout: 2))
        app.buttons["topic.household-a1"].tap()

        answerArticle("der", in: app)
        answerText("Stühle", in: app)
        answerText("lamp", in: app)
        answerArticle("das", in: app)
        answerText("Türen", in: app)
        answerText("window", in: app)

        XCTAssertTrue(app.buttons["score.home"].waitForExistence(timeout: 3))
        app.buttons["score.home"].tap()
        XCTAssertTrue(app.buttons["home.start"].waitForExistence(timeout: 2))
    }

    @MainActor
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }

    private func answerArticle(_ article: String, in app: XCUIApplication) {
        let button = app.buttons["game.answer.\(article)"]
        XCTAssertTrue(button.waitForExistence(timeout: 2))
        button.tap()
        continueLesson(in: app)
    }

    private func answerText(_ answer: String, in app: XCUIApplication) {
        let field = app.textFields["game.answer.text"]
        XCTAssertTrue(field.waitForExistence(timeout: 2))
        field.tap()
        field.typeText(answer)
        app.buttons["game.check"].tap()
        continueLesson(in: app)
    }

    private func continueLesson(in app: XCUIApplication) {
        let button = app.buttons["game.continue"]
        XCTAssertTrue(button.waitForExistence(timeout: 2))
        button.tap()
    }
}
