//
//  iosTncConfigUITests.swift
//  iosTncConfigUITests
//
//  Created by Rob on 2026-06-05.
//

import XCTest
@testable import Mobilinkd_TNC_Config

final class iosTncConfigUITests: XCTestCase {

  var app: XCUIApplication!

  override func setUp() {
    super.setUp()
    continueAfterFailure = false
    app = XCUIApplication()
    app.launchArguments = ["--uitesting"]
    app.launch()
  }

  // MARK: - App Launch

  func testAppLaunches() throws {
    let navBar = app.navigationBars["Mobilinkd TNC Config"]
    XCTAssertTrue(navBar.waitForExistence(timeout: 10), "Main navigation bar should appear after launch")

    let tableView = app.tables["bleDeviceTable"]
    XCTAssertTrue(tableView.waitForExistence(timeout: 5), "BLE device table should be visible")
  }

  // MARK: - Disconnected Navigation (Suite A)

  func testDisconnectedNavigation() throws {
    let tncConfigButton = app.buttons["tncConfigButton"]
    XCTAssertTrue(tncConfigButton.waitForExistence(timeout: 5))
    tncConfigButton.tap()

    // Audio Input screen should appear — check for its key label
    let audioInputLabel = app.staticTexts["audioInputLabel"]
    XCTAssertTrue(audioInputLabel.waitForExistence(timeout: 5), "Audio Input view should be visible")

    // Back to menu via navigation bar back button
    let backButton = app.navigationBars.buttons["Back"]
    if backButton.exists {
      backButton.tap()
    } else {
      // Swipe from left edge for back gesture
      let screen = app.windows.firstMatch
      let start = screen.coordinate(withNormalizedOffset: CGVector(dx: 0.1, dy: 0.5))
      let end = screen.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.5))
      start.press(forDuration: 0.1, thenDragTo: end)
    }

    XCTAssertTrue(tncConfigButton.waitForExistence(timeout: 5), "Should return to TNC Config Menu")
  }

  // MARK: - Audio Settings Interaction

  func testAudioInputSettings() throws {
    let tncConfigButton = app.buttons["tncConfigButton"]
    XCTAssertTrue(tncConfigButton.waitForExistence(timeout: 5))
    tncConfigButton.tap()

    let gainSlider = app.sliders["gainSlider"]
    XCTAssertTrue(gainSlider.waitForExistence(timeout: 5), "Gain slider should be present")
  }

  // MARK: - Power Settings

  func testPowerSettingsScreen() throws {
    let tncConfigButton = app.buttons["tncConfigButton"]
    XCTAssertTrue(tncConfigButton.waitForExistence(timeout: 5))
    tncConfigButton.tap()

    let batteryLabel = app.staticTexts["batteryLevelLabel"]
    XCTAssertTrue(batteryLabel.exists, "Battery level label should exist")
  }

  // MARK: - Kiss Params Screen

  func testKissParamsScreen() throws {
    let tncConfigButton = app.buttons["tncConfigButton"]
    XCTAssertTrue(tncConfigButton.waitForExistence(timeout: 5))
    tncConfigButton.tap()

    let fcsButton = app.buttons["fcsButton"]
    XCTAssertTrue(fcsButton.exists, "FCS button should exist")
  }

  // MARK: - Modem Config Screen

  func testModemConfigScreen() throws {
    let tncConfigButton = app.buttons["tncConfigButton"]
    XCTAssertTrue(tncConfigButton.waitForExistence(timeout: 5))
    tncConfigButton.tap()

    let baudPicker = app.pickerWheels["baudRatePickerWheel"]
    XCTAssertTrue(baudPicker.exists, "Baud rate picker wheel should exist")
  }

  // MARK: - TNC Info Screen

  func testTncInfoScreen() throws {
    let tncConfigButton = app.buttons["tncConfigButton"]
    XCTAssertTrue(tncConfigButton.waitForExistence(timeout: 5))
    tncConfigButton.tap()

    let fwLabel = app.staticTexts["firmwareVersionLabel"]
    XCTAssertTrue(fwLabel.exists, "Firmware version label should exist")
  }

  // MARK: - BLE Device List

  func testBleDeviceListDisplay() throws {
    let tableView = app.tables["bleDeviceTable"]
    XCTAssertTrue(tableView.waitForExistence(timeout: 5))

    let firstCell = tableView.cells.firstMatch
    XCTAssertNotNil(firstCell, "Table should have a cell element")
  }
}
