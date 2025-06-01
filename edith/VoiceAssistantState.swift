import SwiftUI
import Combine

// Observable object to manage the voice assistant state
class VoiceAssistantState: ObservableObject {
    static let shared = VoiceAssistantState()

    // Voice assistant instance
    private lazy var assistant = VoiceAssistant()

    // Published properties that views can observe
    @Published var isListening = false
    @Published var lastTranscription = ""
    @Published var lastResponse = ""
    @Published var isProcessing = false
    @Published var errorMessage = ""

    // Private initializer for singleton
    private init() {
        setupAssistantCallbacks()
    }

    private func setupAssistantCallbacks() {
        // Setup callbacks for transcription and response updates
        assistant.onTranscriptionUpdate = { [weak self] transcript in
            self?.lastTranscription = transcript
        }
        
        assistant.onResponseReceived = { [weak self] response in
            self?.lastResponse = response
            self?.isProcessing = false
        }
    }

    // Method to toggle listening state (mute/unmute)
    func toggleListening() {
        if isListening {
            stopListening()
        } else {
            startListening()
        }
    }

    // Start recording and transcribing (unmute)
    func startListening() {
        do {
            try assistant.startRecording()
            isListening = true
            errorMessage = ""
            lastTranscription = ""
            lastResponse = ""
            print("🎤 Started listening")
        } catch {
            isListening = false
            errorMessage = "Failed to start recording: \(error.localizedDescription)"
            print("❌ Failed to start listening: \(error)")
        }
    }

    // Stop recording and transcribing (mute)
    func stopListening() {
        assistant.stopRecording()
        isListening = false
        isProcessing = true
        print("🛑 Stopped listening - processing transcript...")
    }

    // Convenience method to speak text directly
    func speak(_ text: String) {
        assistant.speak(text)
    }
    
    // Stop current speech
    func stopSpeaking() {
        assistant.stopSpeaking()
    }
    
    // Clear the current transcription and response
    func clearTranscripts() {
        lastTranscription = ""
        lastResponse = ""
        errorMessage = ""
    }
}