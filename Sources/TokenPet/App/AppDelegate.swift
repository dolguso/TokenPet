import AppKit
import SwiftUI

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private let popover = NSPopover()
    private var eventMonitor: Any?
    private weak var appModel: TokenPetAppModel?

    func applicationDidFinishLaunching(_ notification: Notification) {
        let appModel = TokenPetAppModel.shared
        install(appModel: appModel)

        NSApp.setActivationPolicy(.accessory)
        popover.behavior = .transient
        popover.animates = true

        Task {
            await appModel.bootstrap()
        }
    }

    func install(appModel: TokenPetAppModel) {
        self.appModel = appModel

        if popover.contentViewController == nil {
            popover.contentSize = NSSize(width: 340, height: 360)
            popover.contentViewController = NSHostingController(
                rootView: PopoverRootView(appModel: appModel)
            )
        }

        if let button = statusItem.button {
            button.target = self
            button.action = #selector(togglePopover(_:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }

        updateStatusItem(symbol: appModel.statusSymbol)
    }

    func updateStatusItem(symbol: String) {
        guard let button = statusItem.button else { return }

        var attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 16)
        ]

        if let appModel {
            attributes[.foregroundColor] = NSColor(appModel.statusTint)
        }

        button.attributedTitle = NSAttributedString(string: symbol, attributes: attributes)
        button.toolTip = appModel?.statusMessage
    }

    @objc private func togglePopover(_ sender: AnyObject?) {
        if popover.isShown {
            closePopover(sender)
        } else {
            showPopover(sender)
        }
    }

    private func showPopover(_ sender: AnyObject?) {
        guard let button = statusItem.button else { return }
        popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
            self?.closePopover(sender)
        }
    }

    private func closePopover(_ sender: AnyObject?) {
        popover.performClose(sender)
        if let eventMonitor {
            NSEvent.removeMonitor(eventMonitor)
            self.eventMonitor = nil
        }
    }
}
