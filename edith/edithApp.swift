import SwiftUI
import AppKit
#if canImport(DynamicNotchKit)
import DynamicNotchKit
#endif
#if canImport(AIProxy)
import AIProxy
#endif

@main
struct edithApp: App {
    @StateObject private var assistantState = VoiceAssistantState.shared

    init() {
        // Configure AIProxy if available
        #if canImport(AIProxy)
        AIProxy.configure(
            logLevel: .debug,
            printRequestBodies: false,  // Flip to true for library development
            printResponseBodies: false, // Flip to true for library development
            resolveDNSOverTLS: true,
            useStableID: false,         // Please see the docstring if you'd like to enable this
        )
        #endif
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                // Main app interface that can be shown/hidden
                ContentView()
                    .frame(minWidth: 400, minHeight: 500)
                
                // Invisible anchor view to keep app alive when main window is closed
                Color.clear
                    .frame(width: 1, height: 1)
                    .onAppear {
                        Task {
                            showPersistentNotch()
                        }
                    }
            }
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .commands {
            // Remove default menu items
            CommandGroup(replacing: .newItem) { }
            CommandGroup(replacing: .pasteboard) { }
            
            // Add voice control menu
            CommandMenu("Voice Assistant") {
                Button(assistantState.isListening ? "Stop Listening" : "Start Listening") {
                    assistantState.toggleListening()
                }
                .keyboardShortcut("l", modifiers: [.command, .shift])
                
                Divider()
                
                Button("Show Main Window") {
                    NSApp.activate(ignoringOtherApps: true)
                    NSApp.windows.first?.makeKeyAndOrderFront(nil)
                }
                .keyboardShortcut("e", modifiers: [.command, .shift])
            }
        }
    }

    @MainActor
    private func showPersistentNotch() {
        #if canImport(DynamicNotchKit)
        let notch = DynamicNotch {
            NotchContentView()
        }

        notch.show()
        print("EDITH notch is now visible")
        #else
        print("DynamicNotchKit not available - notch functionality disabled")
        #endif
        
        // Greet the user
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            assistantState.speak("EDITH is ready")
        }
    }
    

}
