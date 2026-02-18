//
//  SnapshotHelper.swift
//  Swift 6 compatible version of Fastlane's SnapshotHelper
//

import Foundation
import XCTest

// MARK: - Public API

@MainActor
func setupSnapshot(_ app: XCUIApplication, waitForAnimations: Bool = true) {
    Snapshot.setupSnapshot(app, waitForAnimations: waitForAnimations)
}

@MainActor
func snapshot(_ name: String, timeWaitingForIdle timeout: TimeInterval = 20) {
    Snapshot.snapshot(name, timeWaitingForIdle: timeout)
}

// MARK: - Snapshot Engine

@MainActor
enum Snapshot {
    static var app: XCUIApplication?
    static var waitForAnimations = true
    static var cacheDirectory: URL?

    static func setupSnapshot(_ app: XCUIApplication, waitForAnimations: Bool = true) {
        Snapshot.app = app
        Snapshot.waitForAnimations = waitForAnimations

        do {
            let cacheDir = try cachePath()
            Snapshot.cacheDirectory = cacheDir
            setLanguage(app)
            setLocale(app)
            setLaunchArguments(app)
        } catch {
            NSLog("Snapshot: Error during setup: \(error)")
        }
    }

    static func snapshot(_ name: String, timeWaitingForIdle timeout: TimeInterval = 20) {
        if timeout > 0 && waitForAnimations {
            waitForLoadingIndicatorToDisappear(within: timeout)
        }

        NSLog("Snapshot: Taking snapshot '\(name)'")
        sleep(1)

        guard let app = self.app else {
            NSLog("Snapshot: XCUIApplication not set. Call setupSnapshot(app) first.")
            return
        }

        let screenshot = app.windows.firstMatch.screenshot()

        // Attach to xcresult so capture_screenshots can extract it
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        XCTContext.runActivity(named: "Snapshot: \(name)") { activity in
            activity.add(attachment)
        }
    }

    // MARK: - Private

    private static func cachePath() throws -> URL {
        let cachePaths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
        let cacheDir = URL(fileURLWithPath: cachePaths[0])
        return cacheDir.appendingPathComponent("tools.fastlane")
    }

    private static func setLanguage(_ app: XCUIApplication) {
        guard let cacheDirectory else { return }
        let path = cacheDirectory.appendingPathComponent("language.txt")
        do {
            let lang = try String(contentsOf: path, encoding: .utf8)
                .trimmingCharacters(in: .whitespacesAndNewlines)
            guard !lang.isEmpty else { return }
            app.launchArguments += ["-AppleLanguages", "(\(lang))"]
        } catch {
            NSLog("Snapshot: Couldn't detect language...")
        }
    }

    private static func setLocale(_ app: XCUIApplication) {
        guard let cacheDirectory else { return }
        let path = cacheDirectory.appendingPathComponent("locale.txt")
        do {
            let loc = try String(contentsOf: path, encoding: .utf8)
                .trimmingCharacters(in: .whitespacesAndNewlines)
            guard !loc.isEmpty else { return }
            app.launchArguments += ["-AppleLocale", "\"\(loc)\""]
        } catch {
            NSLog("Snapshot: Couldn't detect locale...")
        }
    }

    private static func setLaunchArguments(_ app: XCUIApplication) {
        guard let cacheDirectory else { return }
        let path = cacheDirectory.appendingPathComponent("snapshot-launch_arguments.txt")
        app.launchArguments += ["-FASTLANE_SNAPSHOT", "YES", "-ui_testing"]

        do {
            let content = try String(contentsOf: path, encoding: .utf8)
            content.components(separatedBy: .newlines).forEach { line in
                let arg = line.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !arg.isEmpty else { return }
                app.launchArguments.append(arg)
            }
        } catch {
            NSLog("Snapshot: Couldn't detect launch arguments...")
        }
    }

    private static func waitForLoadingIndicatorToDisappear(within timeout: TimeInterval) {
        guard let app else { return }
        let networkLoadingIndicator = app.otherElements.element(
            matching: .any,
            identifier: "network-loading-indicator"
        )
        let pred = NSPredicate(format: "exists == false")
        let expectation = XCTNSPredicateExpectation(predicate: pred, object: networkLoadingIndicator)
        _ = XCTWaiter.wait(for: [expectation], timeout: timeout)
    }
}

// Please don't remove the lines below
// They are used to detect outdated configuration files
// SnapshotHelperVersion [1.30]
