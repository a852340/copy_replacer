import AppKit

final class StatusBarController {
    private let statusItem: NSStatusItem
    private let popover: NSPopover
    private let eventMonitor: EventMonitor

    init(popover: NSPopover) {
        self.popover = popover
        self.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            if let image = NSImage(systemSymbolName: "text.cursor", accessibilityDescription: "Comma Replacer") {
                image.isTemplate = true
                button.image = image
            } else {
                button.title = ","
            }
            button.action = #selector(togglePopover(_:))
            button.target = self
        }

        self.eventMonitor = EventMonitor(mask: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            guard let self, self.popover.isShown else { return }
            self.hidePopover(event)
        }
        eventMonitor.start()
    }

    @objc func togglePopover(_ sender: Any?) {
        if popover.isShown {
            hidePopover(sender)
        } else {
            showPopover(sender)
        }
    }

    func showPopover(_ sender: Any?) {
        guard let button = statusItem.button else { return }
        popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        NSApp.activate(ignoringOtherApps: true)
    }

    func hidePopover(_ sender: Any?) {
        popover.performClose(sender)
    }
}

final class EventMonitor {
    private let mask: NSEvent.EventTypeMask
    private let handler: (NSEvent?) -> Void
    private var monitor: Any?

    init(mask: NSEvent.EventTypeMask, handler: @escaping (NSEvent?) -> Void) {
        self.mask = mask
        self.handler = handler
    }

    func start() {
        guard monitor == nil else { return }
        monitor = NSEvent.addGlobalMonitorForEvents(matching: mask, handler: handler)
    }

    func stop() {
        guard let monitor else { return }
        NSEvent.removeMonitor(monitor)
        self.monitor = nil
    }

    deinit {
        stop()
    }
}
