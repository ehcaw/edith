import SwiftUI

// Simple persistent notch content - just a small square
struct NotchContentView: View {
    @ObservedObject private var assistantState = VoiceAssistantState.shared
    
    var body: some View {
        HStack(spacing: 8) {
            // Simple icon
            Image(systemName: assistantState.isListening ? "mic.fill" : "mic.slash.fill")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(assistantState.isListening ? .red : .gray)
                .frame(width: 16, height: 16)
            
            // Simple text
            Text(assistantState.isListening ? "Recording" : "EDITH")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(NSColor.controlBackgroundColor))
                .shadow(color: Color.black.opacity(0.1), radius: 1, x: 0, y: 1)
        )
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                assistantState.toggleListening()
            }
        }
    }
}

// Main content view (not used in notch, but keeping for potential future use)
struct ContentView: View {
    @ObservedObject private var assistantState = VoiceAssistantState.shared
    
    var body: some View {
        VStack(spacing: 20) {
            Text("EDITH Voice Assistant")
                .font(.title2)
                .padding()
            
            // Status indicator
            HStack {
                Circle()
                    .fill(assistantState.isListening ? Color.red : (assistantState.isProcessing ? Color.orange : Color.gray))
                    .frame(width: 12, height: 12)
                
                Text(assistantState.isListening ? "Recording..." : (assistantState.isProcessing ? "Processing..." : "Press to Record"))
                    .font(.headline)
            }
            
            // Transcription display
            VStack(alignment: .leading, spacing: 4) {
                Text("Transcription:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                ScrollView {
                    Text(assistantState.lastTranscription.isEmpty ? "Press unmute and speak..." : assistantState.lastTranscription)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                        .textSelection(.enabled)
                        .foregroundColor(assistantState.lastTranscription.isEmpty ? .secondary : .primary)
                }
                .frame(height: 60)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            
            // Response display
            VStack(alignment: .leading, spacing: 4) {
                Text("EDITH Response:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                ScrollView {
                    Text(assistantState.lastResponse.isEmpty ? "Response will appear here..." : assistantState.lastResponse)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                        .textSelection(.enabled)
                        .foregroundColor(assistantState.lastResponse.isEmpty ? .secondary : .primary)
                }
                .frame(height: 60)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            
            // Controls
            HStack(spacing: 20) {
                Button(action: {
                    assistantState.toggleListening()
                }) {
                    Label(
                        assistantState.isListening ? "Mute" : "Unmute",
                        systemImage: assistantState.isListening ? "mic.slash.fill" : "mic.fill"
                    )
                }
                .buttonStyle(.borderedProminent)
                .disabled(assistantState.isProcessing)
                
                if !assistantState.lastResponse.isEmpty {
                    Button(action: {
                        assistantState.speak(assistantState.lastResponse)
                    }) {
                        Label("Replay", systemImage: "play.fill")
                    }
                    .buttonStyle(.bordered)
                }
                
                Button(action: {
                    assistantState.clearTranscripts()
                }) {
                    Label("Clear", systemImage: "trash")
                }
                .buttonStyle(.bordered)
                .disabled(assistantState.isListening)
            }
            
            VStack(spacing: 4) {
                Text("Press 'Unmute' to start recording, 'Mute' to stop and process")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                Text("Keyboard shortcut: ⌘⇧L • Notch for quick access")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding()
            
            // Error display
            if !assistantState.errorMessage.isEmpty {
                Text(assistantState.errorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.horizontal)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
        .frame(width: 400, height: 500)
    }
}

// Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
            
            NotchContentView()
                .previewLayout(.sizeThatFits)
                .padding()
        }
    }
}