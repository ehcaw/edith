import SwiftUI
import AppKit
import DynamicNotchKit

@main
struct edithApp: App {
    private let assistant = VoiceAssistant()
    
    init() {
        // Start the assistant immediately
        assistant.start()
    }

    var body: some Scene {
        WindowGroup {
            // Invisible anchor view to keep app alive
            Color.clear
                .frame(width: 1, height: 1)
                .onAppear {
                    Task {
                        await showPersistentNotch()
                    }
                }
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .commands {
            // Remove default menu items
            CommandGroup(replacing: .newItem) { }
            CommandGroup(replacing: .pasteboard) { }
        }
    }
    
    @MainActor
    private func showPersistentNotch() async {
        let notch = DynamicNotch {
            NotchContentView()
        }
        
        await notch.show()
        print("EDITH notch is now visible")
    }
}