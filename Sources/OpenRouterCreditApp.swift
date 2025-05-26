import Cocoa
import SwiftUI

@main
struct OpenRouterCreditApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var popover: NSPopover!
    var timer: Timer?
    let openRouterAPI = OpenRouterAPI()

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupMenuBar()
        fetchCreditUsage()

        // Set up timer to refresh data every 30 seconds
        timer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            self?.fetchCreditUsage()
        }
    }

    func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            // Use a simple system icon that resembles the OpenRouter logo concept
            if #available(macOS 11.0, *) {
                button.image = NSImage(systemSymbolName: "arrow.triangle.branch", accessibilityDescription: "OpenRouter Credits")
            } else {
                button.image = NSImage(named: NSImage.infoName)
            }
            button.image?.size = NSSize(width: 16, height: 16)

            button.action = #selector(handleButtonClick)
            button.target = self

            // Enable right-click for menu
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }

        popover = NSPopover()
        popover.contentSize = NSSize(width: 300, height: 200)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: CreditView(openRouterAPI: openRouterAPI))
    }

    @objc func handleButtonClick() {
        guard let event = NSApp.currentEvent else { return }

        if event.type == .rightMouseUp {
            showContextMenu()
        } else {
            togglePopover()
        }
    }

    @objc func togglePopover() {
        if let button = statusItem.button {
            if popover.isShown {
                popover.performClose(nil)
            } else {
                fetchCreditUsage()
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            }
        }
    }

    func showContextMenu() {
        let menu = NSMenu()

        // Check if API key exists
        let hasAPIKey = UserDefaults.standard.string(forKey: "openRouterAPIKey") != nil

        if !hasAPIKey {
            menu.addItem(NSMenuItem(title: "Set API Key", action: #selector(showAPIKeyDialog), keyEquivalent: ""))
            menu.addItem(NSMenuItem.separator())
        }

        menu.addItem(NSMenuItem(title: "Refresh", action: #selector(refreshData), keyEquivalent: "r"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q"))

        if let button = statusItem.button {
            menu.popUp(positioning: nil, at: NSPoint(x: 0, y: button.bounds.height), in: button)
        }
    }

    @objc func showAPIKeyDialog() {
        let alert = NSAlert()
        alert.messageText = "Enter OpenRouter API Key"
        alert.informativeText = "Please enter your OpenRouter API key to view credit information."
        alert.addButton(withTitle: "Save")
        alert.addButton(withTitle: "Cancel")

        let textField = NSSecureTextField(frame: NSRect(x: 0, y: 0, width: 300, height: 24))
        textField.placeholderString = "sk-or-..."

        // Load existing API key if available
        if let existingKey = UserDefaults.standard.string(forKey: "openRouterAPIKey") {
            textField.stringValue = existingKey
        }

        alert.accessoryView = textField

        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            let apiKey = textField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
            if !apiKey.isEmpty {
                openRouterAPI.saveAPIKey(apiKey)
                fetchCreditUsage()
            }
        }
    }

    @objc func refreshData() {
        fetchCreditUsage()
    }

    @objc func quitApp() {
        NSApplication.shared.terminate(nil)
    }

    func fetchCreditUsage() {
        // Check if API key exists
        let hasAPIKey = UserDefaults.standard.string(forKey: "openRouterAPIKey") != nil

        if !hasAPIKey {
            DispatchQueue.main.async { [weak self] in
                if let button = self?.statusItem.button {
                    button.title = "No Key"
                }
            }
            return
        }

        openRouterAPI.fetchCreditUsage { [weak self] in
            DispatchQueue.main.async {
                if let button = self?.statusItem.button {
                    if let remaining = self?.openRouterAPI.creditInfo?.remaining {
                        button.title = "$\(String(format: "%.2f", remaining))"
                    } else {
                        button.title = "Error"
                    }
                }
            }
        }
    }
}