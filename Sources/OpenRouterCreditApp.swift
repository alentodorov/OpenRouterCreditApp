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
            
            button.action = #selector(togglePopover)
            button.target = self
        }
        
        // Create menu for right-click options
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Refresh", action: #selector(refreshData), keyEquivalent: "r"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q"))
        
        statusItem.menu = menu
        
        popover = NSPopover()
        popover.contentSize = NSSize(width: 300, height: 200)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: CreditView(openRouterAPI: openRouterAPI))
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
    
    @objc func refreshData() {
        fetchCreditUsage()
    }
    
    @objc func quitApp() {
        NSApplication.shared.terminate(nil)
    }
    
    func fetchCreditUsage() {
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