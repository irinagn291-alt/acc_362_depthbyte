import XCTest

final class DiveTests: XCTestCase {
    private func advance(_ app: XCUIApplication) {
        let button = app.buttons["lab-action"]
        XCTAssertTrue(button.isHittable)
        button.tap()
    }

    private func capture(_ name: String) {
        RunLoop.current.run(until: Date().addingTimeInterval(0.4))
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    func testCurriculumAndUnlocks() {
        let store = UserDefaults(suiteName: "depthbyte.test." + UUID().uuidString)!
        let log = DiveLog(defaults: store)
        XCTAssertEqual(Course.sectors.count, 10)
        XCTAssertEqual(Course.dives.map(\.id), Array(1...100))
        XCTAssertEqual(Set(Course.dives.map(\.title)).count, 100)
        for dive in Course.dives {
            XCTAssertEqual(log.next?.id, dive.id)
            XCTAssertTrue(log.unlocked(dive))
            if dive.id < 100 { XCTAssertFalse(log.unlocked(Course.dives[dive.id])) }
            XCTAssertEqual(dive.repairSource.filter { $0 == "▧" }.count, 1)
            for phase in 0..<2 {
                let choices = dive.options(for: phase)
                XCTAssertEqual(Set(choices).count, 3)
                XCTAssertTrue(choices.contains(dive.answer(for: phase)))
            }
            var state = Checkpoint()
            state.phase = 1
            state.choice = dive.answer(for: 1)
            state.checked = true
            log.save(state, for: dive)
            XCTAssertEqual(DiveLog(defaults: store).checkpoint(for: dive).choice, state.choice)
            log.finish(state, for: dive)
            XCTAssertEqual(log.checkpoint(for: dive).phase, -1)
            XCTAssertEqual(log.secured(in: dive.sectorIndex), (dive.id - 1) % 10 + 1)
        }
        XCTAssertNil(log.next)
        XCTAssertEqual(DiveLog(defaults: store).count, 100)
        XCTAssertEqual(log.cleanCount, 100)
        log.finish(Checkpoint(), for: Course.dives[99])
        XCTAssertEqual(log.count, 100)
    }

    func testDiveRepairAndResume() {
        let app = XCUIApplication()
        app.launchEnvironment["DEPTHBYTE_TEST_DOMAIN"] = "depthbyte.test." + UUID().uuidString
        app.launch()
        capture("Bridge")
        app.buttons["tab-Depth chart"].tap()
        XCTAssertFalse(app.buttons["dive-2"].isEnabled)
        app.buttons["Next sector"].tap()
        XCTAssertFalse(app.buttons["dive-11"].isEnabled)
        capture("Depth-chart")
        app.buttons["tab-Bridge"].tap()
        app.buttons["launch"].tap()
        app.buttons["full-program"].tap()
        XCTAssertTrue(app.buttons["full-program"].label.contains("Show lesson excerpt"))
        capture("Complete-program")
        app.buttons["full-program"].tap()
        advance(app)
        let dive = Course.dives[0]
        let correct = dive.options(for: 0).firstIndex(of: dive.output)!
        app.buttons["option-\((correct + 1) % 3)"].tap()
        advance(app)
        XCTAssertTrue(app.buttons["lab-action"].label.contains("Adjust answer"))
        advance(app)
        app.buttons["option-\(correct)"].tap()
        app.terminate()
        app.launch()
        app.buttons["launch"].tap()
        XCTAssertTrue(app.buttons["option-\(correct)"].isSelected)
        advance(app)
        advance(app)
        capture("Repair-bench")
        let repair = dive.options(for: 1).firstIndex(of: dive.answer(for: 1))!
        app.buttons["option-\(repair)"].tap()
        advance(app)
        advance(app)
        XCTAssertTrue(app.staticTexts["Back on deck"].exists)
        XCTAssertTrue(app.staticTexts["1/2"].exists)
        advance(app)
        app.buttons["tab-Depth chart"].tap()
        XCTAssertTrue(app.buttons["dive-2"].isEnabled)
        app.buttons["dive-1"].tap()
        advance(app)
        for phase in 0..<2 {
            let index = dive.options(for: phase).firstIndex(of: dive.answer(for: phase))!
            app.buttons["option-\(index)"].tap()
            advance(app)
            advance(app)
        }
        advance(app)
        app.buttons["tab-Salvage"].tap()
        XCTAssertTrue(app.staticTexts["Signal lamp"].exists)
        capture("Salvage")
        app.terminate()
        app.launch()
        XCTAssertTrue(app.staticTexts["1/100"].exists)
    }
}
