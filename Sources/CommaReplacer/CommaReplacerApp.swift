import SwiftUI
import AppKit

@main
struct CommaReplacerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        Settings {
            SettingsView(clipboardManager: appDelegate.clipboardManager)
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    let clipboardManager = ClipboardManager()

    private let popover = NSPopover()
    private var statusBarController: StatusBarController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        popover.contentSize = NSSize(width: 340, height: 520)
        popover.behavior = .transient
        popover.animates = true
        popover.contentViewController = NSHostingController(
            rootView: AppMenuView(clipboardManager: clipboardManager) { [weak self] in
                self?.statusBarController?.hidePopover(nil)
            }
        )

        statusBarController = StatusBarController(popover: popover)

        clipboardManager.onReplacementDetected = { [weak self] in
            DispatchQueue.main.async {
                self?.statusBarController?.showPopover(nil)
            }
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        clipboardManager.stopMonitoring()
    }
}
